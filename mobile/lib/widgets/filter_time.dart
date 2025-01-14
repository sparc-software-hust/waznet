import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/constants/extension/datetime_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

enum TimeFilterOptions {today, thisWeek, thisMonth, thisQuarter, thisYear, custom}

class TimeFilter extends StatefulWidget {
  final TimeFilterOptions option;
  final DateTime? start;
  final DateTime? end;
  final Function(TimeFilterOptions) onSave;
  final Function(DateTime, DateTime) onSaveCustomRange;
  const TimeFilter({super.key, required this.onSave, required this.onSaveCustomRange, this.option = TimeFilterOptions.thisMonth, this.start, this.end});

  @override
  State<TimeFilter> createState() => _TimeFilterState();
}

class _TimeFilterState extends State<TimeFilter> {
  final ColorConstants colorCons = ColorConstants();
  late TimeFilterOptions option;
  late DateTime start;
  late DateTime end;
  bool isCustom = false;
  final DateRangePickerController _controller = DateRangePickerController();
  PickerDateRange? _trackingRange;
  List<DateTime>? specialDates;
  DateTime dateTitle = DateTime.now();

  @override
  void initState() {
    super.initState();
    option = widget.option;
    start = widget.start ??  DateTime.now();
    end = widget.end ??  DateTime.now();
    if (widget.start != null && widget.end != null) {
      _trackingRange = PickerDateRange(widget.start, widget.end);
      _controller.selectedRange = _trackingRange;
      specialDates = [dateTitle];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          child: Container(
              height: isCustom ? 500 : 300 ,
              padding: const EdgeInsets.symmetric(horizontal:  24, vertical: 3),
              color: const Color(0xffFFFFFF),
              child: Column(
                children: [
                  Container(
                    height: 5,
                    width: 45,
                    margin: const EdgeInsets.only(top: 6, bottom: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xffC1C1C2),
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  if (!isCustom)
                  ...[Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 20,),
                      Text(
                        "Lọc theo",
                        style: ColorConstants().fastStyle(
                            16, FontWeight.w700, const Color(0xff29292A)),
                      ),
                      InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            PhosphorIcons.regular.x,
                            size: 24, color: const Color(0xff4D4D4E),
                          )
                        )
                    ],
                  ),
                  ...TimeFilterHelper.options.map((e) {
                    return InkWell(
                      onTap: () {
                        if (!TimeFilterHelper.isCustomOption(e)) {
                          widget.onSave(e);
                          Navigator.pop(context);
                        } else {
                          widget.onSave(e);
                          setState(() {
                            isCustom = true;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(TimeFilterHelper.getOptionsString(e), 
                                style: colorCons.fastStyle(16, FontWeight.w400, const Color(0xff29292A)),
                            ),
                            if (e == option)
                            Icon(PhosphorIcons.fill.checkCircle, color: const Color(0xff4CAF50), size: 20,)
                          ],
                        ),
                      ),
                    );
                  })
                  ]
                  else
                  _buildDateRangePicker()
                ]
              )
            )
          )
    );
  }

  Widget _buildDateRangePicker() {
    bool isValid = _trackingRange != null && _trackingRange?.startDate != null && _trackingRange?.endDate != null;

    String intToVietnameseDayOfWeek(int day) {
      switch (day) {
        case 0:
          return "Th2";  
        case 1:
          return "Th3";   
        case 2:
          return "Th4";    
        case 3:
          return "Th5";   
        case 4:
          return "Th6";  
        case 5:
          return "Th7";   
        case 6:
            return "CN"; 
        default:
          return "";
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    isCustom = false;
                  });
                },
                child: Text("Trở về", style: colorCons.fastStyle(16, FontWeight.w600, const Color(0xff158C3E)))
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      _controller.backward?.call();
                    },
                    child: Icon(PhosphorIcons.regular.caretLeft, color: const Color(0xff666667),size: 20,)
                  ),
                  const SizedBox(width: 15,),
                  Text(DateFormat("MMMM/yyyy", "vi").format(dateTitle).capitalizeFirstChar(), style: colorCons.fastStyle(16, FontWeight.w600, const Color(0xff29292A))),
                  const SizedBox(width: 15,),
                  InkWell(
                    onTap: () {
                      _controller.forward?.call();
                    },
                    child: Icon(PhosphorIcons.regular.caretRight, color: const Color(0xff666667),size: 20,)
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(PhosphorIcons.regular.x, color: const Color(0xff4D4D4E),size: 20,)
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              return Text(
                intToVietnameseDayOfWeek(index),
                style: const TextStyle(
                  color: Color(0xff666667),
                  fontWeight: FontWeight.w500
                ),
              );
            }),
          ),
        ),
        SizedBox(
          height: 280,
          child: SfDateRangePicker(
            headerHeight: 0,
            controller: _controller,
            showNavigationArrow: true,
            allowViewNavigation: false,
            selectionMode: DateRangePickerSelectionMode.range,
            selectionColor: const Color(0xff4CAF50),
            rangeSelectionColor: const Color(0xffE8F5E9),
            startRangeSelectionColor:const Color(0xffFFFFFF),
            endRangeSelectionColor: const Color(0xffFFFFFF),
            monthViewSettings: DateRangePickerMonthViewSettings(
              showTrailingAndLeadingDates: true,
              viewHeaderHeight: 0,
              enableSwipeSelection: false,
              firstDayOfWeek: 1,
              // trigger rebuild lai widget nay khi changed view
              specialDates: specialDates
            ),
            cellBuilder: (context, details) {
              final bool isToday = details.date.isSameDate(DateTime.now());
              bool isPassDate = !details.date.isSameMonth(dateTitle);
              bool isSelected = _controller.selectedRange != null && (
                (_controller.selectedRange?.startDate != null &&  _controller.selectedRange!.startDate!.isSameDate(details.date))
                || (_controller.selectedRange?.endDate != null &&  _controller.selectedRange!.endDate!.isSameDate(details.date))
              );
              // case 2 ngay canh nhau, them margin de nhin k bi sat 
              bool isShortRange = _controller.selectedRange != null 
                &&  _controller.selectedRange?.startDate != null
                &&  _controller.selectedRange?.endDate != null
                && _controller.selectedRange!.startDate!.add(const Duration(days: 1)).isSameDate(_controller.selectedRange!.endDate!)
              ;
          
              return Container(
                height: details.bounds.height,
                width: details.bounds.width,
                margin:  EdgeInsets.all(isToday || (isShortRange && isSelected) ? 3 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: isToday ? Border.all(color: const Color(0xff4CAF50)) : null,
                  color: isSelected ? const Color(0xff4CAF50) : Colors.transparent
                ),
                child: Center(
                  child: Text(details.date.day.toString(),
                    style: isPassDate 
                    ? colorCons.fastStyle(16, FontWeight.w400, const Color(0xffC1C1C2)) 
                    : isSelected 
                      ? colorCons.fastStyle(16, FontWeight.w400, const Color(0xffFFFFFF)) 
                      : colorCons.fastStyle(16, FontWeight.w400, const Color(0xff1D1D1E)) 
                  )
                ),
              );
            },
            onViewChanged: (dateRangePickerViewChangedArgs) {
              if (dateRangePickerViewChangedArgs.visibleDateRange.startDate != null) {  
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  setState(() {
                    dateTitle = dateRangePickerViewChangedArgs.visibleDateRange.startDate!.add(const Duration(days: 7));
                    specialDates = [dateTitle];
                  });
                });
              }
            },
            onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
              _trackingRange = dateRangePickerSelectionChangedArgs.value;
              setState(() {
                isValid = _trackingRange?.startDate != null && _trackingRange?.endDate != null;
              });
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(
            color: Color(0xffF4F4F5),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Từ ngày",
                    style: colorCons.fastStyle(14, FontWeight.w400, const Color(0xff666667))),
                if (_trackingRange != null && _trackingRange?.startDate != null)
                Text(DateFormat("dd/MM/yyyy").format(_trackingRange!.startDate!),
                    style: colorCons.fastStyle(16, FontWeight.w500, const Color(0xff333334))),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Đến ngày",
                    style: colorCons.fastStyle(14, FontWeight.w400, const Color(0xff666667))),
                if (_trackingRange != null && _trackingRange?.endDate != null)
                Text(DateFormat("dd/MM/yyyy").format(_trackingRange!.endDate!),
                    style: colorCons.fastStyle(16, FontWeight.w500, const Color(0xff333334))),
              ],
            ),
            ElevatedButton(
              onPressed: !isValid ? null : () {
                start = _trackingRange!.startDate!;
                end = _trackingRange!.endDate!;
                widget.onSaveCustomRange(start,end);

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isValid ? const Color(0xff4CAF50) : const Color(0xffC1C1C2),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("Chọn",
                  style: colorCons.fastStyle(16, FontWeight.w700, Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}


class TimeFilterHelper {
  static List options = [
    TimeFilterOptions.today, 
    TimeFilterOptions.thisWeek, 
    TimeFilterOptions.thisMonth, 
    TimeFilterOptions.thisQuarter, 
    TimeFilterOptions.thisYear, 
    TimeFilterOptions.custom
  ];

  static String getOptionsString(TimeFilterOptions option) {
    switch (option) {
      case TimeFilterOptions.today:
        return "Hôm nay";
      case TimeFilterOptions.thisWeek:
        return "Tuần này";
      case TimeFilterOptions.thisMonth:
        return "Tháng này";
      case TimeFilterOptions.thisQuarter:
        return "Quý này";
      case TimeFilterOptions.thisYear:
        return "Năm nay";
      default:
        return "Tuỳ chỉnh";
    }
  }

  static Map getDateRange(TimeFilterOptions option) {
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();
    final now = DateTime.now();
    switch (option) {
      case TimeFilterOptions.today:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case TimeFilterOptions.thisWeek:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;

      case TimeFilterOptions.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;

      case TimeFilterOptions.thisQuarter:
        final currentQuarter = ((now.month - 1) ~/ 3) * 3 + 1;
        start = DateTime(now.year, currentQuarter, 1);
        end = DateTime(now.year, currentQuarter + 3, 0, 23, 59, 59);
        break;

      case TimeFilterOptions.thisYear:
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59);
        break;

      default:
      //month
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }


    return {
      "start_date": start,
      "end_date": end
    };
  }

  static bool isCustomOption(TimeFilterOptions option) {
    return option == TimeFilterOptions.custom;
  }
}

