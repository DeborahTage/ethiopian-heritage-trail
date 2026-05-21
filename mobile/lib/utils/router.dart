import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/landmarks/landmarks_screen.dart';
import '../screens/landmarks/landmark_detail_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/passport/passport_screen.dart';
import '../screens/passport/reward_detail_screen.dart';
import '../widgets/main_shell.dart';
import '../models/models.dart';
import 'dart:async';

class RouterNotifier extends ChangeNotifier {
  final AuthBloc authBloc;
  late StreamSubscription _subscription;

  RouterNotifier(this.authBloc) {
    _subscription = authBloc.stream.listen((state) {
      if (state is AuthAuthenticated || state is AuthUnauthenticated) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthBloc authBloc) {
  final notifier = RouterNotifier(authBloc);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = authBloc.state;
      
      // If we are still initial or loading, do not redirect yet 
      // (or redirect to a splash screen if you have one).
      if (authState is AuthInitial || authState is AuthLoading) {
        return null; 
      }

      final isAuth = authState is AuthAuthenticated;
      final onAuthPage = state.matchedLocation.startsWith('/login') ||
                         state.matchedLocation.startsWith('/register');
                         
      if (!isAuth && !onAuthPage) return '/login';
      if (isAuth && onAuthPage) return '/landmarks';
      return null;
    },
    routes: [
      GoRoute(path: '/login',    builder: (ctx, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (ctx, _) => const RegisterScreen()),
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/landmarks',
            builder: (ctx, _) => const LandmarksScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (ctx, state) =>
                    LandmarkDetailScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(path: '/scan',     builder: (ctx, _) => const ScanScreen()),
          GoRoute(
            path: '/passport',
            builder: (ctx, _) => const PassportScreen(),
          ),
          GoRoute(
            path: '/reward/:name',
            builder: (ctx, state) {
              final modelStr = state.extra as RewardModel; // pass complete model via extra
              return RewardDetailScreen(reward: modelStr);
            },
          ),
        ],
      ),
    ],
  );
}
