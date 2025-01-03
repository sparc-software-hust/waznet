import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/authentication.dart';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/firebase/firebase.dart';
import 'package:cecr_unwomen/features/home/view/component/card_statistic.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/tab_bar_widget.dart';
import 'package:cecr_unwomen/features/home/view/contribution_screen.dart';
import 'package:cecr_unwomen/features/home/view/statistic_screen.dart';
import 'package:cecr_unwomen/features/user/view/user_info.dart';
import 'package:cecr_unwomen/temp_api.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/circle_avatar.dart';
import 'package:fl_chart/fl_chart.dart';
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
    final int roleId = context.watch<AuthenticationBloc>().state.user!.roleId;
    final Widget adminWidget = Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
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
                    const SizedBox(width: 10),
                    // InkWell(
                    //   onTap: () => Utils.showDialogWarningError(context, false, "Chức năng đang được phát triển"),
                    //   child: Container(
                    //     height: 40,
                    //     width: 40,
                    //     decoration: const BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       color: Colors.white,
                    //     ),
                    //     child: PhosphorIcon(PhosphorIcons.regular.bell,
                    //         size: 24, color: colorCons.primaryBlack1),
                    //   ),
                    // ),
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
                                // final int roleId = context.watch<AuthenticationBloc>().state.user!.roleId;
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
                  if (roleId == 2) 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildHouseHoldChart()
                  )
                ]
              ),
            ),
          )
        ],
      ),
    );


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
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: SalomonBottomBar(
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
      ),
      body: BlocProvider(
        lazy: false,
        create: (context) => FirebaseBloc()
          ..add(SetupFirebaseToken())
          ..add(TokenRefresh())
          ..add(OpenMessageBackground())
          ..add(OpenMessageTerminated())
          ..add(ReceiveMessageForeground()),
        child: _currentIndex == 0 ? adminWidget
          : _currentIndex == 1 ?
          StatisticScreen(
            householdStatisticData: householdData["statistic"] ?? {},
            scraperStatisticData: scraperData["statistic"] ?? {},
            roleId: roleId,
          )
          : const UserInfo(),
        ),
      );
    }


  Widget _buildHouseHoldChart() {
    List data = (householdData['statistic'] ?? {})["sum_factors"] ?? [];
    List recycled = data.where((e) => (e["factor_name"] ?? "").contains("kilo")).map((e) {
      e.putIfAbsent("color", () {
        switch (e["factor_name"]) {
          case "one_kilo_plastic_recycled":
            return const Color(0xffA569BD);
          case "one_kilo_paper_recycled":
            return const Color(0xff58D68D);
          case "one_kilo_metal_garbage_recycled":
            return const Color(0xff5DADE2);
          case "one_kilo_organic_garbage_to_fertilizer":
            return const Color(0xffF1948A);
          default:
            return const Color(0xffF1948A);
        }
      });
      return e;
    }).toList();

    List rejected = data.where((e) => (e["factor_name"] ?? "").contains("rejected")).map((e) {
      e.putIfAbsent("color", () {
        switch (e["factor_name"]) {
          case "one_plastic_bag_rejected":
            return const Color(0xffA569BD);
          case "one_pet_bottle_rejected":
            return const Color(0xff64B5F6);
          case "one_plastic_cup_rejected":
            return const Color(0xffFFB74D);
          case "one_plastic_straw_rejected":
            return const Color(0xff81C784);
          default:
            return const Color(0xffF1948A);
        }
      });
      return e;
    }).toList();

    String convertGarbageCountToTitle(String key) {
      switch(key) {
        case "one_kilo_plastic_recycled":
          return "Nhựa";
        case "one_kilo_paper_recycled":
          return "Giấy";
        case "one_kilo_metal_garbage_recycled":
          return "Kim loại";
        case "one_kilo_organic_garbage_to_fertilizer":
          return "Hữu cơ";
        default: 
          return "";
      }
    }

    String convertRejectedCountToTitle(String key) {
      switch(key) {
        case "one_plastic_bag_rejected":
          return "Túi nhựa";
        case "one_pet_bottle_rejected":
          return "Chai nhựa";
        case "one_plastic_cup_rejected":
          return "Cốc dùng một lần";
        case "one_plastic_straw_rejected":
          return "Ống hút nhựa";
        default:
          return "";
      }
    }

    Widget label(String title, double value, Color color,) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 14,
              width: 14,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color
              ),
            ),
            const SizedBox(width: 6,),
            Expanded(
              child: Text(
                "$title (${value.toString()} kg)",
                style: colorCons.fastStyle(14, FontWeight.w400, const Color(0xff333334)),
              ),
            )
          ],
        ),
      );
    }

    Widget buildChartItem({bool isRecyled = true}) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRecyled ? "Đóng góp tái chế rác thải" : "Đóng góp giảm thiểu đồ nhựa", 
                style: colorCons.fastStyle(14, FontWeight.w600, const Color(0xff666667)),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xffE3E3E5)
                ),
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.regular.calendarBlank, size: 20, color: const Color(0xff4D4D4E),),
                    Text(" Tháng này",  style: colorCons.fastStyle(14, FontWeight.w500, const Color(0xff4D4D4E)),)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12,),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xffFFFFFF),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: const Color(0xff18274B).withOpacity(0.12),spreadRadius: -2, blurRadius: 4, offset: const Offset(0, 2)),
                BoxShadow(color: const Color(0xff18274B).withOpacity(0.08),spreadRadius: -2, blurRadius: 4, offset: const Offset(0, 4))
              ]
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: (isRecyled ? recycled : rejected).map((e) {
                        return PieChartSectionData(
                          radius: 20,
                          title: "",
                          value: e["quantity"] ?? 0,
                          color: e["color"] ?? const Color(0xffF1948A)
                        );
                      }).toList()
                    )
                  ),
                ),
                const SizedBox(width: 15,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: (isRecyled ? recycled : rejected).map((e) {
                      return label(
                        (isRecyled ? convertGarbageCountToTitle(e["factor_name"] ?? "") : convertRejectedCountToTitle(e["factor_name"] ?? "")),
                        e["quantity"] ?? 0,
                        e["color"] ?? const Color(0xffF1948A)
                      );
                    }).toList()
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        buildChartItem(),
        const SizedBox(height: 32,),
        buildChartItem(isRecyled: false)
      ]
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
        ],
      ),
    );
  }
}


