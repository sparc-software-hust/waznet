import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Utils {
  static Future<String?> getFirebaseToken() async {
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    return fcmToken;
  }
  // static String apiUrl = "http://192.168.0.9:4000/api";
  static String apiUrl = "http://192.168.1.203:4000/api";

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
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Close", 
                        style: TextStyle(color: Color(0xff05AABD), fontSize: 14, fontWeight: FontWeight.w500),),
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