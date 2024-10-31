import 'dart:convert';

import 'package:cecr_unwomen/features/user/repository/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static Future<void> getUserInfo(String userId) async {
    await UserApi.getUserInfo(userId);
  }

  static Future<void> saveUserDataIntoPrefs(Map data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userDataEncoded = jsonEncode(data);
    await prefs.setString("user", userDataEncoded);
  }

  static Future<Map?> getUserDataFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userDataEncoded = prefs.getString("user");
    if (userDataEncoded == null) return null;
    return jsonDecode(userDataEncoded);
  }
}