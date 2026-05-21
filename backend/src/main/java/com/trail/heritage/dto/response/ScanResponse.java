package com.trail.heritage.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
public class ScanResponse {
    private String visitId;
    private String landmarkId;
    private String landmarkName;
    private int pointsEarned;
    private int totalPoints;
    private double distanceMeters;
    private boolean firstVisit;
    private boolean savedToPassport;
    private Instant visitedAt;
    private RewardResponse rewardUnlocked;  // null if no new reward
    private LandmarkContentResponse content;
}
