import 'dart:convert';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
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

  static Future<List<User>> getListContributedUser({required Map data, Function()? onError}) async {
    try {
      final Map res = await UserApi.getListContributedUsers(data: data, onError: onError);
      return (res["data"] as List).map((e) => User.fromJson(e)).toList();
    } 
    catch (e) {
      print(e);
      onError?.call();
      return [];
    }
  }
}