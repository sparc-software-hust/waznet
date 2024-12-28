import 'dart:convert';

import 'package:cecr_unwomen/http.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:dio/dio.dart';

class UserApi {
  static Future<Map> getUserInfo(String userId) async {
    const String url = "/user/get_info";
    final Response res = await dioConfigInterceptor.post(url, data: {"user_id": "f47cc61f-6e66-4822-835a-e0ed2485997e"});
    return res.data;
  }

  static void updateInfo(Map data) async {
    print("payloadt: $data");
    try {
      const String url = "/user/update_info";
      final Response res = await dioConfigInterceptor.post(url, data: jsonEncode(data));
      print(res.data);
    } catch (e) {
      print("errr update info");
    }
  }
}