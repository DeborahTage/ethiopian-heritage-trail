import 'package:equatable/equatable.dart';
import '../../models/models.dart';

// -- Events --
abstract class LandmarksEvent extends Equatable {
  const LandmarksEvent();
  @override
  List<Object?> get props => [];
}

class LoadLandmarks extends LandmarksEvent {}

// -- States --
abstract class LandmarksState extends Equatable {
  const LandmarksState();
  @override
  List<Object?> get props => [];
}

class LandmarksLoading extends LandmarksState {}

class LandmarksLoaded extends LandmarksState {
  final List<LandmarkModel> landmarks;
  const LandmarksLoaded(this.landmarks);
  @override
  List<Object?> get props => [landmarks];
}

class LandmarksError extends LandmarksState {
  final String error;
  const LandmarksError(this.error);
  @override
  List<Object?> get props => [error];
}
