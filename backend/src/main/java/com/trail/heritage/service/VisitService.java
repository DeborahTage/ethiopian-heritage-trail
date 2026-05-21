package com.trail.heritage.service;

import com.trail.heritage.dto.request.ScanRequest;
import com.trail.heritage.dto.response.RewardResponse;
import com.trail.heritage.dto.response.ScanResponse;
import com.trail.heritage.exception.*;
import com.trail.heritage.model.*;
import com.trail.heritage.repository.*;
import com.trail.heritage.mapper.VisitMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class VisitService {

    private final LandmarkRepository landmarkRepo;
    private final VisitRepository visitRepo;
    private final UserRepository userRepo;
    private final FailedVisitRepository failedVisitRepo;
    private final ScanAnalyticsRepository analyticsRepo;
    private final QrCodeService qrCodeService;
    private final GpsVerificationService gpsService;
    private final RateLimitService rateLimitService;
    private final RewardService rewardService;
    private final VisitMapper visitMapper;
    private final LandmarkContentService landmarkContentService;

    private final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    @Transactional
    public ScanResponse claimVisit(ScanRequest req, UUID userId) {
        User user = userRepo.findById(userId)
                .orElseThrow(() -> new LandmarkNotFoundException("User not found"));

        // 1. Decode QR — get landmark ID from payload (validate secret later)
        UUID landmarkId;
        try {
            // Parse the landmark ID from the payload without secret validation first
            String payload = req.getQrPayload();
            String prefix = "heritage-trail://visit/";
            if (!payload.startsWith(prefix)) throw new InvalidQrCodeException("Invalid QR scheme");
            String[] parts = payload.substring(prefix.length()).split("\\?secret=");
            landmarkId = UUID.fromString(parts[0]);
        } catch (InvalidQrCodeException e) {
            recordFailure(userId, null, req, "INVALID_QR_FORMAT");
            throw e;
        } catch (Exception e) {
            recordFailure(userId, null, req, "INVALID_QR_FORMAT");
            throw new InvalidQrCodeException("Could not parse QR payload");
        }

        // 2. Load landmark
        Landmark landmark = landmarkRepo.findById(landmarkId)
                .orElseThrow(() -> {
                    recordFailure(userId, null, req, "LANDMARK_NOT_FOUND");
                    return new LandmarkNotFoundException(landmarkId.toString());
                });

        // 3. Validate QR secret
        try {
            qrCodeService.decodeLandmarkId(req.getQrPayload(), landmark.getQrSecret());
        } catch (InvalidQrCodeException e) {
            recordFailure(userId, landmark, req, "INVALID_QR_SECRET");
            throw e;
        }

        // 4. GPS check
        double landmarkLat = landmark.getLocation().getY();
        double landmarkLng = landmark.getLocation().getX();
        double distance = gpsService.calculateDistance(req.getLatitude(), req.getLongitude(), landmarkLat, landmarkLng);

        if (!gpsService.isWithinRange(req.getLatitude(), req.getLongitude(), landmarkLat, landmarkLng, landmark.getGpsRadiusMeters())) {
            recordFailure(userId, landmark, req, "GPS_TOO_FAR");
            throw new GpsVerificationException(
                    String.format("You are %.0fm from this landmark (max %dm allowed).",
                            distance, landmark.getGpsRadiusMeters()));
        }

        // 5. Rate limit
        rateLimitService.checkAndSet(userId, landmarkId);

        // 6. Duplicate-visit check (same day)
        long todayVisits = visitRepo.countTodayVisits(userId, landmarkId, LocalDate.now());
        boolean firstVisit = (todayVisits == 0);

        // 7. Record visit
        Visit visit = Visit.builder()
                .user(user)
                .landmark(landmark)
                .scanLat(req.getLatitude())
                .scanLng(req.getLongitude())
                .distanceMeters(distance)
                .pointsEarned(landmark.getPointsValue())
                .deviceId(req.getDeviceId())
                .appVersion(req.getAppVersion())
                .build();
        visit = visitRepo.save(visit);

        // 8. Update user points
        user.setTotalPoints(user.getTotalPoints() + landmark.getPointsValue());
        userRepo.save(user);

        // 9. Record analytics
        recordAnalytics(landmark, user, req, true, null);

        // 10. Check rewards
        Optional<RewardResponse> newReward = rewardService.checkAndAwardRewards(user, visit);

        // 11. Build response
        ScanResponse response = visitMapper.toScanResponse(visit);
        response.setTotalPoints(user.getTotalPoints());
        response.setFirstVisit(firstVisit);
        response.setRewardUnlocked(newReward.orElse(null));
        response.setSavedToPassport(true);
        response.setContent(landmarkContentService.getOptionalContentForScan(landmarkId));

        log.info("Visit claimed: user={} landmark={} points={}", userId, landmarkId, landmark.getPointsValue());
        return response;
    }

    private void recordFailure(UUID userId, Landmark landmark, ScanRequest req, String reason) {
        try {
            FailedVisit fv = FailedVisit.builder()
                    .landmark(landmark)
                    .scanLat(req.getLatitude())
                    .scanLng(req.getLongitude())
                    .failureReason(reason)
                    .rawQrData(req.getQrPayload())
                    .deviceId(req.getDeviceId())
                    .build();
            failedVisitRepo.save(fv);
            if (landmark != null) {
                recordAnalytics(landmark, null, req, false, reason);
            }
        } catch (Exception ex) {
            log.warn("Failed to record failure audit: {}", ex.getMessage());
        }
    }

    private void recordAnalytics(Landmark landmark, User user, ScanRequest req, boolean success, String failureReason) {
        try {
            ScanAnalytics sa = ScanAnalytics.builder()
                    .landmark(landmark)
                    .user(user)
                    .scanDate(LocalDate.now())
                    .scanHour((short) java.time.LocalTime.now().getHour())
                    .scanLat(req.getLatitude())
                    .scanLng(req.getLongitude())
                    .success(success)
                    .failureReason(failureReason)
                    .build();
            analyticsRepo.save(sa);
        } catch (Exception ex) {
            log.warn("Failed to record analytics: {}", ex.getMessage());
        }
    }
}
