import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import 'package_event.dart';
import 'package_state.dart';

class PackageBloc extends Bloc<PackageEvent, PackageState> {
  final ApiService _apiService;

  PackageBloc(this._apiService) : super(PackageInitial()) {
    on<LoadPackage>((event, emit) async {
      emit(PackageLoading());
      try {
        final package = await _apiService.getLandmarkPackage(event.landmarkId);
        if (package == null) {
          emit(PackageNotFound());
        } else {
          emit(PackageLoaded(package));
        }
      } catch (e) {
        emit(PackageError(message: 'Failed to load package: ${e.toString()}'));
      }
    });
  }
}
