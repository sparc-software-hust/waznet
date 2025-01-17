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

  static Future<void> logout() async {
    const String url = "/user/logout";
    await dioConfigInterceptor.post(url, data: {});
  }

  static Future<Map> deleteUser() async {
    const String url = "/user/delete_user";
    final Response response = await dioConfigInterceptor.post(url);
    return response.data;
  }
}