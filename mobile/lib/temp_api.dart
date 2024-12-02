import 'package:cecr_unwomen/http.dart';

class TempApi {
  static Future<Map> contributionData(Map data) async {
    try {
      const String url = "/contribution/contribute_data";
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
  //   } catch {
  //     return {"success": false};
  //   }
  // }
}