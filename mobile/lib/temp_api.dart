import 'package:cecr_unwomen/http.dart';

class TempApi {
  static Future<Map> contributionData(Map data) async {
    try {
      const String url = "/contribution/contribute_data";
      print('data:$data');
      final res = await dioConfigInterceptor.post(url, data: data);
      return res.data;
    } catch (e) {
      print('aaa:$e');
      return {"success": false};
    }
  }

  static Future<Map> getDetailContribution(Map data) async {
    try {
      const String url = "/contribution/get_detail_contribution";
      final res = await dioConfigInterceptor.post(url, data: data);
      return res.data;
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map> register(Map data) async {
    try {
      const String url = "/user/register";
      final res = await dioConfigInterceptor.post(url, data: data);
      return res.data;
    } catch (e) {
      return {"success": false};
    }
  }

  // static Future<Map> contributionData(Map data) async {
  //   try {
  //     const String url = "/contribution/contribute_data";
  //     final res = await dioConfigInterceptor.post(url, data: data);
  //     return res.data;
  //   } catch (e) {
  //     return {"success": false};
  //   }
  // }

  static Future<Map> getOverallData() async {
    try {
      const String url = "/contribution/get_overall_data";
      final res = await dioConfigInterceptor.get(url);
      return res.data;
    } catch (e) {
      return {"success": false};
    }
  }
}