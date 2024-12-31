
import 'dart:async';

import 'package:cecr_unwomen/features/authentication/authentication.dart';
import 'package:cecr_unwomen/features/authentication/repository/authentication_api.dart';
import 'package:cecr_unwomen/features/user/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static final _controller = StreamController<AuthenticationStatus>();
  static Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    // yield AuthenticationStatus.unauthorized;
    yield* _controller.stream;
  }
  static void dispose() => _controller.close();

  static Future<bool> checkPassword(String phoneNumber, String password) async {
    try {
      final Map res = await AuthenticationApi.login(phoneNumber, password);
      final bool isLoginSuccess = res["success"];
      if (isLoginSuccess) {
        await AuthRepository.saveTokenDataIntoPrefs(res["data"]);
        await UserRepository.saveUserDataIntoPrefs(res["data"]["user"]);
      }
      return isLoginSuccess;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> login(String phoneNumber, String password) async {
    try {
      final Map res = await AuthenticationApi.login(phoneNumber, password);
      final bool isLoginSuccess = res["success"];
      if (isLoginSuccess) {
        await AuthRepository.saveTokenDataIntoPrefs(res["data"]);
        await UserRepository.saveUserDataIntoPrefs(res["data"]["user"]);
        _controller.add(AuthenticationStatus.authorized);
        return true;
      } else {
        _controller.add(AuthenticationStatus.unauthorized);
        return false;
      }
    } catch (e) {
      print('gndkjf:$e');
      _controller.add(AuthenticationStatus.error);
      return false;
    }
  }

  static Future<Map> register(Map data) async {
    try {
      final Map res = await AuthenticationApi.register(data);
      final bool isLoginSuccess = res["success"];
      if (isLoginSuccess) {
        await AuthRepository.saveTokenDataIntoPrefs(res["data"]);
        await UserRepository.saveUserDataIntoPrefs(res["data"]["user"]);
        _controller.add(AuthenticationStatus.authorized);
      } else {
        _controller.add(AuthenticationStatus.unauthorized);
      }
      return res;
    } catch (e) {
      print('gndkjf:$e');
      _controller.add(AuthenticationStatus.error);
      return {"success": false};
    }
  }

  static Future<void> logout() async {
    await AuthRepository.logoutNoCredentials();
    // await AuthenticationApi.logout(userId);
    _controller.add(AuthenticationStatus.unauthorized);
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


  static Future<bool> checkUserLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getBool("logged_in") ?? false;
    return loggedIn; 
  }
}
