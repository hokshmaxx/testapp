import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@singleton
class NotificationService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseFirestore _firestore;
  static const String _fcmUrl = 'https://fcm.googleapis.com/v1/projects/testapp-80649/messages:send';
  static const String _serverKey = 'AIzaSyCzgehQEuXcsQefI0KsXcBhhnYcWOa_bMc'; // Get this from Firebase Console

  NotificationService(
    this._messaging,
    this._localNotifications,
    this._firestore,
  ) {
    tz.initializeTimeZones();
  }

  Future<void> initialize() async {
    // Request permission for notifications
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> scheduleTaskNotification({
    required String taskId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.inMinutes <= 30 && difference.isNegative == false) {
      await _localNotifications.zonedSchedule(
        taskId.hashCode,
        'Task Due Soon',
        '$title is due in ${difference.inMinutes} minutes',
        tz.TZDateTime.from(dueDate, tz.local).subtract(const Duration(minutes: 30)),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelTaskNotification(String taskId) async {
    await _localNotifications.cancel(taskId.hashCode);
  }

  Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  Future<void> sendTaskStateChangeNotification({
    required String taskId,
    required String title,
    required String newStatus,
    required String userId,
  }) async {
    try {
      // Get all users except the current user
      final usersSnapshot = await _firestore.collection('users').get();
      final tokens = <String>[];

      for (var doc in usersSnapshot.docs) {
        if (doc.id != userId) {
          final token = doc.data()['fcmToken'] as String?;
          if (token != null) {
            tokens.add(token);
          }
        }
      }

      if (tokens.isEmpty) return;

      // Prepare the FCM message
      final message = {
        'registration_ids': tokens,
        'notification': {
          'title': 'Task Status Updated',
          'body': '$title status changed to $newStatus',
        },
        'data': {
          'taskId': taskId,
          'type': 'task_status_change',
        },
      };

      // Send the FCM notification
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_serverKey}',
        },
        body: jsonEncode(message),
      );

      print("nnnnnnnnn${response.body}");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Handle invalid tokens
        if (responseData['failure'] > 0) {
          final results = responseData['results'] as List;
          final invalidTokens = <String>[];
          
          for (var i = 0; i < results.length; i++) {
            if (results[i]['error'] != null) {
              invalidTokens.add(tokens[i]);
            }
          }

          // Remove invalid tokens from users collection
          if (invalidTokens.isNotEmpty) {
            final batch = _firestore.batch();
            for (var doc in usersSnapshot.docs) {
              final userData = doc.data();
              if (userData['fcmToken'] != null && 
                  invalidTokens.contains(userData['fcmToken'])) {
                batch.update(doc.reference, {'fcmToken': null});
              }
            }
            await batch.commit();
          }
        }
      } else {
        print('Error sending FCM notification: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending task state change notification: $e');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Handling background message: ${message.messageId}');
}

void _handleForegroundMessage(RemoteMessage message) async {
  // Handle foreground messages
  print('Handling foreground message: ${message.messageId}');
  if (message.notification != null) {
    // Show local notification
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

void _handleMessageOpenedApp(RemoteMessage message) {
  // Handle notification tap
  print('Handling message opened app: ${message.messageId}');
} 