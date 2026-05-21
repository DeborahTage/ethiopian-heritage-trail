package com.trail.heritage.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class LandmarkContentRequest {

    @Valid
    private StoryRequest story = new StoryRequest();

    @Valid
    private MediaRequest media = new MediaRequest();

    @Valid
    private BadgeRequest badge = new BadgeRequest();

    @Valid
    private PracticalInfoRequest practicalInfo = new PracticalInfoRequest();

    @Data
    public static class StoryRequest {
        private String shortStoryEn;
        private String shortStoryAm;
        private String fullHistoryEn;
        private String fullHistoryAm;
        private List<String> funFacts = new ArrayList<>();
    }

    @Data
    public static class MediaRequest {
        private String heroImageUrl;
        private List<String> galleryUrls = new ArrayList<>();
        private String videoUrl;
        private Integer videoDuration;
        private String videoThumbnailUrl;
        private String audioGuideUrl;
        private Integer audioDuration;
    }

    @Data
    public static class BadgeRequest {
        private String badgeName;
        private String badgeIconUrl;

        @Min(0)
        private Integer badgePoints = 0;

        private String badgeRarity = "common";
    }

    @Data
    public static class PracticalInfoRequest {
        private String openingHours;
        private String entryFee;
        private String bestTime;
        private String contactPhone;
    }
}
