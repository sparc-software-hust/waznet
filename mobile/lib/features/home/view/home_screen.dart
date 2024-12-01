import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/constants/text_constants.dart';
import 'package:cecr_unwomen/features/authentication/authentication.dart';
import 'package:cecr_unwomen/features/firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:collection/collection.dart';

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

  buildBarItem({required PhosphorIconData icon, required PhosphorIconData activeIcon, required String title}) {
    return SalomonBottomBarItem(
      icon: PhosphorIcon(icon, size: 24, color: const Color(0xFF808082)),
      title: Text(title),
      activeIcon: PhosphorIcon(activeIcon, size: 24, color: const Color(0xFF348A3A)),
      selectedColor: const Color(0xFF348A3A)
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget adminWidget = Column(
      children: [
        HeaderWidget(
          child: Row(
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
        ),
        BarWidget(isHousehold: isHousehold, changeBar: changeBar),
        CardStatistic(isHousehold: isHousehold),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text("Người cung cấp số liệu",
                        style: colorCons.fastStyle(
                            14, FontWeight.w600, const Color(0xFF666667))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const UserContributionWidget(),
              const UserContributionWidget(),
              const UserContributionWidget(),
              const UserContributionWidget(),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      bottomNavigationBar: SalomonBottomBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        itemPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        items: [
          buildBarItem(
            activeIcon: PhosphorIcons.fill.house,
            icon: PhosphorIcons.regular.house, title: "Trang chủ"
          ),
          buildBarItem(
            activeIcon: PhosphorIcons.fill.chartBar,
            icon: PhosphorIcons.regular.chartBar, title: "Dữ liệu"
          ),
          buildBarItem(
            activeIcon: PhosphorIcons.fill.userCircle,
            icon: PhosphorIcons.regular.userCircle, title: "Tài khoản"
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
            child: _currentIndex == 0 ? adminWidget
              : HeaderWidget(
                child: Column(
                  children: [
                    // BarWidget(isHousehold: isHousehold, changeBar: changeBar),
                    // const UserContributionWidget(),
                    // const UserContributionWidget(),
                    // const UserContributionWidget(),
                    // const UserContributionWidget(),
                    // const UserContributionWidget(),
                    // const UserContributionWidget(),
                    // const UserContributionWidget(),
                    // const UserContributionWidget(),
                    // const UserContributionWidget(),
                    // const UserContributionWidget(),
                    // const UserContributionWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  class UserContributionWidget extends StatefulWidget {
    const UserContributionWidget({super.key});

  @override
  State<UserContributionWidget> createState() => _UserContributionWidgetState();
}

class _UserContributionWidgetState extends State<UserContributionWidget> {

  _buildRowItem({required String text, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF808082)),
        const SizedBox(width: 12),
        Text(text,
            style: TextStyle(
                color: Color(0xFF333334),
                fontSize: 16,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF66BB6A),
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.regular.user, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRowItem(text: "Thái Đồng", icon: PhosphorIcons.regular.user),
              _buildRowItem(text: "04/11/2024 - 22:32", icon: PhosphorIcons.regular.clock),
              _buildRowItem(text: "500g CO₂e", icon: PhosphorIcons.regular.cloud),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      padding: const EdgeInsets.all(16),
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
          child,
        ],
      ),
    );
  }
}

class CardStatistic extends StatelessWidget {
  const CardStatistic({super.key, required this.isHousehold});
  final bool isHousehold;

  @override
  Widget build(BuildContext context) {
    final String key = isHousehold ? 'household' : 'scraper';
    final List householdIcons = [
      PhosphorIcons.fill.users,
      PhosphorIcons.fill.package,
      PhosphorIcons.fill.recycle,
      PhosphorIcons.fill.trashSimple,
    ];

    final List scraperIcons = [
      PhosphorIcons.fill.users,
      PhosphorIcons.fill.package,
      PhosphorIcons.fill.trashSimple,
      PhosphorIcons.fill.currencyCircleDollar,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        physics: const NeverScrollableScrollPhysics(),
        children: adminStatistic[key]!.entries.mapIndexed((i, e) {
          final icon = isHousehold ? householdIcons[i] : scraperIcons[i];
          return CardInfoWidget(
            icon: PhosphorIcon(
              icon, size: 100, color: Colors.white
            ),
            text: e.value,
            number: 999
          );
        }).toList(),
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
                    style: const TextStyle(
                        color: Color(0xFF666667),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text("$number",
                    style: const TextStyle(
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
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
              color: isSelected ? const Color(0xFF333334) : const Color(0xFF808082),
              fontSize: 14,
              fontWeight: FontWeight.w600
            )),
          )
        )
      )
    );
  }
}
