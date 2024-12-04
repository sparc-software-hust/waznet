import 'package:cecr_unwomen/http.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:dio/dio.dart';

class AuthenticationApi {
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

  static Future<Map> register(data) async {
    const String url = "/user/register";
    final dioWithoutInterceptor = Dio()..options.baseUrl = Utils.apiUrl;
    final Response response = await dioWithoutInterceptor.post(url, data: data);
    return response.data;
  }

  static Future<void> logout(String userId) async {
    const String url = "/user/logout";
    await dioConfigInterceptor.post(url, data: {"user_id": userId});
  }
}