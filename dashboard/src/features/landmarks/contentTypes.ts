export type BadgeRarity = 'common' | 'rare' | 'epic' | 'legendary';

export interface LandmarkContentPayload {
    story: {
        shortStoryEn?: string;
        shortStoryAm?: string;
        fullHistoryEn?: string;
        fullHistoryAm?: string;
        funFacts: string[];
    };
    media: {
        heroImageUrl?: string;
        galleryUrls: string[];
        videoUrl?: string;
        videoDuration?: number;
        videoThumbnailUrl?: string;
        audioGuideUrl?: string;
        audioDuration?: number;
    };
    badge: {
        badgeName?: string;
        badgeIconUrl?: string;
        badgePoints: number;
        badgeRarity: BadgeRarity;
    };
    practicalInfo: {
        openingHours?: string;
        entryFee?: string;
        bestTime?: string;
        contactPhone?: string;
    };
}

export interface LandmarkContent extends LandmarkContentPayload {
    id: string;
    landmarkId: string;
    landmarkName: string;
    createdAt?: string;
    updatedAt?: string;
}

export interface UploadResponse {
    url: string;
    size: number;
    type: string;
}

export const emptyContent: LandmarkContentPayload = {
    story: {
        shortStoryEn: '',
        shortStoryAm: '',
        fullHistoryEn: '',
        fullHistoryAm: '',
        funFacts: [],
    },
    media: {
        heroImageUrl: '',
        galleryUrls: [],
        videoUrl: '',
        videoDuration: 0,
        videoThumbnailUrl: '',
        audioGuideUrl: '',
        audioDuration: 0,
    },
    badge: {
        badgeName: '',
        badgeIconUrl: '',
        badgePoints: 0,
        badgeRarity: 'common',
    },
    practicalInfo: {
        openingHours: '',
        entryFee: '',
        bestTime: '',
        contactPhone: '',
    },
};
