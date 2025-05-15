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
              // disable scroll for zoom
              physics: const NeverScrollableScrollPhysics(),
              children: [
                HouseholdContributionTab(
                  key: screenTabKey,
                  householdInput: input,
                  callbackUpdateTotalKgCO2e: widget.callbackUpdateTotalKgCO2e,
                  initialData: widget.initialData
                ),
                HouseholdContributionTab(
                  isMassTab: true,
                  key: massTabKey,
                  householdInput: input,
                  callbackUpdateTotalKgCO2e: widget.callbackUpdateTotalKgCO2e,
                  initialData: widget.initialData
                )
              ],
            ),
          )
        ],
      )
    );
  }
}

class HouseholdContributionTab extends StatefulWidget {
  const HouseholdContributionTab({super.key,
    required this.householdInput,
    required this.callbackUpdateTotalKgCO2e,
    this.initialData = const [],
    this.isMassTab = false
  });

  final Map householdInput;
  final Function callbackUpdateTotalKgCO2e;
  final List initialData;
  final bool isMassTab;

  @override
  State<HouseholdContributionTab> createState() => _HouseholdContributionTabState();
}

class _HouseholdContributionTabState extends State<HouseholdContributionTab> with AutomaticKeepAliveClientMixin {
  // sử dụng automaticKeepAliveClientMixin để giữ trạng thái của tab khi chuyển qua lại giữa các tab
  Map get input => widget.householdInput;
  final ScrollController tabScrollController = ScrollController();

  @override void dispose() {
    super.dispose();
    tabScrollController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final factors = widget.isMassTab ? input.entries.skip(4) : input.entries.take(4);
    return ListView.builder(
      key: widget.key,
      controller: tabScrollController,
      padding: const EdgeInsets.only(top: 16),
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: factors.length,
      itemBuilder: (context, index) {
        final int factorIndex = widget.isMassTab ? 4 + index : index;
        final num? initValue = widget.initialData.isNotEmpty ? widget.initialData[factorIndex]["quantity"] : null;
        final e = input.entries.elementAt(factorIndex);
        final int factorId = e.key;
        final String text = "${index + 1}. ${e.value.values.last}" ;

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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
