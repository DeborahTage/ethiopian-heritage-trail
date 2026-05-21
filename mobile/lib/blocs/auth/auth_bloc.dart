import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;

  AuthBloc(this._apiService) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      if (isLoggedIn) {
        // Technically, you might want to fetch user profile here if the JWT is still valid.
        // For now, we trust the presense and ApiService interceptor refresh to handle it,
        // so we emit authenticated with a dummy authResponse or we would fetch me().
        // For structural completeness without a /me endpoint, we consider them authenticated.
        // Note: AuthAuthenticated normally needs AuthResponse. For auto-login we might just
        // rely on a check or retrieve stored user. We will implement it minimally.
        emit(const AuthAuthenticated(null));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.login(event.email, event.password);
      emit(AuthAuthenticated(response));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.register(event.email, event.password, event.username);
      emit(AuthAuthenticated(response));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _apiService.logout();
    emit(AuthUnauthenticated());
  }

  String _parseError(Object e) {
    if (e is DioException) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          return data['message'] as String? ??
              data['error'] as String? ??
              data['detail'] as String? ??
              e.message ??
              'Request failed';
        }
        return e.response?.statusMessage ?? e.message ?? 'Request failed';
      }
      return e.message ?? 'Network error or invalid credentials';
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}
