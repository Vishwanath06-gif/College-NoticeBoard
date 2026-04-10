import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Function(String?)? onTokenRefresh;
  Function(RemoteMessage)? onMessageReceived;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (kIsWeb) {
        await _requestPermission();
        await _getToken();
        _setupMessageHandlers();
      } else {
        await _requestPermission();
        await _getToken();
        _setupMessageHandlers();
      }
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('FCM initialization failed (non-critical): $e');
      }
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('Permission status: ${settings.authorizationStatus}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Permission request failed: $e');
      }
    }
  }

  Future<String?> _getToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get FCM token: $e');
      }
      return null;
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message received: ${message.notification?.title}');
      }
      onMessageReceived?.call(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message opened app: ${message.notification?.title}');
      }
      onMessageReceived?.call(message);
    });

    _messaging.onTokenRefresh.listen((token) {
      if (kDebugMode) {
        print('Token refreshed: $token');
      }
      onTokenRefresh?.call(token);
    });
  }

  Future<RemoteMessage?> getInitialMessage() async {
    try {
      return await _messaging.getInitialMessage();
    } catch (e) {
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Subscribe failed: $e');
      }
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unsubscribe failed: $e');
      }
    }
  }

  Future<void> subscribeToDepartment(String department) async {
    await subscribeToTopic(
      'dept_${department.toLowerCase().replaceAll(' ', '_')}',
    );
  }

  Future<void> subscribeToYear(String year) async {
    await subscribeToTopic('year_${year.toLowerCase().replaceAll(' ', '_')}');
  }

  Future<void> subscribeToAll() async {
    await subscribeToTopic('all_notices');
  }

  Future<void> subscribeToCategory(String category) async {
    await subscribeToTopic('cat_${category.toLowerCase()}');
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message received: ${message.notification?.title}');
  }
}
