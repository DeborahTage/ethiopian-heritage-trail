package com.trail.heritage.dto.response;

import com.trail.heritage.model.Reward;
import lombok.Builder;
import lombok.Data;

import java.time.Instant;

@Data
@Builder
public class RewardResponse {
    private String id;
    private String name;
    private String description;
    private String badgeUrl;
    private int pointsCost;
    private Reward.RewardType rewardType;
    private boolean earned;
    private Instant earnedAt;
}
