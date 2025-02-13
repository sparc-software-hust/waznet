import 'dart:io';

import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/constants/text_constants.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_bloc.dart';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/household_contribution_tabs.dart';
import 'package:cecr_unwomen/features/home/view/component/modal/user_contribution_detail.dart';
import 'package:cecr_unwomen/features/home/view/component/toast_content.dart';
import 'package:cecr_unwomen/temp_api.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/circle_avatar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ContributionScreen extends StatefulWidget {
  const ContributionScreen({super.key, required this.roleId});
  final int roleId;

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  final ColorConstants colorCons = ColorConstants();
  double totalkgCO2e = 0.0;
  List inputData = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _displayDate = DateTime.now();
  FToast fToast = FToast();
  bool isErrorDate = false;

  @override
  void initState() {
    super.initState();
    initData();
    fToast.init(context);
  }

  initData() {
    if (widget.roleId == 2) {
      inputData = List.generate(9, (index) => {
        "factor_id": index + 1,
        "quantity": 0,
        "co2e": 0.0,
      });
    } else {
      inputData = List.generate(3, (index) => {
        "factor_id": index + 1,
        "quantity": 0,
        "co2e": 0.0,
      });
    }
  }

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

  Future<void> _pickDate(BuildContext context) async {
    Utils.showDatePicker(
      context: context, 
      onCancel: () {
        _displayDate = _selectedDate;
        Navigator.pop(context);
      },
      onSave: () {
        setState(() {
          _selectedDate = _displayDate;
          isErrorDate = _selectedDate.isAfter(DateTime.now());
        });
        Navigator.pop(context);
      }, 
      onDateTimeChanged: (d) {
        _displayDate = d;
      },
      initDate: _selectedDate
    );
  }

  callApiToContributeData() async {
    if (!mounted) return;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(_selectedDate);

    final Map data = {
      "date": formattedDate,
      "data_entry": inputData
    };
    final res = await TempApi.contributionData(data);
    if (!(res["success"] ?? false)) {
      fToast.showToast(
        child: ToastContent(
          isSuccess: false, 
          title: 'Gửi dữ liệu thất bại. Bạn không thể nhập dữ liệu hai lần trong ngày. ${res["message"] ?? ""}'
        ),
        gravity: ToastGravity.BOTTOM
      );
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   duration: const Duration(seconds: 2),
      //   content: Text('Gửi dữ liệu thất bại. Bạn không thể nhập dữ liệu hai lần trong ngày. ${res["message"] ?? ""}', style: colorCons.fastStyle(16, FontWeight.w600, const Color(0xFFFFFFFF))),
      //   behavior: SnackBarBehavior.fixed,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(24),
      //   ),
      // ));
    } else {
      fToast.showToast(
        child: const ToastContent(
          isSuccess: true,
          title: 'Gửi dữ liệu thành công'
        ),
        gravity: ToastGravity.BOTTOM
      );
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   duration: const Duration(seconds: 2),
      //   content: Text('Gửi dữ liệu thành công', style: colorCons.fastStyle(16, FontWeight.w600, const Color(0xFFFFFFFF))),
      //   behavior: SnackBarBehavior.fixed,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(24),
      //   ),
      // ));
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  bool _validToSend() {
    final List data = inputData.where((element) => element["quantity"] > 0).toList();
    if (data.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final Map input = widget.roleId == 2 ? householdInput : scraperInput;
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
              ],
              ),
            )
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ngày nhập số liệu", style: TextStyle(
                  color: Color(0xFF1D1D1E),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)
                ),
                const SizedBox(height: 10),
                InkWell(
                  radius: 12,
                  onTap: () => _pickDate(context),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isErrorDate ? Border.all(color: const Color(0xffFF4F3F)) : null
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                            style: const TextStyle(
                              color: Color(0xFF333334),
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          ),
                          Icon(PhosphorIcons.regular.calendarBlank, size: 20, color: const Color(0xFF808082)),
                        ],
                      ),
                    )
                  ),
                ),
                if (isErrorDate)
                const Text("Không thể chọn ngày này, hãy thử lại", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xffFF4F3F))),
              ]
            )
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: widget.roleId == 2 ? 
              HouseholdContributionTabs(
                initialData: inputData,
                householdInput: input,
                callbackUpdateTotalKgCO2e: (Map data) {
                  updateTotalKgCO2e(data);
                },
              ) : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: input.entries.map((e) {
                        final int factorId = e.key;
                        final String text = e.value.values.last;
                        return ContributionInput(
                          textHeader: text,
                          factorId: factorId,
                          callBack: (Map data) {
                            updateTotalKgCO2e(data);
                          },
                          onlyInteger: factorId < 5 && widget.roleId == 2 ? true : false,
                          unitValue: e.value['unit_value'],
                        );
                      }).toList(),
                    ),
                  ],
                )
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Thống kê", style: colorCons.fastStyle(14, FontWeight.w600, const Color(0xFF29292A))),
                const SizedBox(height: 10),
                CountTotalOverallCo2e(
                  text: "Tổng lượng giảm phát thải khí nhà kính trong 1 ngày của bạn",
                  total: totalkgCO2e.toStringAsFixed(2),
                  icon: PhosphorIcons.fill.leaf
                ) ,
                const SizedBox(height: 12),
                InkWell(
                  onTap: !_validToSend() ? null : () async {
                    await callApiToContributeData();
                  },
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: (!_validToSend() || isErrorDate) ? const Color(0xFFE3E3E5) : const Color(0xFF4CAF50),
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

class CountTotalOverallCo2e extends StatelessWidget {
  const CountTotalOverallCo2e({super.key, required this.text, this.total = "0", this.unit = "kg CO₂e", required this.icon});
  final String text;
  final String total;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Text(text,
                          style: const TextStyle(
                            height: 22/14,
                            color: Color(0xFF666667),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          )
                      ),
                    ),
                    const Expanded(flex: 2, child: SizedBox())
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(total,
                      style: const TextStyle(
                        color: Color(0xFF29292A),
                        fontSize: 28,
                        fontWeight: FontWeight.w700
                      )
                    ),
                    const SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(unit,
                          style: const TextStyle(
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
              child: Icon(icon, size: 100, color: Colors.white),
            ),
          ),
        ],
      )
    );
  }
}

class ContributionInput extends StatefulWidget {
  const ContributionInput({
    super.key,
    required this.textHeader,
    required this.factorId,
    required this.callBack,
    this.onlyInteger = true,
    required this.unitValue,
    this.initValue
  });

  final String textHeader;
  final int factorId;
  final Function callBack;
  final bool onlyInteger;
  final double unitValue;
  final String? initValue;

  @override
  State<ContributionInput> createState() => _ContributionInputState();
}

class _ContributionInputState extends State<ContributionInput> {
  final TextEditingController _controller = TextEditingController();
  double co2eValue = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.initValue == null) return;
    _controller.value = TextEditingValue(text: widget.initValue!);
  }
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
      if (_controller.text.contains(",")) {
        _controller.text = _controller.text.replaceAll(",", ".");
      }
      currentValue = double.tryParse(_controller.text) ?? 0.0;
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
      if (_controller.text.contains(",")) {
        _controller.text = _controller.text.replaceAll(",", ".");
      }
      currentValue = double.tryParse(_controller.text) ?? 0.0;
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
            height: widget.factorId != 9 ? 192 : 95,
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        onChanged: (value) {
                          // if (value.contains(",")) return;
                          num currentValue = 0;
                          if (widget.onlyInteger && value.isNotEmpty) {
                            currentValue = int.tryParse(value) ?? 0;
                          } else if (!widget.onlyInteger && value.isNotEmpty) {
                            if (value.contains(",")) {
                              _controller.text = _controller.text.replaceAll(",", ".");
                            }
                            currentValue = double.tryParse(value) ?? 0;
                          }
                          if (currentValue < 0) {
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
                          LengthLimitingTextInputFormatter(5)
                        ] : [
                          LengthLimitingTextInputFormatter(5)
                        ],
                        placeholder: "Nhập số lượng",
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF333334),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Inter"
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
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(8), left: Radius.circular(2)),
                      ),
                      child: Icon(PhosphorIcons.regular.plus, size: 20, color: const Color(0xFF4CAF50)),
                    )
                  ),
                ],
              ),
              if (widget.factorId != 9)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              )
            ])
          )
        ],
      ),
    );
  }
}

class UserContributionWidget extends StatefulWidget {
  const UserContributionWidget({super.key, required this.oneDayData, required this.onDelete, required this.onReload, required this.index});
  final Map oneDayData;
  final int index;
  final Function(bool) onDelete;
  final Function(bool) onReload;

  @override
  State<UserContributionWidget> createState() => _UserContributionWidgetState();
}

class _UserContributionWidgetState extends State<UserContributionWidget> {

  _buildRowItem({required String text, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF808082)),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(
          color: Color(0xFF333334),
          fontSize: 16,
          fontWeight: FontWeight.w500
        )),
      ],
    );
  }

  num countTotal() {
    final int roleId = widget.oneDayData["role_id"] ?? 0;
    final Map data = widget.oneDayData;
    switch (roleId) {
      case 2:
        return (data["kg_co2e_recycle_reduced"] ?? 0) + (data["kg_co2e_plastic_reduced"] ?? 0);
      case 3: return data["kg_co2e_reduced"] ?? 0;
      default: return 0;
    }
  }

  String? getAvatarUrl() {
    final User? user = context.read<AuthenticationBloc>().state.user;
    if (user != null && user.roleId != 1) {
      return user.avatarUrl;
    } else {
      final bool hasAvatar = widget.oneDayData["avatar_url"] != null;
      if (!hasAvatar || widget.oneDayData["avatar_url"].contains("localhost")) return null;
      return widget.oneDayData["avatar_url"];
    }
  }

  @override
  Widget build(BuildContext context) {
    final User user = context.watch<AuthenticationBloc>().state.user!;
    final String name = Utils.getContributorName(widget.oneDayData["first_name"], widget.oneDayData["last_name"]) ?? "${user.firstName} ${user.lastName}";
    final String? avatarUrl = getAvatarUrl();
    final String date = Utils.parseContributionDate(widget.oneDayData["date"], format: "dd/MM/yyyy");
    final num totalCo2e = countTotal();
    final String roleUser = widget.oneDayData["role_id"] == 2 ? "Hộ gia đình" : "Người thu gom";

    // "https://statics.pancake.vn/panchat-prod/2024/1/15/6574ac19760ba6628a77f63dcd3991d41c2e8add.jpeg",
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: user.roleId == 1 
        ? Dismissible(
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) {
            void onDelete() async {
              if (context.mounted) {
                Navigator.pop(context);
              }
              // for shimmer effect
              widget.onReload.call(true);
              var res = await TempApi.removeContribution({
                "date": (DateTime.tryParse(widget.oneDayData["date"]) ?? DateTime.now()).toIso8601String(),
                "role_id_contribute": widget.oneDayData["role_id"],
                "user_id_contribute": widget.oneDayData["user_id"]
              });
              widget.onDelete.call(res["success"] ?? false);
              await Future.delayed(const Duration(milliseconds: 400));
              widget.onReload.call(false);
            }

            return showDialog(
              context: context,
              builder: (context) => Platform.isAndroid 
              ? AlertDialog(
                backgroundColor: const Color(0xFFFFFFFF),
                title: const Text("Xoá dữ liệu ?", style: TextStyle(color: Color(0xff333334), fontSize: 18, fontWeight: FontWeight.w700)),
                content: Text("Xoá dữ liệu khai báo ngày $date của $roleUser $name ?", style: const TextStyle(color: Color(0xff333334), fontSize: 14, fontWeight: FontWeight.w400)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Huỷ bỏ", style: TextStyle(color: Color(0xff333334), fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  TextButton(
                    onPressed: onDelete,
                    child: const Text("Xoá", style: TextStyle(color: Color(0xffDB2E2E), fontSize: 14, fontWeight: FontWeight.w600),),
                  ),
                ],
              )
              : CupertinoAlertDialog(
                title: const Text("Xoá dữ liệu ?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: "Inter")),
                content: Text("Xoá dữ liệu khai báo ngày $date của $roleUser $name ?", style: const TextStyle(fontSize: 14, fontFamily: "Inter")),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: onDelete,
                    child: const Text("Xoá", style: TextStyle(color: Color(0xffDB2E2E), fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Inter"),),
                  ),
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Huỷ bỏ", style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Inter"))
                  )
                ]),
            );
          },
          key: ValueKey<int>(widget.index),
          background:  Container(
              decoration: BoxDecoration(
                color: const Color(0xffDB2E2E),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Icon(PhosphorIcons.regular.trashSimple, color: Colors.white, size: 35),
            ),
          child: _buildContributeItem(user: user, name: name, avatarUrl: avatarUrl, date: date, totalCo2e: totalCo2e)
        )
        : _buildContributeItem(user: user, name: name, avatarUrl: avatarUrl, date: date, totalCo2e: totalCo2e),
      ),
    );
  }


  Widget _buildContributeItem({required User user, required String name, required String? avatarUrl, required String date, required num totalCo2e}) {
    return InkWell(
      radius: 12,
      onTap: () {
        showModalBottomSheet(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          backgroundColor: ColorConstants().bgApp,
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return UserContributionDetailScreen(
              oneDayData: widget.oneDayData,
              userId: widget.oneDayData["user_id"] ?? user.id,
              name: name,
              avatarUrl: avatarUrl,
              date: date,
              roleIdUser: widget.oneDayData["role_id"]
            );
          }
        );
      },
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomCircleAvatar(
              avatarUrl: avatarUrl,
              size: 56,
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRowItem(text: name, icon: PhosphorIcons.regular.user),
                _buildRowItem(text: date, icon: PhosphorIcons.regular.clock),
                _buildRowItem(text: "${totalCo2e.toStringAsFixed(2)} kg CO₂e",
                  icon: PhosphorIcons.regular.cloud
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DetailContributionItem extends StatelessWidget {
  const DetailContributionItem({super.key, this.isFirstItem = false, this.isLastItem = false, required this.contributionData});
  final bool isFirstItem;
  final bool isLastItem;
  final Map contributionData;

  @override
  Widget build(BuildContext context) {
    final ColorConstants colorCons = ColorConstants();
    final String quantityFormat = contributionData["factor_id"] <= 4 ? contributionData["quantity"].round().toString() : contributionData["quantity"].toString();
    final double value = contributionData["quantity"] * (contributionData["unit_value"] ?? 0);

    return Container(
      padding: isFirstItem ? const EdgeInsets.only(bottom: 10) 
        : isLastItem ? const EdgeInsets.only(top: 10)
        : const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLastItem ? null : Border(
          bottom: BorderSide(
            color: colorCons.bgApp,
            width: 1
          )
        )
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
              children: [
                TextSpan(
                  text: quantityFormat,
                  style: const TextStyle(
                    color: Color(0xFF1D1D1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w700)
                ),
                TextSpan(
                  text: " ${contributionData["description"]}",
                  style: TextStyle(
                    color: colorCons.textChild,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)
                ),
              ]
            )),
          ),

          Expanded(child: 
            contributionData["factor_id"] == 9 ? const SizedBox() :
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(value.toStringAsFixed(2),
                  style: TextStyle(
                    color: colorCons.textBold,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)
                ),
                const SizedBox(width: 8),
                Text("kg CO₂e", style: TextStyle(
                  color: colorCons.textChild,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}

class DetailContributionTypeGroup extends StatelessWidget {
  const DetailContributionTypeGroup({super.key, this.detailContribution = const [], required this.textHeader, required this.roleId, required this.insertedAt});
  final List detailContribution;
  final String textHeader;
  final String insertedAt;
  final int roleId;

  @override
  Widget build(BuildContext context) {
    final Map detailKeys = roleId == 2 ? householdDetailContribution : scraperDetailContribution;
    final Map<int, Map> dataCalcCo2e = roleId == 2 ? householdInput : scraperInput;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(textHeader, style: const TextStyle(
              color: Color(0xFF1D1D1E),
              fontSize: 14,
              fontWeight: FontWeight.w600)
            ),
            Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: Text(insertedAt, style: const TextStyle(
                color: Color(0xFF666667),
                fontSize: 14,
                fontWeight: FontWeight.w600)
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          // width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: detailContribution.mapIndexed((i, e) {
              final bool isFirstItem = i == 0;
              final bool isLastItem = i == detailContribution.length - 1;
              final String text = detailKeys[e["factor_id"]] ?? "";
              final double unitValue = dataCalcCo2e[e["factor_id"]]!["unit_value"];
              return DetailContributionItem(
                isFirstItem: isFirstItem,
                isLastItem: isLastItem,
                contributionData: {...e, "description": text, "unit_value": unitValue}
              );
            }).toList()
            // [
            //   DetailContributionItem(isFirstItem: true),
            //   DetailContributionItem(),
            //   DetailContributionItem(),
            //   DetailContributionItem(isLastItem: true),
            // ],
          )
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
