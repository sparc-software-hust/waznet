import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/controllers/auth_controller.dart';
import 'package:cecr_unwomen/controllers/firebase_messaging_controller.dart';
import 'package:cecr_unwomen/controllers/user_controller.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ColorConstants colorCons = ColorConstants();

  @override
  void initState() {
    super.initState();
    initFirebase();
    setupInteractedMessage();
  }

  Future<void> initFirebase() async {
    await FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true, provisional: true);
    await FirebaseMessagingController.setupFirebaseToken();
    FirebaseMessaging.instance.onTokenRefresh.listen(FirebaseMessagingController.uploadFirebaseToken);
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _handleMessageOpenedApp(initialMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification == null) return;
      print('Message also contained a notification: ${message.notification}');
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('okeee i seeeee:${message.notification?.body}');
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [colorCons.primaryLightGreen1, Colors.white],
        stops: const [0.1, 0.8],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        // tileMode: TileMode.mirror
      )),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(
                              "https://statics.pancake.vn/panchat-prod/2024/1/15/6574ac19760ba6628a77f63dcd3991d41c2e8add.jpeg"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Thái Đồng",
                          style: colorCons.fastStyle(
                              16, FontWeight.w600, colorCons.primaryBlack1)),
                      const SizedBox(height: 2),
                      Text("Hôm nay bạn thế nào?",
                          style: colorCons.fastStyle(
                              14, FontWeight.w400, colorCons.primaryBlack1))
                    ],
                  ),
                ],
              ),
              PhosphorIcon(PhosphorIcons.bold.bell,
                  size: 24, color: colorCons.primaryBlack1),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: colorCons.primaryGreen,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: colorCons.primaryGreen,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: InkWell(
                onTap: () async {
                  final res = await AuthController.login("0967827856", "270920011");
                  print('okee:${res}');
                },
                child: Text("Login fake")
              )
            )
          ),
          const SizedBox(height: 20,),
          Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: colorCons.primaryGreen,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: InkWell(
                onTap: () async {
                  print('zzz');
                  await UserController.getUserInfo();
                },
                child: Text("Get user info")
              )
            )
          )
        ],
      ),
    );
  }
}
