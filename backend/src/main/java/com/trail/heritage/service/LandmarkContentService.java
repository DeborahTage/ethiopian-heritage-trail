package com.trail.heritage.service;

import com.trail.heritage.dto.request.LandmarkContentRequest;
import com.trail.heritage.dto.response.LandmarkContentResponse;
import com.trail.heritage.exception.LandmarkNotFoundException;
import com.trail.heritage.model.Landmark;
import com.trail.heritage.model.LandmarkContent;
import com.trail.heritage.repository.LandmarkContentRepository;
import com.trail.heritage.repository.LandmarkRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LandmarkContentService {

    private final LandmarkRepository landmarkRepository;
    private final LandmarkContentRepository contentRepository;

    @Transactional
    public LandmarkContentResponse createContent(UUID landmarkId, LandmarkContentRequest request) {
        Landmark landmark = landmarkRepository.findById(landmarkId)
                .orElseThrow(() -> new LandmarkNotFoundException(landmarkId.toString()));

        if (contentRepository.existsByLandmarkId(landmarkId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Content already exists for this landmark");
        }

        LandmarkContent content = new LandmarkContent();
        content.setLandmark(landmark);
        applyRequest(content, request);
        return toResponse(contentRepository.save(content));
    }

    @Transactional
    public LandmarkContentResponse updateContent(UUID landmarkId, LandmarkContentRequest request) {
        LandmarkContent content = contentRepository.findByLandmarkId(landmarkId)
                .orElseGet(() -> {
                    Landmark landmark = landmarkRepository.findById(landmarkId)
                            .orElseThrow(() -> new LandmarkNotFoundException(landmarkId.toString()));
                    LandmarkContent created = new LandmarkContent();
                    created.setLandmark(landmark);
                    return created;
                });

        applyRequest(content, request);
        return toResponse(contentRepository.save(content));
    }

    @Transactional(readOnly = true)
    public LandmarkContentResponse getContentByLandmarkId(UUID landmarkId) {
        return contentRepository.findByLandmarkId(landmarkId)
                .map(this::toResponse)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Landmark content not found"));
    }

    @Transactional
    public void deleteContent(UUID landmarkId) {
        LandmarkContent content = contentRepository.findByLandmarkId(landmarkId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Landmark content not found"));
        contentRepository.delete(content);
    }

    @Transactional(readOnly = true)
    public LandmarkContentResponse getContentForScan(UUID landmarkId) {
        return getContentByLandmarkId(landmarkId);
    }

    @Transactional(readOnly = true)
    public LandmarkContentResponse getOptionalContentForScan(UUID landmarkId) {
        return contentRepository.findByLandmarkId(landmarkId)
                .map(this::toResponse)
                .orElse(null);
    }

    private void applyRequest(LandmarkContent content, LandmarkContentRequest request) {
        LandmarkContentRequest safeRequest = request == null ? new LandmarkContentRequest() : request;
        LandmarkContentRequest.StoryRequest story = safeRequest.getStory() == null
                ? new LandmarkContentRequest.StoryRequest()
                : safeRequest.getStory();
        LandmarkContentRequest.MediaRequest media = safeRequest.getMedia() == null
                ? new LandmarkContentRequest.MediaRequest()
                : safeRequest.getMedia();
        LandmarkContentRequest.BadgeRequest badge = safeRequest.getBadge() == null
                ? new LandmarkContentRequest.BadgeRequest()
                : safeRequest.getBadge();
        LandmarkContentRequest.PracticalInfoRequest practical = safeRequest.getPracticalInfo() == null
                ? new LandmarkContentRequest.PracticalInfoRequest()
                : safeRequest.getPracticalInfo();

        validate(media, badge);

        content.setShortStoryEn(story.getShortStoryEn());
        content.setShortStoryAm(story.getShortStoryAm());
        content.setFullHistoryEn(story.getFullHistoryEn());
        content.setFullHistoryAm(story.getFullHistoryAm());
        content.setFunFacts(cleanList(story.getFunFacts()));

        content.setHeroImageUrl(media.getHeroImageUrl());
        content.setGalleryUrls(cleanList(media.getGalleryUrls()));
        content.setVideoUrl(media.getVideoUrl());
        content.setVideoDuration(media.getVideoDuration());
        content.setVideoThumbnailUrl(media.getVideoThumbnailUrl());
        content.setAudioGuideUrl(media.getAudioGuideUrl());
        content.setAudioDuration(media.getAudioDuration());

        content.setBadgeName(badge.getBadgeName());
        content.setBadgeIconUrl(badge.getBadgeIconUrl());
        content.setBadgePoints(badge.getBadgePoints() == null ? 0 : badge.getBadgePoints());
        content.setBadgeRarity(badge.getBadgeRarity() == null || badge.getBadgeRarity().isBlank()
                ? "common"
                : badge.getBadgeRarity());

        content.setOpeningHours(practical.getOpeningHours());
        content.setEntryFee(practical.getEntryFee());
        content.setBestTime(practical.getBestTime());
        content.setContactPhone(practical.getContactPhone());
    }

    private void validate(LandmarkContentRequest.MediaRequest media, LandmarkContentRequest.BadgeRequest badge) {
        if (media.getVideoUrl() != null && !media.getVideoUrl().isBlank()
                && (media.getVideoDuration() == null || media.getVideoDuration() <= 0)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "video_url requires video_duration > 0");
        }
        if (badge.getBadgePoints() != null && badge.getBadgePoints() < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "badge_points must be >= 0");
        }
    }

    private List<String> cleanList(List<String> values) {
        if (values == null) {
            return new ArrayList<>();
        }
        return values.stream()
                .filter(value -> value != null && !value.isBlank())
                .toList();
    }

    private LandmarkContentResponse toResponse(LandmarkContent content) {
        Landmark landmark = content.getLandmark();
        return LandmarkContentResponse.builder()
                .id(content.getId())
                .landmarkId(landmark.getId())
                .landmarkName(landmark.getName())
                .story(LandmarkContentResponse.StoryResponse.builder()
                        .shortStoryEn(content.getShortStoryEn())
                        .shortStoryAm(content.getShortStoryAm())
                        .fullHistoryEn(content.getFullHistoryEn())
                        .fullHistoryAm(content.getFullHistoryAm())
                        .funFacts(content.getFunFacts())
                        .build())
                .media(LandmarkContentResponse.MediaResponse.builder()
                        .heroImageUrl(content.getHeroImageUrl())
                        .galleryUrls(content.getGalleryUrls())
                        .videoUrl(content.getVideoUrl())
                        .videoDuration(content.getVideoDuration())
                        .videoThumbnailUrl(content.getVideoThumbnailUrl())
                        .audioGuideUrl(content.getAudioGuideUrl())
                        .audioDuration(content.getAudioDuration())
                        .build())
                .badge(LandmarkContentResponse.BadgeResponse.builder()
                        .badgeName(content.getBadgeName())
                        .badgeIconUrl(content.getBadgeIconUrl())
                        .badgePoints(content.getBadgePoints())
                        .badgeRarity(content.getBadgeRarity())
                        .build())
                .practicalInfo(LandmarkContentResponse.PracticalInfoResponse.builder()
                        .openingHours(content.getOpeningHours())
                        .entryFee(content.getEntryFee())
                        .bestTime(content.getBestTime())
                        .contactPhone(content.getContactPhone())
                        .build())
                .createdAt(content.getCreatedAt())
                .updatedAt(content.getUpdatedAt())
                .build();
    }
}
