import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/secrets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static Future<String?> getFirebaseToken() async {
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    return fcmToken;
  }
  static String apiUrl = Secrets.apiUrl;
  static String parseContributionDate(String input, {String format = 'dd/MM/yyyy - HH:mm'}) {
    final DateTime? date = DateTime.tryParse(input);
    if (date == null) return "";
    final DateFormat formatter = DateFormat(format);
    final String formattedDate = formatter.format(date.add(const Duration(hours: 7)));
    return formattedDate;
  }

  static String? getContributorName(String? firstName, String? lastName) {
    final bool hasName = firstName != null && lastName != null;
    if (!hasName) return null;
    return "$firstName $lastName";
  }

  static Future<dynamic> showDialogWarningError(BuildContext context, bool isDark, String warningContent) {
    final Color colorInput = isDark ? const Color(0xFF25282A) : const Color(0xFFF2F4F7);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: colorInput,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Container(
                width: 230,
                height: 130,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(warningContent,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFF6F6F7) : const Color(0xFF101828),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Đóng",
                        style: TextStyle(color: ColorConstants().bgClickable, fontSize: 16, fontWeight: FontWeight.w600),),
                    ),
                  ],
                )
              )
            );
          }
        );
      }
    );
  }
}