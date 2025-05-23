import 'dart:async';

import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/tab_bar_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/toast_content.dart';
import 'package:cecr_unwomen/features/home/view/contribution_screen.dart';
import 'package:cecr_unwomen/temp_api.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SearchContributionScreen extends StatefulWidget {
  const SearchContributionScreen({super.key});

  @override
  State<SearchContributionScreen> createState() => _SearchContributionScreenState();
}

class _SearchContributionScreenState extends State<SearchContributionScreen> {
  final ColorConstants colorCons = ColorConstants();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  bool isHouseholdTab = true;
  DateTime date = DateTime.now();
  List data = [];
  bool isLoading = false;
  bool isLoadMore = false;
  FToast fToast = FToast();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(searchContribution);
    scrollController.addListener(scrollListener);
    fToast.init(context);
  }

  searchContribution(){
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (searchController.text.isEmpty) {
      setState(() {
        data = [];
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!isLoading) {
        setState(() {
          isLoading = true;
        });
      }
      Map payload = {
        "name": searchController.text,
        "role_id_search": isHouseholdTab ? 2 : 3,
        "date": date.toIso8601String()
      };
      // for smooth (deleted when response time increased)
      await Future.delayed(const Duration(milliseconds: 300));
      TempApi.searchContribution(payload).then((res) {
        setState(() {
          // case empty field after timer trigger and before has response 
          data = searchController.text.isNotEmpty ? res["data"] : [];
          isLoading = false;
        });
      });
    });
  }

  void changeBar() {
    setState(() {
      isLoading = true;
      isHouseholdTab = !isHouseholdTab;
    });
    searchContribution();
  }

  scrollListener() async {
    if (mounted && scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      final date = DateTime.tryParse(data.last["date"]);
      if (date == null) return;
      setState(() {
        isLoadMore = true;
      });
      // for smooth (deleted when response time increased)
      await Future.delayed(const Duration(milliseconds: 300));
      TempApi.searchContribution({
          "name": searchController.text,
          "role_id_search": isHouseholdTab ? 2 : 3,
          // for load more -> decrease by 1 day because api using <= to avoid loop result
          "date": date.add(const Duration(days: -1)).toIso8601String()
        })
        .then((res) {
          setState(() {
            data.addAll(res["data"]);
            isLoadMore = false;
          });
      });
    }
  }

  @override
  void dispose() {
    searchController.removeListener(searchContribution);
    searchController.dispose();
    _debounce?.cancel();
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      color: const Color(0xffF4F4F5),
      child: Column(
        children: [
          HeaderWidget(
            height: 155,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(PhosphorIcons.regular.arrowLeft, size: 20, color: const Color(0xff1D2939))),
                    const SizedBox(width: 12),
                    Text("Tìm kiếm", style: colorCons.fastStyle(16, FontWeight.w600, const Color(0xFF101828))),
                  ],
                ), 
                const SizedBox(height: 12),
                TextFormField(
                  style: colorCons.fastStyle(16, FontWeight.w400,const Color(0xff333334)),
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(PhosphorIcons.regular.magnifyingGlass, size: 20, color: const Color(0xff808082)),
                    suffixIcon: searchController.text.isNotEmpty 
                      ? InkWell(
                        onTap: () => searchController.clear(),
                        child: Icon(PhosphorIcons.regular.x, size: 20, color: const Color(0xff333334))) 
                      : null,
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Tìm kiếm theo tên",
                    hintStyle: colorCons.fastStyle(14, FontWeight.w400,const Color(0xffC1C1C2)),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF348A3A)),
                    ),
                  ),
                ),   
              ],
            )
          ),
          BarWidget(isHousehold: isHouseholdTab, changeBar: changeBar),
          _buildContent(),
          _buildLoadMoreIndicator(),
        ],
      ),
    );
  }

   Widget _buildContent() {
    if (searchController.text.isNotEmpty && data.isEmpty && !isLoading) {
      return _buildEmptySearchResult();
    }
    if (searchController.text.isEmpty && data.isEmpty) {
      return _buildInitialSearchState();
    }
    if (isLoading) {
      return Expanded(child: Utils.buildShimmerEffectshimmerEffect(context));
    }
    return _buildSearchResults();
  }

  Widget _buildEmptySearchResult() {
    Size screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        SizedBox(height: screenSize.height * 0.1),
        Image.asset(
          "assets/images/empty_box.png",
          height: screenSize.height * 0.2, 
          width: screenSize.height * 0.2,
          fit: BoxFit.fill,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            "\"${searchController.text}\" không khớp với bất kỳ kết quả nào. \nVui lòng thử lại.",
            style: colorCons.fastStyle(14, FontWeight.w400, const Color(0xff808082)),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildInitialSearchState() {
    Size screenSize = MediaQuery.of(context).size;

    return Center(
      child: Column(
        children: [
          SizedBox(height: screenSize.height * 0.1),
          Image.asset(
            "assets/images/search_user.png", 
            height: screenSize.height * 0.2, 
            width: screenSize.height * 0.2,
            fit: BoxFit.fill,
          ),
          Text(
            "Bạn đang tìm kiếm ai?",
            style: colorCons.fastStyle(16, FontWeight.w600, const Color(0xff666667)),
          ),
          Text(
            "Nhập để tìm kiếm và xem kết quả tương tự",
            style: colorCons.fastStyle(14, FontWeight.w400, const Color(0xff808082)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        physics: const ClampingScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) => UserContributionWidget(
          index: index,
          oneDayData: {...data[index], "role_id": isHouseholdTab ? 2 : 3},
          onReload: (isLoad) => setState(() => isLoading = isLoad),
          onDelete:(success) {
            if (success) {
              setState(() => data.removeAt(index));
            }
            fToast.showToast(
              child: ToastContent(
                isSuccess: success,
                title: success ? "Xoá dữ liệu thành công" : "Xoá dữ liệu thất bại. Thử lại sau",
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return SizedBox(
      height: 30,
      child: isLoadMore
        ? const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          )
        : null,
    );
  }
}