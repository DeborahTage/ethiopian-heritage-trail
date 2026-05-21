import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  FirebaseMessaging? _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _fcm = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await _requestPermission();
      
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });
    } catch (e) {
      debugPrint("Firebase initialization failed: $e");
    }

    await _initLocalNotifications();
  }

  Future<void> _requestPermission() async {
    if (_fcm == null) return;
    NotificationSettings settings = await _fcm!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted Fcm permission');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInitSettings, iOS: iosInitSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse res) {
        // Handle navigation when tapped
        if (res.payload != null) {
          debugPrint('Notification payload: ${res.payload}');
          // In real app, push to correct router path
        }
      },
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const androidDetails = AndroidNotificationDetails(
        'heritage_channel',
        'Heritage Notifications',
        channelDescription: 'Notifications for nearby landmarks',
        importance: Importance.max,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: message.data['route'],
      );
    }
  }

  void startGeofenceMonitoring(ApiService apiService) {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, distanceFilter: 100),
    ).listen((Position position) async {
      try {
        final loggedIn = await apiService.isLoggedIn();
        if (!loggedIn) return;
        final landmarks = await apiService.getLandmarks();
        for (var l in landmarks) {
          if (!l.visited) {
            final distance = Geolocator.distanceBetween(
                position.latitude, position.longitude, l.latitude, l.longitude);
            if (distance < l.gpsRadiusMeters) {
              await _localNotifications.show(
                l.id.hashCode,
                'You are near ${l.name}!',
                'Scan the QR code to claim your reward!',
                const NotificationDetails(
                  android: AndroidNotificationDetails('heritage_channel', 'Heritage Notifications',
                      importance: Importance.max),
                  iOS: DarwinNotificationDetails(),
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Geofence error: $e');
      }
    });
  }
}
