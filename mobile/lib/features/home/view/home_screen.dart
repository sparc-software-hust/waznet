import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/authentication.dart';
import 'package:cecr_unwomen/features/firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ColorConstants colorCons = ColorConstants();
  bool isHousehold = true;

  changeBar() {
    setState(() {
      isHousehold = !isHousehold;
    });
  }
  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 124,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [const Color(0xFFA5D6A7).withOpacity(0.55), const Color(0xFF81C784)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16)
                    )
                  ),
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
                          Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: PhosphorIcon(PhosphorIcons.regular.bell,
                                size: 24, color: colorCons.primaryBlack1),
                          ),
                        ],
                      ),

                      // const SizedBox(height: 32),
                      // Container(
                      //   height: 100,
                      //   decoration: BoxDecoration(
                      //     color: colorCons.primaryGreen,
                      //     borderRadius: BorderRadius.circular(15),
                      //   ),
                      // ),
                      // const SizedBox(height: 20),
                      // Material(
                      //   color: Colors.transparent,
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(6),
                      //       color: colorCons.primaryGreen,
                      //     ),
                      //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      //     child: InkWell(
                      //       onTap: () async {
                      //         // final res = await AuthController.login("0967827856", "270920011");
                      //         // print('okee:${res}');
                      //       },
                      //       child: Text("Login fake")
                      //     )
                      //   )
                      // ),
                      // const SizedBox(height: 20,),
                      // Material(
                      //   color: Colors.transparent,
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(6),
                      //       color: colorCons.primaryGreen,
                      //     ),
                      //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      //     child: InkWell(
                      //       onTap: () {
                      //         context.read<AuthenticationBloc>().add(LogoutRequest());
                      //       },
                      //       child: Text("Logout")
                      //     )
                      //   )
                      // )
                    ],
                  ),
                ),
                BarWidget(isHousehold: isHousehold, changeBar: changeBar),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BarWidget extends StatefulWidget {
  const BarWidget({super.key, required this.isHousehold, required this.changeBar});
  final bool isHousehold;
  final Function changeBar;

  @override
  State<BarWidget> createState() => _BarWidgetState();
}

class _BarWidgetState extends State<BarWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 44,
        width: 280,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          color: Color(0xFFE3E3E5)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonBar(
              onPressed: widget.changeBar,
              isSelected: widget.isHousehold,
              text: "Hộ gia đình"
            ),
            ButtonBar(
              onPressed: widget.changeBar,
              isSelected: !widget.isHousehold,
              text: "Người thu gom"
            ),
          ],
        ),
      )
    );
  }
}

class ButtonBar extends StatelessWidget {
  const ButtonBar({super.key, required this.onPressed, required this.isSelected, required this.text});
  final Function onPressed;
  final bool isSelected;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 135,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: isSelected ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ) : null,
          color: isSelected ? Colors.white : Colors.transparent
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: InkWell(
          onTap: () => onPressed(),
          child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
            color: isSelected ? const Color(0xFF333334) : const Color(0xFF808082),
            fontSize: 14,
            fontWeight: FontWeight.w600
          ))
        )
      )
    );
  }
}
