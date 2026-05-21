package com.trail.heritage.controller;

import com.trail.heritage.dto.request.LandmarkContentRequest;
import com.trail.heritage.dto.response.LandmarkContentResponse;
import com.trail.heritage.service.LandmarkContentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequiredArgsConstructor
public class LandmarkContentController {

    private final LandmarkContentService landmarkContentService;

    @PostMapping("/api/v1/admin/landmarks/{landmarkId}/content")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<LandmarkContentResponse> create(
            @PathVariable UUID landmarkId,
            @Valid @RequestBody LandmarkContentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(landmarkContentService.createContent(landmarkId, request));
    }

    @PutMapping("/api/v1/admin/landmarks/{landmarkId}/content")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<LandmarkContentResponse> update(
            @PathVariable UUID landmarkId,
            @Valid @RequestBody LandmarkContentRequest request) {
        return ResponseEntity.ok(landmarkContentService.updateContent(landmarkId, request));
    }

    @GetMapping("/api/v1/admin/landmarks/{landmarkId}/content")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<LandmarkContentResponse> getAdmin(@PathVariable UUID landmarkId) {
        return ResponseEntity.ok(landmarkContentService.getContentByLandmarkId(landmarkId));
    }

    @DeleteMapping("/api/v1/admin/landmarks/{landmarkId}/content")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable UUID landmarkId) {
        landmarkContentService.deleteContent(landmarkId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/api/v1/landmarks/{landmarkId}/content")
    public ResponseEntity<LandmarkContentResponse> getPublic(@PathVariable UUID landmarkId) {
        return ResponseEntity.ok(landmarkContentService.getContentForScan(landmarkId));
    }
}
