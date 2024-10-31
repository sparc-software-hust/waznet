import 'dart:io';

import 'package:cecr_unwomen/http.dart';
import 'package:cecr_unwomen/utils.dart';

class FirebaseRepository {
   static Future<void> setupFirebaseToken() async {
    final String? fcmToken = await Utils.getFirebaseToken();
    if (fcmToken == null) return;
    await uploadFirebaseToken(fcmToken);
  }

  static Future<void> uploadFirebaseToken(String token) async {
    const String url = "/user/add_firebase_token";
    final Map data = {
      "firebase_token": token,
      "platform": Platform.isAndroid ? "android" : "ios",
    };
    await dioConfigInterceptor.post(url, data: data);
  }
}