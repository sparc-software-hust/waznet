import 'package:cecr_unwomen/http.dart';
import 'package:intl/intl.dart';

class TempApi {
  static Future<Map> contributionData(Map data) async {
    try {
      const String url = "/contribution/contribute_data";
      // print('data:$data');
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

  static Future<Map> getFilterOverallData({required DateTime start,required DateTime end}) async {
    String startDate =  DateFormat('yyyy-MM-dd').format(start);
    String endDate = DateFormat('yyyy-MM-dd').format(end);

    try {
      const String url = "/contribution/get_filter_overall_data";
      final res = await dioConfigInterceptor.get(
        url, queryParameters: {
          "start": startDate,
          "end": endDate
        } 
      );
      return res.data;
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map> getDetailDataByTime({required DateTime start,required DateTime end}) async {
    String startDate =  DateFormat('yyyy-MM-dd').format(start);
    String endDate = DateFormat('yyyy-MM-dd').format(end);

    try {
      const String url = "/contribution/get_detail_contribution_by_time";
      final res = await dioConfigInterceptor.get(
        url, queryParameters: {
          "start": startDate,
          "end": endDate
        } 
      );
      return res.data;
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map> removeContribution(Map data) async {
    try {
      const String url = "/contribution/remove_contribution";
      final res = await dioConfigInterceptor.post(url, data: data);
      return res.data;
    } catch (e) {
      return {"success": false};
    }
  }
}