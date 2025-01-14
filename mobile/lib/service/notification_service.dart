import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void>  onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {}
  static Future<void>  onDidReceiveBackgroundNotificationResponse(NotificationResponse notificationResponse) async {}

  static void init(){
    // android
    const AndroidInitializationSettings initializationSettingsAndroid =  AndroidInitializationSettings('@mipmap/waznet_icon');
    // ios
    const DarwinInitializationSettings initializationSettingsDarwin =  DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse
    );
  }

  static Future<void> showNotification(String title, String body) async {
    NotificationDetails details = const NotificationDetails(
      android: AndroidNotificationDetails("channel_id", "channel_name", importance: Importance.high, priority: Priority.high),
      iOS: DarwinNotificationDetails()
    );

    await flutterLocalNotificationsPlugin.show( 0, title, body, details);
  }
}