package com.trail.heritage.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
@Builder
public class AnalyticsResponse {
    private long totalScans;
    private long successfulScans;
    private long failedScans;
    private double successRate;
    private List<HeatmapPoint> heatmapPoints;
    private List<Map<String, Object>> flowData;
    private Map<String, Long> scansByHour;
    private Map<String, Long> scansByLandmark;

    @Data
    @Builder
    public static class HeatmapPoint {
        private String landmarkId;
        private double lat;
        private double lng;
        private long count;
    }
}
