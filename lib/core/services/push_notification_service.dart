import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_constants.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are handled by Firebase; no-op here for now.
}

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'komo_notifications',
    'KOMO Notifications',
    description: 'Task, project, and collaboration notifications',
    importance: Importance.high,
  );

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _localNotifications.initialize(initSettings);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    _messaging.onTokenRefresh.listen((token) async {
      await _syncToken(token);
    });

    await setPushEnabled(true);
    _isInitialized = true;
  }

  static Future<void> setPushEnabled(bool enabled) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final usersCol = FirebaseFirestore.instance.collection(FirebaseConstants.usersCollection);

    if (!enabled) {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await usersCol.doc(user.uid).set(
          {
            'fcmTokens': FieldValue.arrayRemove([token]),
            'pushNotificationsEnabled': false,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      await _messaging.deleteToken();
      return;
    }

    final permission = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (permission.authorizationStatus == AuthorizationStatus.denied) {
      await usersCol.doc(user.uid).set(
        {
          'pushNotificationsEnabled': false,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return;
    }

    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;

    await _syncToken(token);
    await usersCol.doc(user.uid).set(
      {
        'pushNotificationsEnabled': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> _syncToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || token.isEmpty) return;

    await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final android = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const ios = DarwinNotificationDetails();

    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'KOMO',
      notification.body ?? '',
      NotificationDetails(android: android, iOS: ios),
    );

    if (kDebugMode) {
      debugPrint('Foreground notification shown: ${notification.title}');
    }
  }
}
