import 'dart:async';

import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/tab_bar_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/toast_content.dart';
import 'package:cecr_unwomen/features/home/view/contribution_screen.dart';
import 'package:cecr_unwomen/features/user/repository/user_api.dart';
import 'package:cecr_unwomen/features/user/view/screen/user_management.dart';
import 'package:cecr_unwomen/temp_api.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final ColorConstants colorCons = ColorConstants();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  bool isHouseholdTab = true;
  List<User> data = [];
  bool isLoading = false;
  bool isLoadMore = false;
  FToast fToast = FToast();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(searchContribution);
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
        "text": searchController.text,
        "role_id_filter": isHouseholdTab ? 2 : 3,
      };
      // for smooth (deleted when response time increased)
      await Future.delayed(const Duration(milliseconds: 300));
      UserApi.searchUser(data: payload).then((res) {
        setState(() {
          // case empty field after timer trigger and before has response 
          data = searchController.text.isNotEmpty 
            ? ((res["data"] ?? [])  as List).map((e) => User.fromJson(e)).toList().cast<User>() 
            : [];
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


  @override
  void dispose() {
    searchController.removeListener(searchContribution);
    searchController.dispose();
    _debounce?.cancel();
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
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        physics: const ClampingScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) => UserWidget(
          user: data[index],
          index: index,
          onDelete: (user) {
            UserApi.deleteUser(data: {
              "user_id": user.id,
              "role_id": user.roleId,
            }).then((value) {
              setState(() {
                data.remove(user);
              });
            }).catchError((e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text('Xoá tài khoản thất bại. Vui lòng thử lại sau.', style: ColorConstants().fastStyle(16, FontWeight.w600, const Color(0xFFFFFFFF))),
                    behavior: SnackBarBehavior.fixed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  )
                );
              }
            });
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