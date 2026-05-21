package com.trail.heritage.controller;

import com.trail.heritage.dto.response.AnalyticsResponse;
import com.trail.heritage.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/analytics")
@PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
@RequiredArgsConstructor
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @GetMapping("/heatmap")
    public ResponseEntity<AnalyticsResponse> heatmap(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(analyticsService.getHeatmap(startDate, endDate));
    }

    @GetMapping("/flow")
    public ResponseEntity<AnalyticsResponse> flow(
            @RequestParam(required = false) UUID landmarkId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDate start = startDate != null ? startDate : LocalDate.now().minusDays(30);
        LocalDate end   = endDate   != null ? endDate   : LocalDate.now();
        return ResponseEntity.ok(analyticsService.getFlow(landmarkId, start, end));
    }

    @GetMapping("/landmarks/{id}")
    public ResponseEntity<AnalyticsResponse> landmarkStats(@PathVariable UUID id) {
        return ResponseEntity.ok(analyticsService.getLandmarkStats(id));
    }
}
