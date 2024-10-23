import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static Future<String?> getFirebaseToken() async {
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    return fcmToken;
  }
  static String apiUrl = "http://192.168.1.68:4000/api";

  static saveTokenDataIntoPrefs(Map data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String accessToken = data["access_token"] ?? "";
    final String refreshToken = data["refresh_token"] ?? "";
    final int accessTokenExp = data["access_exp"] ?? 0;
    await prefs.setString("access_token", accessToken);
    await prefs.setString("refresh_token", refreshToken);
    await prefs.setInt("access_exp", accessTokenExp);
    print('save successfully');
  }
}