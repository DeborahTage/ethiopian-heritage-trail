import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import 'api_service.dart';

class OfflineSyncService {
  final ApiService _apiService;
  late StreamSubscription _connectivitySub;
  bool _isSyncing = false;

  OfflineSyncService(this._apiService) {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        syncPendingScans();
      }
    });
  }

  void dispose() {
    _connectivitySub.cancel();
  }

  Future<void> queueScan(String qrPayload, double lat, double lng) async {
    final box = Hive.box('pending_scans');
    final scanData = {
      'qrPayload': qrPayload,
      'latitude': lat,
      'longitude': lng,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await box.add(scanData);
    _enforceCacheSize(box);
  }

  Future<void> cacheScanResponse(ScanResponse response) async {
    final content = response.content;
    if (content == null) return;
    final visitedContent = content.visitedNow();
    await _saveContent(visitedContent);
    if (content.media.heroImageUrl != null) {
      await _cacheMedia(content.media.heroImageUrl!);
    }
  }

  Future<void> saveToMemories(LandmarkContentModel content) async {
    await _saveContent(content.visitedNow());
    final urls = <String>[
      if (content.media.heroImageUrl != null) content.media.heroImageUrl!,
      if (content.media.videoUrl != null) content.media.videoUrl!,
      if (content.media.videoThumbnailUrl != null) content.media.videoThumbnailUrl!,
      if (content.media.audioGuideUrl != null) content.media.audioGuideUrl!,
      ...content.media.galleryUrls,
    ];
    for (final url in urls) {
      await _cacheMedia(url);
    }
    await _enforceMediaLimit();
  }

  Future<void> syncPendingScans() async {
    if (_isSyncing) return;
    final box = Hive.box('pending_scans');
    if (box.isEmpty) return;

    _isSyncing = true;
    final keys = box.keys.toList();

    for (var key in keys) {
      final scan = box.get(key) as Map?;
      if (scan == null) continue;

      try {
        await _apiService.claimVisit(
          qrPayload: scan['qrPayload'],
          latitude: scan['latitude'],
          longitude: scan['longitude'],
        );
        // On success, remove from queue
        await box.delete(key);
      } catch (e) {
        // If there's an error (e.g. still offline or server error), keep it for later backoff
        // Exponential backoff logic omitted for brevity in UI layer, but could be added heavily here
        break; 
      }
    }
    _isSyncing = false;
  }

  // Rough approximation of cache size enforcement (e.g., max 1000 items)
  void _enforceCacheSize(Box box) {
    if (box.length > 1000) {
      final keysToRemove = box.keys.take(box.length - 1000);
      box.deleteAll(keysToRemove);
    }
  }

  Future<void> _saveContent(LandmarkContentModel content) async {
    final box = Hive.box('landmark_contents');
    await box.put(content.landmarkId, jsonEncode(content.toJson()));
  }

  Future<String?> cachedPath(String url) async {
    return Hive.box('media_cache').get(url) as String?;
  }

  Future<void> _cacheMedia(String url) async {
    final mediaBox = Hive.box('media_cache');
    if (mediaBox.containsKey(url)) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${dir.path}/media_cache');
      if (!await mediaDir.exists()) await mediaDir.create(recursive: true);
      final uri = Uri.parse(url);
      final fileName = '${DateTime.now().microsecondsSinceEpoch}_${uri.pathSegments.isEmpty ? 'media' : uri.pathSegments.last}';
      final path = '${mediaDir.path}/$fileName';
      await Dio().download(url, path);
      await mediaBox.put(url, path);
    } catch (_) {
      // Leave uncached media as placeholders in offline mode.
    }
  }

  Future<void> _enforceMediaLimit() async {
    final mediaBox = Hive.box('media_cache');
    final entries = mediaBox.toMap().entries.toList();
    var total = 0;
    for (final entry in entries) {
      final file = File(entry.value as String);
      if (await file.exists()) total += await file.length();
    }
    const limit = 500 * 1024 * 1024;
    for (final entry in entries) {
      if (total <= limit) break;
      final file = File(entry.value as String);
      if (await file.exists()) {
        total -= await file.length();
        await file.delete();
      }
      await mediaBox.delete(entry.key);
    }
  }
}
