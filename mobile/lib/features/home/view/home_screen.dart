import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/constants/text_constants.dart';
// import 'package:cecr_unwomen/features/authentication/authentication.dart';
import 'package:cecr_unwomen/features/firebase/firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int roleId = 3;

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

    final Widget adminStatisticWidget = Column(
      children: [
        HeaderWidget(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Dữ liệu", style: colorCons.fastStyle(18, FontWeight.w600, const Color(0xFF29292A))),
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: PhosphorIcon(PhosphorIcons.regular.export,
                    size: 24, color: colorCons.primaryBlack1),
              ),
            ],
          )
        ),
        BarWidget(isHousehold: isHousehold, changeBar: changeBar),
        const UserContributionWidget(),
        const UserContributionWidget(),
        const UserContributionWidget(),
        const UserContributionWidget(),
        const UserContributionWidget(),
        const UserContributionWidget(),
        const UserContributionWidget(),
        const UserContributionWidget(),
        const UserContributionWidget(),
        const UserContributionWidget(),
        const UserContributionWidget(),
      ],
    );

    final Widget userInfoWidget = Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            height: 104,
            width: 104,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: NetworkImage(
                      "https://statics.pancake.vn/panchat-prod/2024/1/15/6574ac19760ba6628a77f63dcd3991d41c2e8add.jpeg"),
                  fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          Text("Thái Đồng", style: colorCons.fastStyle(18,FontWeight.w700, const Color(0xFF333334))),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () { },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("Sửa thông tin", style: colorCons.fastStyle(16, FontWeight.w600, const Color(0xFF4CAF50))),
              ),
            ),
          ),
          const SizedBox(height: 20),
          UserInfoItem(
            text: "Về chúng tôi",
            icon: PhosphorIcons.regular.users,
            onTap: () { },
          ),
          UserInfoItem(
            text: "Đổi mật khẩu",
            icon: PhosphorIcons.regular.lock,
            onTap: () { },
          ),
          UserInfoItem(
            text: "Đăng xuất",
            isLogout: true,
            icon: PhosphorIcons.regular.signOut,
            onTap: () { },
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      floatingActionButton: roleId != 1 && _currentIndex == 0 ? FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () { 
          Navigator.push(context, MaterialPageRoute(builder: (context) => ContributionScreen(roleId: roleId)));
        },
        child: Icon(PhosphorIcons.regular.plus, size: 24, color: Colors.white),
        backgroundColor: const Color(0xFF4CAF50),
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
        child: SingleChildScrollView(
          child: _currentIndex == 0 ? adminWidget
            : _currentIndex == 1 ? adminStatisticWidget
            : userInfoWidget,
          ),
        ),
      );
    }
  }

class ContributionScreen extends StatefulWidget {
  const ContributionScreen({super.key, required this.roleId});
  final int roleId;

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  final ColorConstants colorCons = ColorConstants();
  double totalkgCO2e = 0.0;
  final List inputData = [];

  updateTotalKgCO2e(Map data) {
    if (inputData.isNotEmpty) {
      final int index = inputData.indexWhere((element) => element["factor_id"] == data["factor_id"]);
      if (index != -1) {
        inputData[index] = data;
      } else {
        inputData.add(data);
      }
    } else {
      inputData.add(data);
    }
    setState(() {
      totalkgCO2e = inputData.fold(0.0, (previousValue, element) => previousValue + element["co2e"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map> input = widget.roleId == 2 ? householdInput : scraperInput;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      body: Column(
        children: [
          HeaderWidget(child:
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(PhosphorIcons.regular.arrowLeft, size: 24, color: const Color(0xFF29292A))),
                const SizedBox(width: 10),
                Text("Nhập dữ liệu", style: colorCons.fastStyle(18, FontWeight.w600, const Color(0xFF29292A))),
                // Container(
                //   height: 40,
                //   width: 40,
                //   decoration: const BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Colors.white,
                //   ),
                //   child: Icon(PhosphorIcons.regular.export, size: 24, color: colorCons.primaryBlack1),
                // ),
              ],
              ),
            )
          ),
          Expanded(
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: input.map((Map e) {
                    final String text = e.values.last;
                    return ContributionInput(
                      textHeader: text,
                      factorId: e['factor_id'],
                      callBack: (Map data) {
                        print('daataaa$data');
                        updateTotalKgCO2e(data);
                      },
                      onlyInteger: e['factor_id'] < 5 && widget.roleId == 2 ? true : false,
                      unitValue: e['unit_value'],
                    );
                  }).toList(),
                )
              ),
            ),
          ),
          // const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Thống kê", style: colorCons.fastStyle(14, FontWeight.w600, const Color(0xFF29292A))),
                const SizedBox(height: 10),
                Container(
                  height: 115,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE4FDDA), Color(0xFFFFFCF0)],
                      stops: [0.0, 0.45],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Expanded(
                                  child: Text("Tổng lượng giảm phát thải khí nhà kính trong 1 ngày của bạn",
                                      style: TextStyle(
                                        color: Color(0xFF666667),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                      )
                                  ),
                                ),
                                SizedBox(width: 50),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(totalkgCO2e.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Color(0xFF29292A),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700
                                  )
                                ),
                                const SizedBox(width: 3),
                                const Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text("kg CO₂e",
                                      style: TextStyle(
                                          color: Color(0xFF29292A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),

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
                          child: PhosphorIcon(PhosphorIcons.fill.leaf, size: 100, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 2),
                      content: Text('Gửi dữ liệu thành công', style: colorCons.fastStyle(16, FontWeight.w600, const Color(0xFFFFFFFF))),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ));
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: inputData.isEmpty ? const Color(0xFFE3E3E5) : const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("Gửi dữ liệu", textAlign: TextAlign.center, style: colorCons.fastStyle(16, FontWeight.w600, const Color(0xFFFFFFFF))),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ContributionInput extends StatefulWidget {
  const ContributionInput({super.key, required this.textHeader, required this.factorId, required this.callBack, this.onlyInteger = true, required this.unitValue});
  final String textHeader;
  final int factorId;
  final Function callBack;
  final bool onlyInteger;
  final double unitValue;
  @override
  State<ContributionInput> createState() => _ContributionInputState();
}

class _ContributionInputState extends State<ContributionInput> {
  final TextEditingController _controller = TextEditingController();
  // final FocusNode _focusNode = FocusNode();
  double co2eValue = 0.0;

  updateValue(currentValue) {
    setState(() {
      co2eValue = currentValue * widget.unitValue;
    });
  }

  void _incrementValue() {
    num currentValue = 0;
    if (widget.onlyInteger) {
      currentValue = int.tryParse(_controller.text) ?? 0;
    } else {
      currentValue = double.tryParse(_controller.text) ?? 0;
    }
    if (currentValue < 1) {
      currentValue = 0;
    }

    setState(() {
      _controller.text = (currentValue + 1).toString();
      co2eValue = (currentValue + 1) * widget.unitValue;
    });

    widget.callBack({
      'factor_id': widget.factorId,
      'quantity': currentValue + 1,
      'co2e': co2eValue
    });
  }

  void _decrementValue() {
    num currentValue = 0;
    if (widget.onlyInteger) {
      currentValue = int.tryParse(_controller.text) ?? 0;
    } else {
      currentValue = double.tryParse(_controller.text) ?? 0;
    }
    if (currentValue < 1) {
      currentValue = 1;
    }

    setState(() {
      _controller.text = (currentValue - 1).toString();
      co2eValue = (currentValue - 1) * widget.unitValue;
    });

    widget.callBack({
      'factor_id': widget.factorId,
      'quantity': currentValue - 1,
      'co2e': co2eValue
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.textHeader, style: const TextStyle(
            color: Color(0xFF1D1D1E),
            fontSize: 14,
            fontWeight: FontWeight.w600)
          ),
          const SizedBox(height: 10),
          Container(
            height: 192,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text("Số lượng", style: TextStyle(
                color: Color(0xFF666667),
                fontSize: 14,
                fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  InkWell(
                    canRequestFocus: false,
                    onTap: _decrementValue,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(8), right: Radius.circular(2)),
                      ),
                      child: Icon(PhosphorIcons.regular.minus, size: 20, color: const Color(0xFF4CAF50)),
                    )
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 40,
                      child: CupertinoTextField(
                        controller: _controller,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        onChanged: (value) {
                          num currentValue = 0;
                          if (widget.onlyInteger && value.isNotEmpty) {
                            currentValue = int.tryParse(value) ?? 0;
                          } else if (!widget.onlyInteger && value.isNotEmpty) {
                            currentValue = double.tryParse(value) ?? 0;
                          }

                          if (currentValue < 1) {
                            _controller.text = "";
                          }
                          setState(() {
                            co2eValue = currentValue * widget.unitValue;
                          });
                          widget.callBack({
                            'factor_id': widget.factorId,
                            'quantity': currentValue,
                            'co2e': co2eValue
                          });
                        },
                        inputFormatters: widget.onlyInteger ? [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3)
                        ] : [
                          LengthLimitingTextInputFormatter(3)
                        ],
                        placeholder: "Nhập số lượng",
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF333334),
                          fontSize: 17,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    )
                  ),
                  InkWell(
                    onTap: _incrementValue,
                    canRequestFocus: false,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(8), right: Radius.circular(2)),
                      ),
                      child: Icon(PhosphorIcons.regular.plus, size: 20, color: const Color(0xFF4CAF50)),
                    )
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: const Divider(color: Color(0xFFF4F4F5), height: 1, thickness: 1)
              ),
              const Text("Giảm phát thải khí nhà kính", style: TextStyle(
                color: Color(0xFF666667),
                fontSize: 14,
                fontWeight: FontWeight.w600)
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(co2eValue.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Color(0xFF808082),
                            fontSize: 16,
                            fontWeight: FontWeight.w500)
                        ),
                      ),
                    )),
                    const SizedBox(width: 10),
                    const Text("kg CO₂e", style: TextStyle(
                      color: Color(0xFF333334),
                      fontSize: 16,
                      fontWeight: FontWeight.w400)
                    ),
                  ],
                ),
              )
            ])
          )
        ],
      ),
    );
  }
}

class UserInfoItem extends StatelessWidget {
  const UserInfoItem({super.key, required this.text, required this.icon, this.isLogout =  false, this.isBiometric = false, this.onTap});
  final String text;
  final IconData icon;
  final bool isLogout;
  final bool isBiometric;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isLogout ? const Color(0xFFFF4F3F) : const Color(0xFF4CAF50);
    final Color iconBgColor = isLogout ? const Color(0xFFFFE8D8) : const Color(0xFFE8F5E9).withOpacity(0.7);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap == null ? null : onTap!(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(text, style: TextStyle(
                  color: !isLogout ? const Color(0xFF333334) : const Color(0xFFFF4F3F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600)
                ),
              ),
              Icon(PhosphorIcons.regular.caretRight, size: 20, color: const Color(0xFF4D4D4E)),
            ],
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
            style: const TextStyle(
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
          const SizedBox(height: 40),
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
        padding: const EdgeInsets.only(top: 0),
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
