import 'dart:io';

import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/constants/extension/datetime_extension.dart';
import 'package:cecr_unwomen/constants/text_constants.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/tab_bar_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/toast_content.dart';
import 'package:cecr_unwomen/features/home/view/contribution_screen.dart';
import 'package:cecr_unwomen/temp_api.dart';
import 'package:cecr_unwomen/widgets/filter_time.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key, required this.roleId, this.isHouseHoldTabAdminScreen, this.needGetDataAdmin});
  final int roleId;
  final bool? isHouseHoldTabAdminScreen;
  final bool? needGetDataAdmin;

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final ColorConstants colorCons = ColorConstants();
  Map householdStatisticData = {};
  List detailHouseholdStatisticData = [];
  Map scraperStatisticData = {};
  List detailScraperStatisticData = [];
  late bool isHouseholdTab;
  TimeFilterOptions option = TimeFilterOptions.thisMonth;
  bool isLoading = false;
  bool isGetDetailSuccess = true;
  late DateTime start;
  late DateTime end;
  FToast fToast = FToast();

  @override
  void initState() {
    super.initState();
    fToast.init(context);
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

    if (widget.needGetDataAdmin != null && oldWidget.needGetDataAdmin != null
      && widget.needGetDataAdmin!= oldWidget.needGetDataAdmin
    ) {
      callApiGetFilterOverallData();
    } 
  }

  callApiGetFilterOverallData({bool isCustomRange = false}) async {
    setState(() {
      isLoading = true;
    });
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
    isLoading = false;
    if (!(data["success"] ?? false)) return;
    await Future.delayed(const Duration(milliseconds: 200));
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

  Future<bool> _getDetailDataByTime() async {
    if (householdStatisticData["overall_data_by_time"] != null && scraperStatisticData["overall_data_by_time"] != null) {
      detailHouseholdStatisticData = householdStatisticData["overall_data_by_time"];
      detailScraperStatisticData = scraperStatisticData["overall_data_by_time"];
    }
    Map res = await TempApi.getDetailDataByTime(start: start, end: end).timeout(const Duration(seconds: 6), onTimeout: () {
      return {"success" : false};
    },);
    if (!res["success"]) return false;
    
    detailHouseholdStatisticData = detailHouseholdStatisticData.map((e) {
      List detailHouseholdContribution = res["data"]["detail_household"];
      Map? detailMap = detailHouseholdContribution.firstWhereOrNull((detail) {
        return detail["user_id"] == e["user_id"] && DateTime.parse(e["date"]).isSameDate(DateTime.parse(detail["date"]));
      });
      List factorMap =  detailMap == null ? [] : detailMap["factors"] ?? [];
      Map<String, dynamic> result = e;
      result.addAll({
        "factors": factorMap
      });
      return result;
    }).toList();

    detailScraperStatisticData = detailScraperStatisticData .map((e) {
      List detailHouseholdContribution = res["data"]["detail_scraper"];
      Map? detailMap = detailHouseholdContribution.firstWhereOrNull((detail) {
        return detail["user_id"] == e["user_id"] && DateTime.parse(e["date"]).isSameDate(DateTime.parse(detail["date"]));
      });
      List factorMap = detailMap == null ? [] : detailMap["factors"]  ?? [];
      Map<String, dynamic> result = e;
      result.addAll({
        "factors": factorMap
      });
      return result;
    }).toList();
   
    return true;
  }

  _createExcel({required bool hasDetail}) async {
    Excel excel = Excel.createExcel();
    excel.rename("Sheet1", "Hộ gia đình");
    Sheet sheetHouseHold = excel["Hộ gia đình"];
    Sheet sheetScrapper = excel["Người thu gom"];

    CellStyle headerCellStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      fontSize: 18,
      bold: true,
      backgroundColorHex: ExcelColor.yellow400,
      textWrapping: TextWrapping.WrapText
    );
    List headerHouseHold = [" Số thứ tự ", " Ngày nhập ", " Người nhập ", " Tổng lượng kgCO₂e giảm thiểu ", " Lượng giảm thải kgCO₂e từ việc hạn chế đồ nhựa ", " Lượng giảm thải kgCO₂e từ việc tái chế "];
    List headerScraper = [" Số thứ tự ", " Ngày nhập ", " Người nhập ", " Tổng lượng kgCO₂e giảm thiểu ", " Lượng giảm thải kgCO₂e từ việc thu gom ", " Tổng số rác tái chế đã thu gom được (kg) ", " Trung bình chi phí xử lý rác thải tiết kiệm được (VND) "];
    // Neu api lay detail success se them cac column count factor
    if (hasDetail) {
      headerHouseHold  = headerHouseHold + householdDetailContribution.values.toList();
      headerScraper = headerScraper + scraperDetailContribution.values.toList();
    }
    sheetHouseHold.appendRow(headerHouseHold.map((e) => TextCellValue(e)).toList());
    sheetScrapper.appendRow(headerScraper.map((e) => TextCellValue(e)).toList());

    for (var data in detailHouseholdStatisticData) {
      List<CellValue> factors = !hasDetail ? [] : householdDetailContribution.keys.map((key) {
        List factorsDetail = data["factors"];
        Map? val = factorsDetail.firstWhereOrNull((e) {
          return e["factor_id"] == key;
        });
        if (key <= 4) {
          return IntCellValue(val != null ? val["quantity"].round() : 0);
        } 
        return DoubleCellValue(val != null ? val["quantity"] : 0.0);
      }).toList();
      sheetHouseHold.appendRow(
        [
        IntCellValue(detailHouseholdStatisticData.indexOf(data)),
        DateCellValue.fromDateTime(DateTime.parse(data["date"])),
        TextCellValue("${data["first_name"]} ${data["last_name"]}"),
        DoubleCellValue(data["kg_co2e_plastic_reduced"] + data["kg_co2e_recycle_reduced"]),
        DoubleCellValue(data["kg_co2e_plastic_reduced"]),
        DoubleCellValue(data["kg_co2e_recycle_reduced"]),
        ] + factors
      );
    }



    for (var data in detailScraperStatisticData) {
      List<CellValue> factors = !hasDetail ? [] : scraperDetailContribution.keys.map((key) {
        List factorsDetail = data["factors"];
        Map? val = factorsDetail.firstWhereOrNull((e) {
          return e["factor_id"] == key;
        });

        return DoubleCellValue(val != null ? val["quantity"] : 0.0);
      }).toList();
      sheetScrapper.appendRow(
        [
        IntCellValue(detailScraperStatisticData.indexOf(data)),
        DateCellValue.fromDateTime(DateTime.parse(data["date"])),
        TextCellValue("${data["first_name"]} ${data["last_name"]}"),
        DoubleCellValue(data["kg_co2e_reduced"] + data["kg_collected"]),
        DoubleCellValue(data["kg_co2e_reduced"]),
        DoubleCellValue(data["kg_collected"]),
        DoubleCellValue(data["expense_reduced"]),
        ] + factors
      );
    }

    for (var row in sheetScrapper.rows) {
      for (var e in row) {
        bool isDateType = row.indexOf(e) == 1;
        e?.cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 16, 
          numberFormat: isDateType ? const CustomDateTimeNumFormat(formatCode: "dd/MM/yyyy",) : NumFormat.standard_0
        );
      }
    }

    for (var row in sheetHouseHold.rows) {
      for (var e in row) {
        bool isDateType = row.indexOf(e) == 1;
        e?.cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 16, 
          numberFormat: isDateType ? const CustomDateTimeNumFormat(formatCode: "dd/MM/yyyy",) : NumFormat.standard_0
        );
      }
    }

    for (int i = 0; i < sheetScrapper.maxColumns || i < sheetHouseHold.maxColumns; i++) {
      sheetHouseHold.setColumnAutoFit(i);
      sheetScrapper.setColumnAutoFit(i);
      sheetHouseHold.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerCellStyle;
      sheetScrapper.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerCellStyle;
    }

    final fileBytes = excel.save();
    final directory = await getApplicationDocumentsDirectory();

    String fileName = "WAZNET_Thong_Ke_${DateFormat("dd_MM_yyyy").format(start)}_${DateFormat("dd_MM_yyyy").format(end)}.xlsx";
    File("${directory.path}/$fileName").writeAsBytes(fileBytes ?? []);
    // voi android, can co app ho tro view xlsx
    // voi ios, mo file in app 
    await OpenFile.open("${directory.path}/$fileName").then((value) {
      switch (value.type) {
        case ResultType.noAppToOpen:
          fToast.showToast(
            child: const ToastContent(
              isSuccess: false, 
              title: "Vui lòng đảm bảo thiết bị có cài đặt phần mềm hỗ trợ mở file excel",
            ),
            gravity: ToastGravity.BOTTOM
          );
          return;
        case ResultType.permissionDenied:
          fToast.showToast(
            child: const ToastContent(
              isSuccess: false, 
              title: "Không đủ quyền để mở file này",
            ),
            gravity: ToastGravity.BOTTOM
          );
          return;
        case ResultType.error:
          fToast.showToast(
            child: const ToastContent(
              isSuccess: false, 
              title: "Có lỗi xảy ra khi mở file excel, vui lòng thử lại sau",
            ),
            gravity: ToastGravity.BOTTOM
          );
          return;
        default: return;
      }
    });   
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
          if (isLoading)
          const CircularProgressIndicator(
            color: Color(0xff4CAF50),
            backgroundColor: Color(0xffC1C1C2),
          )
          else
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
              const SizedBox(width: 16),
              if (widget.roleId == 1)
              InkWell(
                onTap: () async{
                  bool isSuccess = await _getDetailDataByTime();
                  _createExcel(hasDetail: isSuccess);
                },
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
            child: RefreshIndicator(
              color: const Color(0xff4CAF50),
              backgroundColor: const Color(0xFFE8FCE3),
              onRefresh: () {
                return callApiGetFilterOverallData();
              },
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: buildStatistic()
              ),
            ),
          ),
        ),
      ],
    );
  }
}