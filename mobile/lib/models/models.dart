
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String role;
  final int totalPoints;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.totalPoints,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:           json['id'] as String,
        email:        json['email'] as String,
        displayName:  json['displayName'] as String,
        role:         json['role'] as String,
        totalPoints:  json['totalPoints'] as int? ?? 0,
      );
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken:  json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        tokenType:    json['tokenType'] as String? ?? 'Bearer',
        expiresIn:    json['expiresIn'] as int? ?? 900,
        user:         UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class LandmarkModel {
  final String id;
  final String name;
  final String? nameAm;
  final String? description;
  final double latitude;
  final double longitude;
  final String? address;
  final String? region;
  final String category;
  final String? mediaUrl;
  final int gpsRadiusMeters;
  final int pointsValue;
  final bool visited;

  const LandmarkModel({
    required this.id,
    required this.name,
    this.nameAm,
    this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    this.region,
    required this.category,
    this.mediaUrl,
    required this.gpsRadiusMeters,
    required this.pointsValue,
    required this.visited,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json) => LandmarkModel(
        id:              json['id'] as String,
        name:            json['name'] as String,
        nameAm:          json['nameAm'] as String?,
        description:     json['description'] as String?,
        latitude:        (json['latitude'] as num).toDouble(),
        longitude:       (json['longitude'] as num).toDouble(),
        address:         json['address'] as String?,
        region:          json['region'] as String?,
        category:        json['category'] as String? ?? 'HERITAGE',
        mediaUrl:        json['mediaUrl'] as String?,
        gpsRadiusMeters: json['gpsRadiusMeters'] as int? ?? 200,
        pointsValue:     json['pointsValue'] as int? ?? 10,
        visited:         json['visited'] as bool? ?? false,
      );
}

class AdventurePackageModel {
  final String id;
  final String landmarkId;
  final String landmarkName;
  final String title;
  final String? description;
  final String difficulty;
  final int durationMinutes;
  final List<String> activities;
  final List<String> imageUrls;
  final int priceUSD;
  final bool available;
  final int maxParticipants;
  final String? guideName;

  const AdventurePackageModel({
    required this.id,
    required this.landmarkId,
    required this.landmarkName,
    required this.title,
    this.description,
    required this.difficulty,
    required this.durationMinutes,
    required this.activities,
    required this.imageUrls,
    required this.priceUSD,
    required this.available,
    required this.maxParticipants,
    this.guideName,
  });

  factory AdventurePackageModel.fromJson(Map<String, dynamic> json) => AdventurePackageModel(
        id:              json['id'] as String,
        landmarkId:      json['landmarkId'] as String,
        landmarkName:    json['landmarkName'] as String,
        title:           json['title'] as String,
        description:     json['description'] as String?,
        difficulty:      json['difficulty'] as String? ?? 'moderate',
        durationMinutes: json['durationMinutes'] as int? ?? 60,
        activities:      (json['activities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        imageUrls:       (json['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        priceUSD:        json['priceUSD'] as int? ?? 0,
        available:       json['available'] as bool? ?? true,
        maxParticipants: json['maxParticipants'] as int? ?? 10,
        guideName:       json['guideName'] as String?,
      );
}

class ScanResponse {
  final String visitId;
  final String landmarkId;
  final String landmarkName;
  final int pointsEarned;
  final int totalPoints;
  final double distanceMeters;
  final bool firstVisit;
  final bool savedToPassport;
  final RewardModel? rewardUnlocked;
  final LandmarkContentModel? content;

  const ScanResponse({
    required this.visitId,
    required this.landmarkId,
    required this.landmarkName,
    required this.pointsEarned,
    required this.totalPoints,
    required this.distanceMeters,
    required this.firstVisit,
    required this.savedToPassport,
    this.rewardUnlocked,
    this.content,
  });

  factory ScanResponse.fromJson(Map<String, dynamic> json) => ScanResponse(
        visitId:        json['visitId'] as String,
        landmarkId:     json['landmarkId'] as String,
        landmarkName:   json['landmarkName'] as String,
        pointsEarned:   json['pointsEarned'] as int? ?? 0,
        totalPoints:    json['totalPoints'] as int? ?? 0,
        distanceMeters: (json['distanceMeters'] as num).toDouble(),
        firstVisit:     json['firstVisit'] as bool? ?? false,
        savedToPassport: json['savedToPassport'] as bool? ?? false,
        rewardUnlocked: json['rewardUnlocked'] == null
            ? null
            : RewardModel.fromJson(json['rewardUnlocked'] as Map<String, dynamic>),
        content: json['content'] == null
            ? null
            : LandmarkContentModel.fromJson(json['content'] as Map<String, dynamic>),
      );
}

class LandmarkContentModel {
  final String id;
  final String landmarkId;
  final String landmarkName;
  final StoryContent story;
  final MediaContent media;
  final BadgeContent badge;
  final PracticalInfoContent practicalInfo;
  final String? visitDate;

  const LandmarkContentModel({
    required this.id,
    required this.landmarkId,
    required this.landmarkName,
    required this.story,
    required this.media,
    required this.badge,
    required this.practicalInfo,
    this.visitDate,
  });

  factory LandmarkContentModel.fromJson(Map<String, dynamic> json) => LandmarkContentModel(
        id: json['id'] as String? ?? '',
        landmarkId: json['landmarkId'] as String,
        landmarkName: json['landmarkName'] as String? ?? 'Landmark',
        story: StoryContent.fromJson(json['story'] as Map<String, dynamic>? ?? <String, dynamic>{}),
        media: MediaContent.fromJson(json['media'] as Map<String, dynamic>? ?? <String, dynamic>{}),
        badge: BadgeContent.fromJson(json['badge'] as Map<String, dynamic>? ?? <String, dynamic>{}),
        practicalInfo: PracticalInfoContent.fromJson(json['practicalInfo'] as Map<String, dynamic>? ?? <String, dynamic>{}),
        visitDate: json['visitDate'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'landmarkId': landmarkId,
        'landmarkName': landmarkName,
        'story': story.toJson(),
        'media': media.toJson(),
        'badge': badge.toJson(),
        'practicalInfo': practicalInfo.toJson(),
        'visitDate': visitDate,
      };

  LandmarkContentModel visitedNow() => LandmarkContentModel(
        id: id,
        landmarkId: landmarkId,
        landmarkName: landmarkName,
        story: story,
        media: media,
        badge: badge,
        practicalInfo: practicalInfo,
        visitDate: DateTime.now().toIso8601String(),
      );
}

class StoryContent {
  final String? shortStoryEn;
  final String? shortStoryAm;
  final String? fullHistoryEn;
  final String? fullHistoryAm;
  final List<String> funFacts;

  const StoryContent({this.shortStoryEn, this.shortStoryAm, this.fullHistoryEn, this.fullHistoryAm, required this.funFacts});

  factory StoryContent.fromJson(Map<String, dynamic> json) => StoryContent(
        shortStoryEn: json['shortStoryEn'] as String?,
        shortStoryAm: json['shortStoryAm'] as String?,
        fullHistoryEn: json['fullHistoryEn'] as String?,
        fullHistoryAm: json['fullHistoryAm'] as String?,
        funFacts: (json['funFacts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'shortStoryEn': shortStoryEn,
        'shortStoryAm': shortStoryAm,
        'fullHistoryEn': fullHistoryEn,
        'fullHistoryAm': fullHistoryAm,
        'funFacts': funFacts,
      };
}

class MediaContent {
  final String? heroImageUrl;
  final List<String> galleryUrls;
  final String? videoUrl;
  final int? videoDuration;
  final String? videoThumbnailUrl;
  final String? audioGuideUrl;
  final int? audioDuration;

  const MediaContent({this.heroImageUrl, required this.galleryUrls, this.videoUrl, this.videoDuration, this.videoThumbnailUrl, this.audioGuideUrl, this.audioDuration});

  factory MediaContent.fromJson(Map<String, dynamic> json) => MediaContent(
        heroImageUrl: json['heroImageUrl'] as String?,
        galleryUrls: (json['galleryUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        videoUrl: json['videoUrl'] as String?,
        videoDuration: json['videoDuration'] as int?,
        videoThumbnailUrl: json['videoThumbnailUrl'] as String?,
        audioGuideUrl: json['audioGuideUrl'] as String?,
        audioDuration: json['audioDuration'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'heroImageUrl': heroImageUrl,
        'galleryUrls': galleryUrls,
        'videoUrl': videoUrl,
        'videoDuration': videoDuration,
        'videoThumbnailUrl': videoThumbnailUrl,
        'audioGuideUrl': audioGuideUrl,
        'audioDuration': audioDuration,
      };
}

class BadgeContent {
  final String? badgeName;
  final String? badgeIconUrl;
  final int badgePoints;
  final String badgeRarity;

  const BadgeContent({this.badgeName, this.badgeIconUrl, required this.badgePoints, required this.badgeRarity});

  factory BadgeContent.fromJson(Map<String, dynamic> json) => BadgeContent(
        badgeName: json['badgeName'] as String?,
        badgeIconUrl: json['badgeIconUrl'] as String?,
        badgePoints: json['badgePoints'] as int? ?? 0,
        badgeRarity: json['badgeRarity'] as String? ?? 'common',
      );

  Map<String, dynamic> toJson() => {
        'badgeName': badgeName,
        'badgeIconUrl': badgeIconUrl,
        'badgePoints': badgePoints,
        'badgeRarity': badgeRarity,
      };
}

class PracticalInfoContent {
  final String? openingHours;
  final String? entryFee;
  final String? bestTime;
  final String? contactPhone;

  const PracticalInfoContent({this.openingHours, this.entryFee, this.bestTime, this.contactPhone});

  factory PracticalInfoContent.fromJson(Map<String, dynamic> json) => PracticalInfoContent(
        openingHours: json['openingHours'] as String?,
        entryFee: json['entryFee'] as String?,
        bestTime: json['bestTime'] as String?,
        contactPhone: json['contactPhone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'openingHours': openingHours,
        'entryFee': entryFee,
        'bestTime': bestTime,
        'contactPhone': contactPhone,
      };
}

class RewardModel {
  final String id;
  final String name;
  final String? description;
  final String? badgeUrl;
  final bool earned;

  const RewardModel({
    required this.id,
    required this.name,
    this.description,
    this.badgeUrl,
    required this.earned,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) => RewardModel(
        id:          json['id'] as String,
        name:        json['name'] as String,
        description: json['description'] as String?,
        badgeUrl:    json['badgeUrl'] as String?,
        earned:      json['earned'] as bool? ?? false,
      );
}

class PassportModel {
  final String userId;
  final String displayName;
  final int totalPoints;
  final int totalVisits;
  final int totalLandmarks;
  final double completionPercent;
  final List<LandmarkModel> visitedLandmarks;
  final List<RewardModel> earnedRewards;

  const PassportModel({
    required this.userId,
    required this.displayName,
    required this.totalPoints,
    required this.totalVisits,
    required this.totalLandmarks,
    required this.completionPercent,
    required this.visitedLandmarks,
    required this.earnedRewards,
  });

  factory PassportModel.fromJson(Map<String, dynamic> json) => PassportModel(
        userId:            json['userId'] as String,
        displayName:       json['displayName'] as String,
        totalPoints:       json['totalPoints'] as int? ?? 0,
        totalVisits:       json['totalVisits'] as int? ?? 0,
        totalLandmarks:    json['totalLandmarks'] as int? ?? 0,
        completionPercent: (json['completionPercent'] as num?)?.toDouble() ?? 0.0,
        visitedLandmarks:  (json['visitedLandmarks'] as List<dynamic>?)
                ?.map((e) => LandmarkModel.fromJson(e as Map<String, dynamic>))
                .toList() ?? [],
        earnedRewards:     (json['earnedRewards'] as List<dynamic>?)
                ?.map((e) => RewardModel.fromJson(e as Map<String, dynamic>))
                .toList() ?? [],
      );
}
