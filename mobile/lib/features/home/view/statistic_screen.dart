import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/tab_bar_widget.dart';
import 'package:cecr_unwomen/features/home/view/contribution_screen.dart';
import 'package:cecr_unwomen/temp_api.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/filter_time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key, required this.roleId, this.isHouseHoldTabAdminScreen});
  final int roleId;
  final bool? isHouseHoldTabAdminScreen;

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final ColorConstants colorCons = ColorConstants();
  Map householdStatisticData = {};
  Map scraperStatisticData = {};
  late bool isHouseholdTab;
  TimeFilterOptions option = TimeFilterOptions.thisMonth;
  late DateTime start;
  late DateTime end;

  @override
  void initState() {
    super.initState();
    callApiGetFilterOverallData();
    isHouseholdTab = widget.isHouseHoldTabAdminScreen ?? true;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHouseHoldTabAdminScreen != null && oldWidget.isHouseHoldTabAdminScreen != null
      && widget.isHouseHoldTabAdminScreen != oldWidget.isHouseHoldTabAdminScreen
    ) {
      isHouseholdTab = widget.isHouseHoldTabAdminScreen!;
    } 
  }

  callApiGetFilterOverallData({bool isCustomRange = false}) async {
    if (!mounted) return;
    if (!isCustomRange) {
      Map dateMap = TimeFilterHelper.getDateRange(option);
      start = dateMap["start_date"];
      end = dateMap["end_date"];
    }

    final data  = await TempApi.getFilterOverallData(
      start: start,
      end: end
    );

    if (!(data["success"] ?? false)) return;

    switch (widget.roleId) {
      case 1:
        setState(() {
          householdStatisticData = data["data"]["household_overall_data"];
          scraperStatisticData = data["data"]["scraper_overall_data"];
        });
        break;
      case 2:
        setState(() {
          householdStatisticData = data["data"];
        });
        break;
      case 3:
        setState(() {
          scraperStatisticData = data["data"];
        });
        break;
    }
  }

  void changeBar() {
    setState(() {
      isHouseholdTab = !isHouseholdTab;
    });
  }

  _getRoleIdShowData() {
    return widget.roleId == 1 ?
      isHouseholdTab ? 2 : 3
    : widget.roleId;
  }

  @override
  Widget build(BuildContext context) {
    final Map allData = widget.roleId == 1 ?
      isHouseholdTab ? householdStatisticData : scraperStatisticData
    : widget.roleId == 2 ? householdStatisticData
    : widget.roleId == 3 ? scraperStatisticData
    : {};
    final String title = widget.roleId == 1 ? "Người cung cấp số liệu" : "Thống kế số liệu đóng góp";
    final bool isInAdminScreen = widget.isHouseHoldTabAdminScreen != null ;

    Widget buildStatistic() {
      return  Column(
        children: [
          if (!isInAdminScreen)
          BarWidget(isHousehold: isHouseholdTab, changeBar: changeBar),
          Padding(
            padding: const EdgeInsets.only(bottom:  12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, 
                  style: colorCons.fastStyle(14, FontWeight.w600, const Color(0xff666667)),
                ),
                InkWell(
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context, 
                      builder: (context) {
                        return TimeFilter(
                          option: option,
                          start: start,
                          end: end,
                          onSave: (e) {
                            setState(() {
                              option = e;
                            });
                            if (!TimeFilterHelper.isCustomOption(option)) {
                              callApiGetFilterOverallData();
                            }
                          },
                          onSaveCustomRange: (startDate, endDate) {
                            setState(() {
                              start = startDate;
                              end = endDate;
                            });
                            callApiGetFilterOverallData(isCustomRange: true);
                          },
                        );
                      }
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xffE3E3E5)
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.regular.calendarBlank, size: 20, color: const Color(0xff4D4D4E),),
                        Text(" ${TimeFilterHelper.getOptionsString(option)}",  style: colorCons.fastStyle(14, FontWeight.w500, const Color(0xff4D4D4E)),)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (allData["overall_data_by_time"] != null && allData["overall_data_by_time"].isNotEmpty)
          ...allData["overall_data_by_time"].map((e) {
            return UserContributionWidget(oneDayData: {...e, "role_id": _getRoleIdShowData()});
          }).toList()
          else
            const Center(
              child: Text("Không có dữ liệu", style: TextStyle(
                color: Color(0xFF808082),
                fontSize: 16,
                fontWeight: FontWeight.w500)
              ),
            ),
        ],
      );
    }

    return isInAdminScreen
    ? buildStatistic()
    : Column(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: buildStatistic()
            ),
          ),
        ),
      ],
    );
  }
}