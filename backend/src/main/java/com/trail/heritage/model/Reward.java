package com.trail.heritage.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "rewards")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Reward extends BaseEntity {

    @Column(nullable = false, length = 200)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "badge_url", length = 1024)
    private String badgeUrl;

    @Column(name = "points_cost", nullable = false)
    private Integer pointsCost = 0;

    @Enumerated(EnumType.STRING)
    @Column(name = "reward_type", nullable = false, length = 50)
    private RewardType rewardType = RewardType.BADGE;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    public enum RewardType {
        BADGE, DISCOUNT, CERTIFICATE, PHYSICAL
    }
}
