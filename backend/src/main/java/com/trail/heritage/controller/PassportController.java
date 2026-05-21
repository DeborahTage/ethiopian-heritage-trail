package com.trail.heritage.controller;

import com.trail.heritage.dto.response.*;
import com.trail.heritage.mapper.LandmarkMapper;
import com.trail.heritage.model.User;
import com.trail.heritage.model.Visit;
import com.trail.heritage.repository.*;
import com.trail.heritage.service.RewardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/passport")
@RequiredArgsConstructor
public class PassportController {

    private final UserRepository userRepo;
    private final VisitRepository visitRepo;
    private final LandmarkRepository landmarkRepo;
    private final LandmarkMapper landmarkMapper;
    private final RewardService rewardService;

    @GetMapping
    public ResponseEntity<PassportResponse> getPassport(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        User user = userRepo.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Visit> visits = visitRepo.findByUserIdOrderByCreatedAtDesc(userId);
        List<UUID> visitedLandmarkIds = visits.stream()
                .map(v -> v.getLandmark().getId()).distinct().toList();

        List<LandmarkResponse> visitedLandmarks = visitedLandmarkIds.stream()
                .map(id -> landmarkRepo.findById(id).orElse(null))
                .filter(l -> l != null)
                .map(l -> {
                    LandmarkResponse r = landmarkMapper.toResponse(l);
                    r.setVisited(true);
                    return r;
                }).toList();

        List<RewardResponse> earnedRewards = rewardService.getEarnedRewards(userId);
        long totalLandmarks = landmarkRepo.countByIsActiveTrue();
        double completionPercent = totalLandmarks == 0 ? 0
                : (double) visitedLandmarkIds.size() / totalLandmarks * 100;

        PassportResponse passport = PassportResponse.builder()
                .userId(userId.toString())
                .displayName(user.getDisplayName())
                .totalPoints(user.getTotalPoints())
                .totalVisits(visits.size())
                .totalLandmarks((int) totalLandmarks)
                .completionPercent(Math.round(completionPercent * 10.0) / 10.0)
                .visitedLandmarks(visitedLandmarks)
                .earnedRewards(earnedRewards)
                .build();

        return ResponseEntity.ok(passport);
    }
}
