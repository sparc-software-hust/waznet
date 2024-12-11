import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/tab_bar_widget.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final ColorConstants colorCons = ColorConstants();
  bool isHouseholdTab = true;

  void changeBar() {
    setState(() {
      isHouseholdTab = !isHouseholdTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderWidget(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Dữ liệu", style: colorCons.fastStyle(18, FontWeight.w600, const Color(0xFF29292A))),
              InkWell(
                onTap: () => Utils.showDialogWarningError(context, false, "Chức năng đang được phát triển"),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: PhosphorIcon(PhosphorIcons.regular.export,
                      size: 24, color: colorCons.primaryBlack1),
                ),
              ),
            ],
          )
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                BarWidget(isHousehold: isHouseholdTab, changeBar: changeBar),
                // if (allData["overall_data_one_month"] != null && allData["overall_data_one_month"].isNotEmpty)
                // ...allData["overall_data_one_month"].map((e) {
                //   final int roleIdUser = isHouseholdTab ? 2 : 3;
                //   return UserContributionWidget(oneDayData: {...e, "role_id": roleIdUser});
                // }).toList()
                // else
                const Center(
                  child: Text("Không có dữ liệu", style: TextStyle(
                    color: Color(0xFF808082),
                    fontSize: 16,
                    fontWeight: FontWeight.w500)
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}