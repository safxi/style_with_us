import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../network/api_client.dart';
import '../router/app_router.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifs = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permission on iOS/Android
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    // Get current FCM Token
    final token = await _fcm.getToken();
    if (token != null) {
      await _sendTokenToBackend(token);
    }

    _fcm.onTokenRefresh.listen(_sendTokenToBackend);

    // Setup Local Notifications for Foreground display
    const AndroidInitializationSettings initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initIOS = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: initAndroid, iOS: initIOS);
    
    await _localNotifs.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        _localNotifs.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'style_with_us_channel', 
              'Important Notifications', 
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
          ),
          payload: message.data['route'], // payload can securely guide routing
        );
      }
    });

    // Listen to background/terminated taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data['route']);
    });
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final api = ApiClient();
      await api.postJson('/users/fcm-token', body: {'fcm_token': token});
    } catch (e) {
      // Intentionally swallow error if user is not logged in / 401
    }
  }

  void _handleNotificationTap(String? route) {
    if (route != null && rootNavigatorKey.currentContext != null) {
      rootNavigatorKey.currentContext!.go(route);
    }
  }
}
