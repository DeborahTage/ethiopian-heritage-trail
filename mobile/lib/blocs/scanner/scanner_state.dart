import 'package:equatable/equatable.dart';
import '../../models/models.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {}

class ScannerReady extends ScannerState {
  final bool isGpsEnabled;
  final int _token;

  ScannerReady({this.isGpsEnabled = true}) : _token = DateTime.now().microsecondsSinceEpoch;

  @override
  List<Object?> get props => [isGpsEnabled, _token];
}

class ScannerProcessing extends ScannerState {
  final String message;

  const ScannerProcessing({this.message = 'Processing...'});

  @override
  List<Object?> get props => [message];
}

class ScannerSuccess extends ScannerState {
  final ScanResponse response;

  const ScannerSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ScannerFailure extends ScannerState {
  final String error;

  const ScannerFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ScannerGpsDenied extends ScannerState {}
