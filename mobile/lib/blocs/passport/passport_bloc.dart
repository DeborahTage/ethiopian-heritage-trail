import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import 'passport_state.dart';

class PassportBloc extends Bloc<PassportEvent, PassportState> {
  final ApiService _apiService;

  PassportBloc(this._apiService) : super(PassportLoading()) {
    on<LoadPassport>(_onLoad);
    on<RefreshPassport>(_onLoad);
  }

  Future<void> _onLoad(PassportEvent event, Emitter<PassportState> emit) async {
    emit(PassportLoading());
    try {
      final passport = await _apiService.getPassport();
      emit(PassportLoaded(passport));
    } catch (e) {
      emit(PassportError('Failed to sync passport'));
    }
  }
}
