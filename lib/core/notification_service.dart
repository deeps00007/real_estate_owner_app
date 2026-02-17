import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
            // Handle notification tap
          },
    );

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        _showNotification(message);
      }
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get token
    String? token = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $token");

    // Check if app was opened from a notification
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      // Handle navigation or logic based on initialMessage
      debugPrint("App opened from notification: ${initialMessage.messageId}");
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("A new onMessageOpenedApp event was published!");
      // Handle navigation
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final imageUrl =
        message.data['imageUrl'] ?? message.notification?.android?.imageUrl;

    AndroidNotificationDetails? androidDetails;

    if (imageUrl != null) {
      try {
        final http.Response response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final BigPictureStyleInformation bigPictureStyleInformation =
              BigPictureStyleInformation(
                ByteArrayAndroidBitmap(response.bodyBytes),
                largeIcon: ByteArrayAndroidBitmap(response.bodyBytes),
                contentTitle: message.notification?.title,
                summaryText: message.notification?.body,
              );

          androidDetails = AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: bigPictureStyleInformation,
          );
        }
      } catch (e) {
        debugPrint('Error downloading illustration: $e');
      }
    }

    // Fallback if no image or download failed
    androidDetails ??= const AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: message.notification.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: notificationDetails,
    );
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<String> sendNotification({
    String? receiverId, // Optional, if null implies broadcast
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    try {
      final url = Uri.parse(
        'https://real-estate-notifications.onrender.com/send-notification',
      );

      final Map<String, dynamic> payload = {'title': title, 'body': body};

      if (imageUrl != null) {
        payload['imageUrl'] = imageUrl;
      }

      if (receiverId != null) {
        payload['userId'] = receiverId;
      }
      // If receiverId is null, we assume the backend handles it as a broadcast
      // or we might need a specific flag like 'topic': 'all'.
      // For now, sending without userId implies broadcast based on user description.

      debugPrint('Sending notification payload: $payload to $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Notification sent successfully: ${response.body}');
        return 'Success: ${response.body}';
      } else {
        return 'Failed: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return 'Error: $e';
    }
  }
}
