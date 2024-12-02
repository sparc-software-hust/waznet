import 'package:cecr_unwomen/http.dart';

class TempApi {
  static Future<void> contributionData(Map data) async {
    const String url = "/contribution/contribute_data";
    final res = await dioConfigInterceptor.post(url, data: data);
    return res.data;
  }
}