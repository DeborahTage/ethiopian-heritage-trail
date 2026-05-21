import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/landmarks/landmarks_bloc.dart';
import 'blocs/landmarks/landmarks_state.dart';
import 'blocs/passport/passport_bloc.dart';
import 'blocs/passport/passport_state.dart';
import 'blocs/scanner/scanner_bloc.dart';
import 'services/api_service.dart';
import 'services/offline_sync_service.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'utils/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('pending_scans');
  await Hive.openBox('cached_landmarks');
  await Hive.openBox('cached_rewards');
  await Hive.openBox('landmark_contents');
  await Hive.openBox('media_cache');
  
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(HeritageTrailApp(notificationService: notificationService));
}

class HeritageTrailApp extends StatefulWidget {
  final NotificationService notificationService;
  const HeritageTrailApp({super.key, required this.notificationService});

  @override
  State<HeritageTrailApp> createState() => _HeritageTrailAppState();
}

class _HeritageTrailAppState extends State<HeritageTrailApp> {
  late final ApiService _apiService;
  late final OfflineSyncService _offlineSyncService;
  late final AuthBloc _authBloc;
  late final LandmarksBloc _landmarksBloc;
  late final PassportBloc _passportBloc;
  late final ScannerBloc _scannerBloc;
  late final router;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _offlineSyncService = OfflineSyncService(_apiService);
    widget.notificationService.startGeofenceMonitoring(_apiService);
    _authBloc = AuthBloc(_apiService)..add(AppStarted());
    _landmarksBloc = LandmarksBloc(_apiService);
    _passportBloc = PassportBloc(_apiService);
    _scannerBloc = ScannerBloc(_apiService, _offlineSyncService);
    router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _offlineSyncService.dispose();
    _authBloc.close();
    _landmarksBloc.close();
    _passportBloc.close();
    _scannerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<LandmarksBloc>.value(value: _landmarksBloc),
        BlocProvider<PassportBloc>.value(value: _passportBloc),
        BlocProvider<ScannerBloc>.value(value: _scannerBloc),
      ],
      child: MaterialApp.router(
        title: 'Ethiopian Heritage Trail',
        theme: AppTheme.dark,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
