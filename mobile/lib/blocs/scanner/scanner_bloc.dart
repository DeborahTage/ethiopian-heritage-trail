import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api_service.dart';
import '../../services/offline_sync_service.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final ApiService _apiService;
  final OfflineSyncService _offlineSyncService;

  ScannerBloc(this._apiService, this._offlineSyncService) : super(ScannerInitial()) {
    on<InitializeScanner>(_onInitializeScanner);
    on<QrCodeDetected>(_onQrCodeDetected);
    on<SubmitScan>(_onSubmitScan);
    on<DismissResult>(_onDismissResult);
  }

  Future<void> _onInitializeScanner(InitializeScanner event, Emitter<ScannerState> emit) async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        emit(ScannerGpsDenied());
        return;
      }
      emit(ScannerReady());
    } catch (_) {
      emit(ScannerReady(isGpsEnabled: false));
    }
  }

  Future<void> _onQrCodeDetected(QrCodeDetected event, Emitter<ScannerState> emit) async {
    emit(const ScannerProcessing(message: 'Verifying location...'));
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        emit(ScannerGpsDenied());
        return;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        emit(const ScannerFailure('Could not determine location. Ensure GPS is enabled and try outdoors.'));
        return;
      }

      add(SubmitScan(qrPayload: event.qrPayload, latitude: pos.latitude, longitude: pos.longitude));
    } catch (e) {
      emit(const ScannerFailure('Could not determine location. Ensure GPS is enabled.'));
    }
  }

  Future<void> _onSubmitScan(SubmitScan event, Emitter<ScannerState> emit) async {
    emit(const ScannerProcessing(message: 'Validating scan...'));
    try {
      final response = await _apiService.claimVisit(
        qrPayload: event.qrPayload,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      await _offlineSyncService.cacheScanResponse(response);
      emit(ScannerSuccess(response));
    } on DioException catch (e) {
      // Only treat as offline if it's a genuine network/connection error
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        await _offlineSyncService.queueScan(event.qrPayload, event.latitude, event.longitude);
        emit(const ScannerFailure('You are offline. Scan saved and will sync when connection is restored!'));
      } else {
        // Server responded — show the actual error message
        final serverMsg = e.response?.data?['message'] as String?;
        emit(ScannerFailure(serverMsg ?? e.message ?? 'Scan failed. Please try again.'));
      }
    } catch (e) {
      emit(ScannerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onDismissResult(DismissResult event, Emitter<ScannerState> emit) {
    emit(ScannerReady());
  }
}
