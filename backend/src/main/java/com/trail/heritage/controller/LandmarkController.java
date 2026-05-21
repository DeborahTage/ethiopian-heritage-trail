package com.trail.heritage.controller;

import com.trail.heritage.dto.request.LandmarkCreateRequest;
import com.trail.heritage.dto.request.LandmarkUpdateRequest;
import com.trail.heritage.dto.response.LandmarkResponse;
import com.trail.heritage.exception.LandmarkNotFoundException;
import com.trail.heritage.mapper.LandmarkMapper;
import com.trail.heritage.model.Landmark;
import com.trail.heritage.repository.LandmarkRepository;
import com.trail.heritage.repository.VisitRepository;
import com.trail.heritage.service.QrCodeService;
import com.trail.heritage.service.StorageService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/landmarks")
@RequiredArgsConstructor
public class LandmarkController {

    private final LandmarkRepository landmarkRepo;
    private final VisitRepository visitRepo;
    private final LandmarkMapper landmarkMapper;
    private final QrCodeService qrCodeService;
    private final StorageService storageService;

    private final GeometryFactory gf = new GeometryFactory(new PrecisionModel(), 4326);

    @GetMapping
    public ResponseEntity<List<LandmarkResponse>> listAll(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        List<Landmark> landmarks = landmarkRepo.findByIsActiveTrue();
        List<UUID> visitedIds = visitRepo.findByUserIdOrderByCreatedAtDesc(userId)
                .stream().map(v -> v.getLandmark().getId()).distinct().toList();

        List<LandmarkResponse> responses = landmarks.stream()
                .map(l -> {
                    LandmarkResponse r = landmarkMapper.toResponse(l);
                    r.setVisited(visitedIds.contains(l.getId()));
                    return r;
                }).toList();
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/{id}")
    public ResponseEntity<LandmarkResponse> getById(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        Landmark landmark = landmarkRepo.findById(id)
                .orElseThrow(() -> new LandmarkNotFoundException(id.toString()));
        LandmarkResponse response = landmarkMapper.toResponse(landmark);
        boolean visited = visitRepo.findByUserIdOrderByCreatedAtDesc(userId)
                .stream().anyMatch(v -> v.getLandmark().getId().equals(id));
        response.setVisited(visited);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/qr")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<byte[]> getQrCode(@PathVariable UUID id) {
        Landmark landmark = landmarkRepo.findById(id)
                .orElseThrow(() -> new LandmarkNotFoundException(id.toString()));
        byte[] qrPng = qrCodeService.generateQrPng(landmark.getId(), landmark.getQrSecret(), 400);
        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_PNG)
                .body(qrPng);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<LandmarkResponse> create(@Valid @RequestBody LandmarkCreateRequest req) {
        Landmark landmark = Landmark.builder()
                .name(req.getName())
                .nameAm(req.getNameAm())
                .description(req.getDescription())
                .descriptionAm(req.getDescriptionAm())
                .location(gf.createPoint(new Coordinate(req.getLongitude(), req.getLatitude())))
                .address(req.getAddress())
                .region(req.getRegion())
                .category(req.getCategory())
                .gpsRadiusMeters(req.getGpsRadiusMeters())
                .pointsValue(req.getPointsValue())
                .qrSecret(UUID.randomUUID().toString())
                .isActive(true)
                .build();
        landmark = landmarkRepo.save(landmark);

        // Generate and persist QR code
        byte[] qrPng = qrCodeService.generateQrPng(landmark.getId(), landmark.getQrSecret(), 400);
        String qrUrl = storageService.uploadQrCode(landmark.getId(), qrPng);
        landmark.setQrCodeUrl(qrUrl);
        landmarkRepo.save(landmark);

        return ResponseEntity.status(HttpStatus.CREATED).body(landmarkMapper.toResponse(landmark));
    }
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<LandmarkResponse> update(@PathVariable UUID id, @Valid @RequestBody LandmarkUpdateRequest req) {
        Landmark landmark = landmarkRepo.findById(id)
                .orElseThrow(() -> new LandmarkNotFoundException(id.toString()));

        landmark.setName(req.getName());
        landmark.setNameAm(req.getNameAm());
        landmark.setDescription(req.getDescription());
        landmark.setDescriptionAm(req.getDescriptionAm());
        landmark.setLocation(gf.createPoint(new Coordinate(req.getLongitude(), req.getLatitude())));
        landmark.setAddress(req.getAddress());
        landmark.setRegion(req.getRegion());
        landmark.setCategory(req.getCategory());
        landmark.setGpsRadiusMeters(req.getGpsRadiusMeters());
        landmark.setPointsValue(req.getPointsValue());
        landmark.setIsActive(req.isActive());

        landmark = landmarkRepo.save(landmark);
        return ResponseEntity.ok(landmarkMapper.toResponse(landmark));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        Landmark landmark = landmarkRepo.findById(id)
                .orElseThrow(() -> new LandmarkNotFoundException(id.toString()));
        landmark.setIsActive(false);
        landmarkRepo.save(landmark);
        return ResponseEntity.noContent().build();
    }
}
