package com.trail.heritage.service;

import com.trail.heritage.dto.response.AnalyticsResponse;
import com.trail.heritage.model.ScanAnalytics;
import com.trail.heritage.repository.ScanAnalyticsRepository;
import com.trail.heritage.repository.VisitRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final ScanAnalyticsRepository analyticsRepo;
    private final VisitRepository visitRepo;

    public AnalyticsResponse getHeatmap(LocalDate start, LocalDate end) {
        List<ScanAnalytics> records = analyticsRepo.findByScanDateBetween(start, end);

        long total = records.size();
        long successful = records.stream().filter(ScanAnalytics::getSuccess).count();

        List<Object[]> raw = analyticsRepo.findHeatmapData(start, end);
        List<AnalyticsResponse.HeatmapPoint> heatmap = raw.stream()
                .map(r -> AnalyticsResponse.HeatmapPoint.builder()
                        .landmarkId(r[0].toString())
                        .lat(((Number) r[1]).doubleValue())
                        .lng(((Number) r[2]).doubleValue())
                        .count(((Number) r[3]).longValue())
                        .build())
                .toList();

        Map<String, Long> byHour = records.stream()
                .collect(Collectors.groupingBy(
                        sa -> String.format("%02d:00", sa.getScanHour()),
                        Collectors.counting()));

        Map<String, Long> byLandmark = records.stream()
                .filter(sa -> sa.getLandmark() != null)
                .collect(Collectors.groupingBy(
                        sa -> sa.getLandmark().getName(),
                        Collectors.counting()));

        return AnalyticsResponse.builder()
                .totalScans(total)
                .successfulScans(successful)
                .failedScans(total - successful)
                .successRate(total == 0 ? 0 : (double) successful / total * 100)
                .heatmapPoints(heatmap)
                .scansByHour(byHour)
                .scansByLandmark(byLandmark)
                .build();
    }

    public AnalyticsResponse getFlow(UUID landmarkId, LocalDate start, LocalDate end) {
        List<ScanAnalytics> records = landmarkId != null
                ? analyticsRepo.findByLandmarkIdAndScanDateBetween(landmarkId, start, end)
                : analyticsRepo.findByScanDateBetween(start, end);

        long total = records.size();
        long successful = records.stream().filter(ScanAnalytics::getSuccess).count();

        List<Map<String, Object>> flow = records.stream()
                .collect(Collectors.groupingBy(ScanAnalytics::getScanDate, Collectors.counting()))
                .entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .map(e -> {
                    Map<String, Object> point = new LinkedHashMap<>();
                    point.put("date", e.getKey().toString());
                    point.put("scans", e.getValue());
                    return point;
                }).toList();

        return AnalyticsResponse.builder()
                .totalScans(total)
                .successfulScans(successful)
                .failedScans(total - successful)
                .successRate(total == 0 ? 0 : (double) successful / total * 100)
                .flowData(flow)
                .build();
    }

    public AnalyticsResponse getLandmarkStats(UUID landmarkId) {
        LocalDate start = LocalDate.now().minusDays(30);
        LocalDate end   = LocalDate.now();
        return getFlow(landmarkId, start, end);
    }
}
