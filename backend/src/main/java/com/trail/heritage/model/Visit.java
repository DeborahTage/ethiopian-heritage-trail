package com.trail.heritage.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "visits")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Visit extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "landmark_id", nullable = false)
    private Landmark landmark;

    @Column(name = "scan_lat", nullable = false)
    private Double scanLat;

    @Column(name = "scan_lng", nullable = false)
    private Double scanLng;

    @Column(name = "distance_meters", nullable = false)
    private Double distanceMeters;

    @Column(name = "points_earned", nullable = false)
    private Integer pointsEarned = 0;

    @Column(name = "device_id", length = 256)
    private String deviceId;

    @Column(name = "app_version", length = 20)
    private String appVersion;
}
