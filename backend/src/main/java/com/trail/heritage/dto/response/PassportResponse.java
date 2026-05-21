package com.trail.heritage.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class PassportResponse {
    private String userId;
    private String displayName;
    private int totalPoints;
    private int totalVisits;
    private int totalLandmarks;    // total available landmarks
    private double completionPercent;
    private List<LandmarkResponse> visitedLandmarks;
    private List<RewardResponse> earnedRewards;
}
