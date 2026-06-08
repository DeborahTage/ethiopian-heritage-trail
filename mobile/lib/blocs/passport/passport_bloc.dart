import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/api_service.dart';
import 'passport_state.dart';
import 'dart:convert';

class PassportBloc extends Bloc<PassportEvent, PassportState> {
  final ApiService _apiService;

  PassportBloc(this._apiService) : super(PassportLoading()) {
    on<LoadPassport>(_onLoad);
    on<RefreshPassport>(_onRefresh);
  }

  Future<void> _onLoad(PassportEvent event, Emitter<PassportState> emit) async {
    emit(PassportLoading());
    try {
      final passport = await _apiService.getPassport();
      emit(PassportLoaded(passport));
    } catch (e) {
      // Try to use cache as fallback
      try {
        final box = Hive.box('cached_rewards');
        final cached = box.get('passport_data');
        if (cached != null) {
          final passport = PassportModel.fromJson(jsonDecode(cached));
          emit(PassportLoaded(passport));
          return;
        }
      } catch (_) {}
      emit(PassportError('Failed to load passport'));
    }
  }

  Future<void> _onRefresh(PassportEvent event, Emitter<PassportState> emit) async {
    emit(PassportLoading());
    try {
      // Clear old cache before fetching fresh data
      final box = Hive.box('cached_rewards');
      await box.delete('passport_data');
      
      final passport = await _apiService.getPassport();
      emit(PassportLoaded(passport));
    } catch (e) {
      emit(PassportError('Failed to refresh passport'));
    }
  }
}
