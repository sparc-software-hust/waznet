import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/authentication.dart';
import 'package:cecr_unwomen/features/firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final ColorConstants colorCons = ColorConstants();
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          lazy: false,
          create: (context) => FirebaseBloc()
            ..add(SetupFirebaseToken())
            ..add(TokenRefresh())
            ..add(OpenMessageBackground())
            ..add(OpenMessageTerminated())
            ..add(ReceiveMessageForeground()),
          child: Container(
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
                        // final res = await AuthController.login("0967827856", "270920011");
                        // print('okee:${res}');
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
                      onTap: () {
                        context.read<AuthenticationBloc>().add(LogoutRequest());
                      },
                      child: Text("Logout")
                    )
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
