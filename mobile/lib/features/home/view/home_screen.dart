import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/authentication.dart';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/firebase/firebase.dart';
import 'package:cecr_unwomen/features/home/view/component/card_statistic.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/tab_bar_widget.dart';
import 'package:cecr_unwomen/features/home/view/contribution_screen.dart';
import 'package:cecr_unwomen/features/home/view/statistic_screen.dart';
import 'package:cecr_unwomen/features/home/view/user_info.dart';
import 'package:cecr_unwomen/temp_api.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/circle_avatar.dart';
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
  final ScrollController _scrollControllerHome = ScrollController();
  bool isHouseholdTab = true;
  int _currentIndex = 0;
  final Map householdData = {};
  final Map scraperData = {};

  changeBar() {
    setState(() {
      isHouseholdTab = !isHouseholdTab;
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
  void initState() {
    super.initState();
    final User? user = context.read<AuthenticationBloc>().state.user;
    if (user == null) return;
    isHouseholdTab = user.roleId != 3;
    callApiGetOverallData();
  }

  callApiGetOverallData() async {
    // TODO: move to bloc
    if (!mounted) return;
    final int roleId = context.read<AuthenticationBloc>().state.user!.roleId;
    final data  = await TempApi.getOverallData();

    if (!(data["success"] ?? false)) return;

    if (roleId == 2) {
      setState(() {
        householdData['statistic'] = data["data"];
      });
    } else if (roleId == 3) {
      setState(() {
        scraperData['statistic'] = data["data"];
      });
    } else if (roleId == 1) {
      setState(() {
        householdData['statistic'] = data["data"]["household_overall_data"];
        scraperData['statistic'] = data["data"]["scraper_overall_data"];
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollControllerHome.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map allData = isHouseholdTab ? (householdData['statistic'] ?? {}) : (scraperData['statistic'] ?? {});
    final Widget adminWidget = Column(
      children: [
        HeaderWidget(
          child: Builder(
            builder: (context) {
              final User? user = context.watch<AuthenticationBloc>().state.user;
              if (user == null) return const SizedBox();

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomCircleAvatar(
                        size: 40,
                        avatarUrl: user.avatarUrl,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${user.firstName} ${user.lastName}",
                              style: colorCons.fastStyle(
                                  16, FontWeight.w600, colorCons.primaryBlack1)),
                          const SizedBox(height: 2),
                          Text("Hôm nay bạn thế nào??",
                              style: colorCons.fastStyle(
                                  14, FontWeight.w400, colorCons.primaryBlack1))
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Utils.showDialogWarningError(context, false, "Chức năng đang được phát triển"),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: PhosphorIcon(PhosphorIcons.regular.bell,
                          size: 24, color: colorCons.primaryBlack1),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollControllerHome,
            child: Column(
              children: [
                BarWidget(isHousehold: isHouseholdTab, changeBar: changeBar),
                CardStatistic(
                  isHouseholdTab: isHouseholdTab, 
                  statistic: allData
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(
                            builder: (context) {
                              final int roleId = context.watch<AuthenticationBloc>().state.user!.roleId;
                              return Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(roleId == 1 ? "Người cung cấp số liệu" : "Thống kê số liệu đóng góp",
                                    style: colorCons.fastStyle(
                                        14, FontWeight.w600, const Color(0xFF666667))),
                              );
                            }
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (allData["overall_data_one_month"] != null && allData["overall_data_one_month"].isNotEmpty)
                      ...allData["overall_data_one_month"].map((e) {
                        final int roleIdUser = isHouseholdTab ? 2 : 3;
                        return UserContributionWidget(oneDayData: {...e, "role_id": roleIdUser});
                      }).toList()

                      else const Center(
                        child: Text("Không có dữ liệu", style: TextStyle(
                          color: Color(0xFF808082),
                          fontSize: 16,
                          fontWeight: FontWeight.w500)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final int roleId = context.watch<AuthenticationBloc>().state.user!.roleId;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      floatingActionButton: roleId != 1 && _currentIndex == 0 ? FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          final bool? shouldCallApi = await Navigator.push(context, MaterialPageRoute(builder: (context) => ContributionScreen(roleId: roleId)));
          if (!(shouldCallApi ?? false)) return;
          callApiGetOverallData();
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: Icon(PhosphorIcons.regular.plus, size: 24, color: Colors.white),
      ) : null,
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
      body: BlocProvider(
        lazy: false,
        create: (context) => FirebaseBloc()
          ..add(SetupFirebaseToken())
          ..add(TokenRefresh())
          ..add(OpenMessageBackground())
          ..add(OpenMessageTerminated())
          ..add(ReceiveMessageForeground()),
        child: _currentIndex == 0 ? adminWidget
          : _currentIndex == 1 ? const StatisticScreen()
          : const UserInfo(),
        ),
      );
    }
  }

class CardInfoWidget extends StatelessWidget {
  const CardInfoWidget({super.key, required this.icon, required this.text, required this.number});
  final Widget icon;
  final String text;
  final String number;

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
                Text(number,
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
