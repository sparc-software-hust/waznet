import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/authentication.dart';
import 'package:cecr_unwomen/features/firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ColorConstants colorCons = ColorConstants();
  bool isHousehold = true;
  int _currentIndex = 0;

  changeBar() {
    setState(() {
      isHousehold = !isHousehold;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      bottomNavigationBar: SalomonBottomBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        itemPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home),
          title: const Text("Trang chủ"),
          selectedColor: colorCons.primaryGreen,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.map),
          title: const Text("Bản đồ"),
          selectedColor: colorCons.primaryGreen,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.message),
          title: const Text("Tin nhắn"),
          selectedColor: colorCons.primaryGreen,
        ),
      ]),
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
                const CardStatistic(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardStatistic extends StatelessWidget {
  const CardStatistic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          CardInfoWidget(
            icon: PhosphorIcon(
              PhosphorIcons.fill.users, size: 100, color: Colors.white
            ),
            text: "Hộ gia đình",
            number: 999
          ),
          CardInfoWidget(
            icon: PhosphorIcon(
              PhosphorIcons.fill.users, size: 100, color: Colors.white
            ),
            text: "Hộ gia đình",
            number: 999
          ),
          CardInfoWidget(
            icon: PhosphorIcon(
              PhosphorIcons.fill.users, size: 100, color: Colors.white
            ),
            text: "Hộ gia đình",
            number: 999
          ),
          CardInfoWidget(
            icon: PhosphorIcon(
              PhosphorIcons.fill.users, size: 100, color: Colors.white
            ),
            text: "Hộ gia đình",
            number: 999
          ),
        ],
      ),
    );
  }
}

class CardInfoWidget extends StatelessWidget {
  const CardInfoWidget({super.key, required this.icon, required this.text, required this.number});
  final Widget icon;
  final String text;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text,
                    style: TextStyle(
                        color: Color(0xFF666667),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Text("$number",
                    style: TextStyle(
                        color: Color(0xFF29292A),
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Positioned(
            right: -5,
            bottom: -20,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Color(0xFFFFFCF0), Color(0xFFC8E6C9)], // Define your gradient colors here
                  tileMode: TileMode.clamp,
                  begin: Alignment.centerLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: icon
            ),
          ),
        ],
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
