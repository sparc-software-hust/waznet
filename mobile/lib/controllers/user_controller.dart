import 'package:cecr_unwomen/http.dart';
import 'package:dio/dio.dart';

class UserController {
  static Future<void> getUserInfo() async {
    const String url = "/user/get_info";
    final Response res = await dioConfigInterceptor.post(url, data: {"user_id": "f47cc61f-6e66-4822-835a-e0ed2485997e"});
    print('aaa:${res.data}');
  }
}
