import 'package:firebase_messaging/firebase_messaging.dart';

class Utils {
  static Future<String?> getFirebaseToken() async {
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    return fcmToken;
  }
  static String apiUrl = "http://192.168.1.200:4000/api";
}