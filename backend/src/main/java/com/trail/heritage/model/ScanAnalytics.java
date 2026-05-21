package com.trail.heritage.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "scan_analytics")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScanAnalytics extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "landmark_id", nullable = false)
    private Landmark landmark;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "scan_date", nullable = false)
    private LocalDate scanDate = LocalDate.now();

    @Column(name = "scan_hour", nullable = false)
    private Short scanHour;

    @Column(name = "scan_lat")
    private Double scanLat;

    @Column(name = "scan_lng")
    private Double scanLng;

    @Column(nullable = false)
    private Boolean success = true;

    @Column(name = "failure_reason", length = 100)
    private String failureReason;
}
