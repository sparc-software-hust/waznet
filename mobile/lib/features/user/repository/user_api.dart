import 'dart:convert';

import 'package:cecr_unwomen/http.dart';
import 'package:dio/dio.dart';

class UserApi {
  static Future<Map> getUserInfo(String userId) async {
    const String url = "/user/get_info";
    final Response res = await dioConfigInterceptor.post(url, data: {"user_id": "f47cc61f-6e66-4822-835a-e0ed2485997e"});
    return res.data;
  }

  static Future<Map> updateInfo(Map data) async {
    const String url = "/user/update_info";
    final Response res = await dioConfigInterceptor.post(url, data: jsonEncode(data));
    return res.data["data"];
  }

  static Future<Map> setTimeReminded(Map data) async {
    const String url = "/user/set_time_reminded";
    final Response res = await dioConfigInterceptor.post(url, data: data);
    return res.data["data"];
  }

  static Future<Map> changePassword(
      String newPassword, String oldPassword) async {

    const String url = "/user/change_password";
    final Response res = await dioConfigInterceptor.post(url,
        data: {"new_password": newPassword, "old_password": oldPassword});
    return res.data;
  }

  static Future<Map> changeAvatar({required data, required onError}) async {
    try {
      const String url = "/upload/upload_avatar";
      final Response res = await dioConfigInterceptor.post(url, data: data);
      return res.data;
    } 
    catch (e) {
      onError(e);
      return {};
    }
  }

  static Future<Map> getListContributedUsers({required Map data, Function()? onError}) async {
    // try {
      const String url = "/user/get_list_user_of_type";
      final Response res = await dioConfigInterceptor.post(url, data: data);
      return res.data;
  //   } 
  //   catch (e) {
  //     onError?.call();
  //     return {};
  //   }
  }
}
