package com.trail.heritage.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class LandmarkContentResponse {
    private UUID id;
    private UUID landmarkId;
    private String landmarkName;
    private StoryResponse story;
    private MediaResponse media;
    private BadgeResponse badge;
    private PracticalInfoResponse practicalInfo;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Data
    @Builder
    public static class StoryResponse {
        private String shortStoryEn;
        private String shortStoryAm;
        private String fullHistoryEn;
        private String fullHistoryAm;
        private List<String> funFacts;
    }

    @Data
    @Builder
    public static class MediaResponse {
        private String heroImageUrl;
        private List<String> galleryUrls;
        private String videoUrl;
        private Integer videoDuration;
        private String videoThumbnailUrl;
        private String audioGuideUrl;
        private Integer audioDuration;
    }

    @Data
    @Builder
    public static class BadgeResponse {
        private String badgeName;
        private String badgeIconUrl;
        private Integer badgePoints;
        private String badgeRarity;
    }

    @Data
    @Builder
    public static class PracticalInfoResponse {
        private String openingHours;
        private String entryFee;
        private String bestTime;
        private String contactPhone;
    }
}
