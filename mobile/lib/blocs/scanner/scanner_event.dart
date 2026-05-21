import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeScanner extends ScannerEvent {}

class QrCodeDetected extends ScannerEvent {
  final String qrPayload;

  const QrCodeDetected(this.qrPayload);

  @override
  List<Object?> get props => [qrPayload];
}

class SubmitScan extends ScannerEvent {
  final String qrPayload;
  final double latitude;
  final double longitude;

  const SubmitScan({
    required this.qrPayload,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [qrPayload, latitude, longitude];
}

class DismissResult extends ScannerEvent {}
