import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/models.dart';
import '../utils/app_config.dart';
import 'dart:convert';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _tokenKey   = 'access_token';
  static const _refreshKey = 'refresh_token';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConfig.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeoutMs),
      headers: {'Content-Type': 'application/json'},
    ));
    debugPrint('ApiService baseUrl: ${AppConfig.baseUrl}');

    // Request interceptor — attach Bearer token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException err, handler) async {
        if (err.response?.statusCode == 401) {
          // Try token refresh
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final token = await _storage.read(key: _tokenKey);
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            final cloned = await _dio.fetch(err.requestOptions);
            return handler.resolve(cloned);
          }
        }
        handler.next(err);
      },
    ));
  }

  // ─── Auth ──────────────────────────────────────────────────────────[...]

  Future<AuthResponse> register(String email, String password, String displayName) async {
    final res = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'displayName': displayName,
    });
    final auth = AuthResponse.fromJson(res.data as Map<String, dynamic>);
    await _saveTokens(auth.accessToken, auth.refreshToken);
    return auth;
  }

  Future<AuthResponse> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final auth = AuthResponse.fromJson(res.data as Map<String, dynamic>);
    await _saveTokens(auth.accessToken, auth.refreshToken);
    return auth;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // ─── Landmarks ─────────────────────────────────────────────────────────[...]

  Future<List<LandmarkModel>> getLandmarks() async {
    try {
      final res = await _dio.get('/landmarks');
      final data = (res.data as List).map((j) => LandmarkModel.fromJson(j as Map<String, dynamic>)).toList();
      final box = Hive.box('cached_landmarks');
      await box.put('all_landmarks', jsonEncode(res.data));
      return data;
    } catch (e) {
      final box = Hive.box('cached_landmarks');
      final cached = box.get('all_landmarks');
      if (cached != null) {
        return (jsonDecode(cached) as List).map((j) => LandmarkModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to load landmarks, no cache available');
    }
  }

  Future<LandmarkModel> getLandmark(String id) async {
    final res = await _dio.get('/landmarks/$id');
    return LandmarkModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<LandmarkContentModel> getLandmarkContent(String landmarkId) async {
    final contentBox = Hive.box('landmark_contents');
    final connectivity = await Connectivity().checkConnectivity();
    final offline = connectivity.every((result) => result == ConnectivityResult.none);
    if (offline) {
      final cached = contentBox.get(landmarkId);
      if (cached != null) {
        return LandmarkContentModel.fromJson(jsonDecode(cached as String) as Map<String, dynamic>);
      }
      throw Exception('Content is not cached for offline viewing');
    }

    try {
      final res = await _dio.get('/landmarks/$landmarkId/content');
      await contentBox.put(landmarkId, jsonEncode(res.data));
      return LandmarkContentModel.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      final cached = contentBox.get(landmarkId);
      if (cached != null) {
        return LandmarkContentModel.fromJson(jsonDecode(cached as String) as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  Future<AdventurePackageModel?> getLandmarkPackage(String landmarkId) async {
    final cacheBox = Hive.box('landmark_contents');
    final connectivity = await Connectivity().checkConnectivity();
    final offline = connectivity.every((result) => result == ConnectivityResult.none);
    
    try {
      final res = await _dio.get('/landmarks/$landmarkId/package');
      if (res.statusCode == 404 || res.data == null) {
        return null; // Site has no package
      }
      final package = AdventurePackageModel.fromJson(res.data as Map<String, dynamic>);
      await cacheBox.put('package_$landmarkId', jsonEncode(res.data));
      return package;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No package for this site
      }
      // Try to use cached data if available
      if (offline) {
        final cached = cacheBox.get('package_$landmarkId');
        if (cached != null) {
          return AdventurePackageModel.fromJson(jsonDecode(cached as String) as Map<String, dynamic>);
        }
      }
      rethrow;
    } catch (_) {
      // Try cache fallback
      final cached = cacheBox.get('package_$landmarkId');
      if (cached != null) {
        return AdventurePackageModel.fromJson(jsonDecode(cached as String) as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  // ─── Visit / Scan ───────────────────────────────────────────────────────[...]

  Future<ScanResponse> claimVisit({
    required String qrPayload,
    required double latitude,
    required double longitude,
    String? deviceId,
  }) async {
    final res = await _dio.post('/visits/claim', data: {
      'qrPayload': qrPayload,
      'latitude':  latitude,
      'longitude': longitude,
      if (deviceId != null) 'deviceId': deviceId,
    });
    return ScanResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // ─── Passport ─────────────────────────────────────────────────────────[...]

  Future<PassportModel> getPassport() async {
    try {
      final res = await _dio.get('/passport');
      final data = PassportModel.fromJson(res.data as Map<String, dynamic>);
      final box = Hive.box('cached_rewards');
      await box.put('passport_data', jsonEncode(res.data));
      return data;
    } catch (e) {
      final box = Hive.box('cached_rewards');
      final cached = box.get('passport_data');
      if (cached != null) {
        return PassportModel.fromJson(jsonDecode(cached));
      }
      throw Exception('Failed to load passport, no cache available');
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────[...]

  Future<void> _saveTokens(String access, String refresh) async {
    await _storage.write(key: _tokenKey,   value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<bool> _tryRefresh() async {
    try {
      final refresh = await _storage.read(key: _refreshKey);
      if (refresh == null) return false;
      final res = await Dio().post(
        '${AppConfig.baseUrl}/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final auth = AuthResponse.fromJson(res.data as Map<String, dynamic>);
      await _saveTokens(auth.accessToken, auth.refreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    return await _storage.read(key: _tokenKey) != null;
  }
}
