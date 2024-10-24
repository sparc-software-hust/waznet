
import 'dart:convert';

import 'package:cecr_unwomen/utils.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static Future<Map> login(String phoneNumber, String password) async {
    const String url = "/user/login";
    final Map data = {
      "phone_number": phoneNumber,
      "password": password
    };
    final dioWithoutInterceptor = Dio()..options.baseUrl = Utils.apiUrl;
    final Response response = await dioWithoutInterceptor.post(url, data: data);
    return response.data;
  }

  static Future<void> logoutNoCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveTokenDataIntoPrefs(Map data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String accessToken = data["access_token"] ?? "";
    final String refreshToken = data["refresh_token"] ?? "";
    final int accessTokenExp = data["access_exp"] ?? 0;
    await prefs.setString("access_token", accessToken);
    await prefs.setString("refresh_token", refreshToken);
    await prefs.setInt("access_exp", accessTokenExp);
    await prefs.setBool("logged_in", true);
  }

  static Future<List> getTokenDataFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString("access_token") ?? "";
    final String refreshToken = prefs.getString("refresh_token") ?? "";
    final int accessTokenExp = prefs.getInt("access_exp") ?? 0;
    return [accessToken, refreshToken, accessTokenExp];
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

  static Future<bool> checkUserLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getBool("logged_in") ?? false;
    return loggedIn; 
  }
}
