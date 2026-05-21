import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import 'landmarks_state.dart';

class LandmarksBloc extends Bloc<LandmarksEvent, LandmarksState> {
  final ApiService _apiService;

  LandmarksBloc(this._apiService) : super(LandmarksLoading()) {
    on<LoadLandmarks>((event, emit) async {
      emit(LandmarksLoading());
      try {
        final landmarks = await _apiService.getLandmarks();
        emit(LandmarksLoaded(landmarks));
      } catch (e) {
        emit(LandmarksError('Failed to load landmarks'));
      }
    });
  }
}
