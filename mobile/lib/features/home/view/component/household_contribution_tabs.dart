import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/home/view/contribution_screen.dart';
import 'package:flutter/material.dart';

class HouseholdContributionTabs extends StatefulWidget {
  const HouseholdContributionTabs({
    super.key,
    required this.householdInput,
    required this.callbackUpdateTotalKgCO2e,
    this.initialData = const []
  });

  final Map householdInput;
  final Function callbackUpdateTotalKgCO2e;
  final List initialData;

  @override
  State<HouseholdContributionTabs> createState() => _HouseholdContributionTabsState();
}

class _HouseholdContributionTabsState extends State<HouseholdContributionTabs> with SingleTickerProviderStateMixin {
  Map get input => widget.householdInput;

  late TabController tabController;
  final ColorConstants colorCons = ColorConstants();
  final ScrollController greenTabController = ScrollController(keepScrollOffset: true);
  final ScrollController massController = ScrollController(keepScrollOffset: true);
  final PageStorageKey screenTabKey = const PageStorageKey('screenTab');
  final PageStorageKey massTabKey = const PageStorageKey('massTab');

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this, animationDuration: const Duration(milliseconds: 50));
    tabController.addListener(() {
      if (tabController.previousIndex != tabController.index) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    greenTabController.dispose();
    massController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color colorDividerFilter = Color(0xFFF2F4F7);
    final bool isGreenActionTab = tabController.index == 0;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)
              ),
              color: Colors.white,
            ),
            child: TabBar(
              splashBorderRadius: BorderRadius.circular(12),
              controller: tabController,
              labelPadding: const EdgeInsets.symmetric(vertical: 2),
              indicatorColor: const Color(0xFF81C784),
              dividerColor: colorDividerFilter,
              indicatorSize: TabBarIndicatorSize.tab,
              onTap: (value) {
                tabController.animateTo(value);
              },
              tabs: [
                Tab(
                  child: Text(
                    "Thực hành xanh",
                    style: TextStyle(
                      color: isGreenActionTab ? colorCons.textBold : colorCons.textPlaceholder,
                      fontSize: 16,
                      fontWeight: isGreenActionTab ? FontWeight.w700 : FontWeight.w400,
                    ),
                  )
                ),
                Tab(
                  child: Text(
                    "Khối lượng rác thải",
                    style: TextStyle(
                      color: !isGreenActionTab ? colorCons.textBold : colorCons.textPlaceholder,
                      fontSize: 16,
                      fontWeight: !isGreenActionTab ? FontWeight.w700 : FontWeight.w400,
                    ),
                  )
                )
              ]
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                ListView.builder(
                  key: screenTabKey,
                  controller: greenTabController,
                  padding: const EdgeInsets.only(top: 16),
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: input.entries.take(4).length,
                  itemBuilder: (context, index) {
                    final int? initValue = widget.initialData.isNotEmpty ? widget.initialData[index]["quantity"] : null;
                    final e = input.entries.elementAt(index);
                    final int factorId = e.key;
                    final String text = e.value.values.last;
                    return ContributionInput(
                      initValue: initValue.toString(),
                      textHeader: text,
                      factorId: factorId,
                      callBack: (Map data) {
                        widget.callbackUpdateTotalKgCO2e(data);
                      },
                      onlyInteger: factorId < 5,
                      unitValue: e.value['unit_value'],
                    );
                  }
                ),
                ListView.builder(
                  key: massTabKey,
                  padding: const EdgeInsets.only(top: 16),
                  controller: massController,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: input.entries.skip(4).length,
                  itemBuilder: (context, index) {
                    final num initValue = widget.initialData.isNotEmpty ? widget.initialData[4 + index]["quantity"] : null;
                    final e = input.entries.skip(4).elementAt(index);
                    final int factorId = e.key;
                    final String text = e.value.values.last;
                    return ContributionInput(
                      initValue: initValue.toString(),
                      textHeader: text,
                      factorId: factorId,
                      callBack: (Map data) {
                        widget.callbackUpdateTotalKgCO2e(data);
                      },
                      onlyInteger: factorId < 5,
                      unitValue: e.value['unit_value'],
                    );
                  }
                )
              ],
            ),
          )
        ],
      )
    );
  }
}
