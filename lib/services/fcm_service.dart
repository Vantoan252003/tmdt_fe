import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'fcm_token_service.dart';
import 'auth_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // Track if notifications should be suppressed (e.g., when in chat room)
  bool _suppressNotifications = false;
  String? _activeConversationId;

  Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get the token and register with backend if logged in
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        await FCMTokenService.registerToken(token);
      }
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('FCM Token refreshed: $newToken');
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        await FCMTokenService.registerToken(newToken);
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      // Check if this is a chat message for the active conversation
      if (_suppressNotifications && message.data['conversationId'] == _activeConversationId) {
        print('🔇 Suppressing notification - user is in chat room: $_activeConversationId');
        return;
      }

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Navigate to notification screen or handle
    });
  }

  Future<void> registerCurrentToken() async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await FCMTokenService.registerToken(token);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  /// Deactivate current FCM token
  Future<void> deactivateCurrentToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await FCMTokenService.deactivateToken(token);
    }
  }

  /// Suppress notifications for a specific conversation (when user is in chat room)
  void suppressNotificationsForConversation(String conversationId) {
    _suppressNotifications = true;
    _activeConversationId = conversationId;
    print('🔇 Notifications suppressed for conversation: $conversationId');
  }

  /// Resume notifications (when user leaves chat room)
  void resumeNotifications() {
    _suppressNotifications = false;
    _activeConversationId = null;
    print('🔔 Notifications resumed');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}