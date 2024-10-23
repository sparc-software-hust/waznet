import 'package:cecr_unwomen/utils.dart';
import 'package:dio/dio.dart';

class AuthController {
  // static Future<void> renewAccessToken(String refreshToken) async {
  //   const String url = "/auth/renew_access_token";
  //   await dioConfigInterceptor.post(url, data: data);
  // }

  static Future<Map> login(String phoneNumber, String password) async {
    const String url = "/user/login";
    final Map data = {
      "phone_number": phoneNumber,
      "password": password
    };
    final dioWithoutInterceptor = Dio()..options.baseUrl = Utils.apiUrl;
    final Response response = await dioWithoutInterceptor.post(url, data: data);
    final bool isSuccess = response.data["success"];
    if (isSuccess) {
      await Utils.saveTokenDataIntoPrefs(response.data["data"]);
      return {"success": true};
    } else {
      return response.data;
    }
  }
}