package com.trail.heritage.model;

import jakarta.persistence.*;
import lombok.*;
import org.locationtech.jts.geom.Point;

import java.util.List;

@Entity
@Table(name = "landmarks")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Landmark extends BaseEntity {

    @Column(nullable = false, length = 200)
    private String name;

    @Column(name = "name_am", length = 200)
    private String nameAm;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "description_am", columnDefinition = "TEXT")
    private String descriptionAm;

    @Column(columnDefinition = "geometry(Point, 4326)", nullable = false)
    private Point location;

    @Column(length = 500)
    private String address;

    @Column(length = 100)
    private String region;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private Category category = Category.HERITAGE;

    @Column(name = "media_url", length = 1024)
    private String mediaUrl;

    @Column(name = "qr_code_url", length = 1024)
    private String qrCodeUrl;

    @Column(name = "qr_secret", nullable = false, length = 256)
    private String qrSecret;

    @Column(name = "gps_radius_meters", nullable = false)
    private Integer gpsRadiusMeters = 200;

    @Column(name = "points_value", nullable = false)
    private Integer pointsValue = 10;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @OneToMany(mappedBy = "landmark", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Visit> visits;

    public enum Category {
        HERITAGE, MUSEUM, CHURCH, MOSQUE, PALACE, NATURE, OTHER
    }
}
