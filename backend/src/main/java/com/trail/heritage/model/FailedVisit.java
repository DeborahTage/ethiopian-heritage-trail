package com.trail.heritage.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "failed_visits")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FailedVisit extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "landmark_id")
    private Landmark landmark;

    @Column(name = "scan_lat")
    private Double scanLat;

    @Column(name = "scan_lng")
    private Double scanLng;

    @Column(name = "distance_meters")
    private Double distanceMeters;

    @Column(name = "failure_reason", nullable = false, length = 100)
    private String failureReason;

    @Column(name = "raw_qr_data", columnDefinition = "TEXT")
    private String rawQrData;

    @Column(name = "device_id", length = 256)
    private String deviceId;
}
