package com.trail.heritage.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "landmark_contents")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LandmarkContent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "landmark_id", nullable = false, unique = true)
    private Landmark landmark;

    @Column(name = "short_story_en", columnDefinition = "TEXT")
    private String shortStoryEn;

    @Column(name = "short_story_am", columnDefinition = "TEXT")
    private String shortStoryAm;

    @Column(name = "full_history_en", columnDefinition = "TEXT")
    private String fullHistoryEn;

    @Column(name = "full_history_am", columnDefinition = "TEXT")
    private String fullHistoryAm;

    @Builder.Default
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "fun_facts", columnDefinition = "jsonb")
    private List<String> funFacts = new ArrayList<>();

    @Column(name = "hero_image_url", length = 500)
    private String heroImageUrl;

    @Builder.Default
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "gallery_urls", columnDefinition = "jsonb")
    private List<String> galleryUrls = new ArrayList<>();

    @Column(name = "video_url", length = 500)
    private String videoUrl;

    @Column(name = "video_duration")
    private Integer videoDuration;

    @Column(name = "video_thumbnail_url", length = 500)
    private String videoThumbnailUrl;

    @Column(name = "audio_guide_url", length = 500)
    private String audioGuideUrl;

    @Column(name = "audio_duration")
    private Integer audioDuration;

    @Column(name = "badge_name", length = 100)
    private String badgeName;

    @Column(name = "badge_icon_url", length = 500)
    private String badgeIconUrl;

    @Column(name = "badge_points")
    private Integer badgePoints = 0;

    @Column(name = "badge_rarity", length = 20)
    private String badgeRarity = "common";

    @Column(name = "opening_hours", length = 50)
    private String openingHours;

    @Column(name = "entry_fee", length = 50)
    private String entryFee;

    @Column(name = "best_time", length = 50)
    private String bestTime;

    @Column(name = "contact_phone", length = 20)
    private String contactPhone;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
