import 'dart:io';

import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/tab_bar_widget.dart';
import 'package:cecr_unwomen/features/user/domain/bloc/fetch_users/fetch_users_cubit.dart';
import 'package:cecr_unwomen/features/user/domain/bloc/fetch_users/fetch_users_state.dart';
import 'package:cecr_unwomen/features/user/view/screen/search_user_screen.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/circle_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final ColorConstants colorCons = ColorConstants();
  final ColorConstants colorConstants = ColorConstants();
  ValueNotifier<bool> isHouseholdTab = ValueNotifier<bool>(true);
  final PageStorageKey householdTabKey = const PageStorageKey('householdTab');
  final PageStorageKey scraperTabKey = const PageStorageKey('scraperTab');

  @override
  void initState() {
    super.initState();
    context.read<FetchUsersCubit>().fetchUsers(roleId: isHouseholdTab.value ? 2 : 3);
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            HeaderWidget(
              child: Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Row(
                  children: [
                    InkWell(
                      child: Icon(PhosphorIcons.regular.arrowLeft, size: 20, color: const Color(0xff29292A),),
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16,),
                    Text(
                      "Quản lý người đóng góp",
                      style: colorConstants.fastStyle(16, FontWeight.w600, const Color(0xff29292A)),
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: isHouseholdTab, 
              builder: (context, value, child) {
                return BarWidget(
                  isHousehold: value, 
                  changeBar: () {
                    isHouseholdTab.value = !value;
                    context.read<FetchUsersCubit>().fetchUsers(roleId: isHouseholdTab.value ? 2 : 3);
                  },
                );
            }),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  Text("Danh sách", style: colorCons.fastStyle(14, FontWeight.w600, const Color(0xff666667))),
                  const Spacer(),
                  Material(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xffE3E3E5),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return const SearchUserScreen();
                          })
                        ).then((_) {
                          // go back -> trigger load lai data
                          if (context.mounted) {
                            context.read<FetchUsersCubit>().fetchUsers(roleId: isHouseholdTab.value ? 2 : 3, reload: true);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(PhosphorIcons.regular.magnifyingGlass, size: 20, color: const Color(0xff4D4D4E),),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<FetchUsersCubit, FetchUsersState>(
                builder: (context, state) {
                  switch (state.status) {
                    case FetchStatus.loading: return Utils.buildShimmerEffectshimmerEffect(context);
                    case FetchStatus.success: return _buildListUsers(state: state, isHousehold: isHouseholdTab.value);
                    default: return const SizedBox();
                  } 
                }
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildListUsers({required FetchUsersState state, required bool isHousehold}) {
    List<User> listUsers = isHousehold ? state.householdUsers : state.scraperUsers;

    return listUsers.isEmpty 
      ? _buildEmptyResult() 
      : isHousehold 
        ? ListHouseHoldUser(key: householdTabKey)
        : ListScraperUser(key: scraperTabKey);
  }

  Widget _buildEmptyResult() {
    Size screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        const Spacer(),
        Image.asset(
          "assets/images/empty_box.png",
          height: screenSize.height * 0.2, 
          width: screenSize.height * 0.2,
          fit: BoxFit.fill,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            "Không có dữ liệu",
            style: colorCons.fastStyle(14, FontWeight.w400, const Color(0xff808082)),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer()
      ],
    );
  }
}

class ListHouseHoldUser extends StatefulWidget {
  const ListHouseHoldUser({super.key});

  @override
  State<ListHouseHoldUser> createState() => _ListHouseHoldUserState();
}

class _ListHouseHoldUserState extends State<ListHouseHoldUser> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }


  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      final FetchUsersState fetchingState = context.read<FetchUsersCubit>().state;
      if (fetchingState.hasMoreHousehold && !fetchingState.isLoadingMoreHousehold) {
        context.read<FetchUsersCubit>().loadMoreUsers(roleId: 2);
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchUsersCubit, FetchUsersState>(
      builder: (context, state) {
        final List<User> listUsers = state.householdUsers;

        return Column(
          children: [
            Expanded(
              child: RawScrollbar(
                controller: scrollController,
                padding: EdgeInsets.zero,
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(8),
                thumbColor:const Color(0xFFC1C1C2),
                child: ListView.builder(
                  controller: scrollController,
                  key: widget.key,
                  physics: const ClampingScrollPhysics(),
                  itemCount: listUsers.length + 5,  
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemBuilder: (context, index) {
                    if (index >= listUsers.length) {
                      if (!state.hasMoreHousehold && !state.isLoadingMoreHousehold && index == listUsers.length) {
                        return const Center(
                          child: Text(
                            "----- Không còn dữ liệu -----", style: TextStyle(
                            color: Color(0xFF808082),
                            fontSize: 12,
                            fontFamily: "Inter",
                          )),
                        );
                      }
                      if (!state.isLoadingMoreHousehold) return const SizedBox();

                      return Shimmer.fromColors(
                        baseColor:  const Color(0xffe2e5e8),
                        highlightColor:  Colors.grey.shade100,
                        enabled: true,
                        child: Container(
                          height: 70,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)
                          ),
                        )
                      );
                    }
                    return UserWidget(
                      user: listUsers[index], 
                      index: index,
                      onDelete: (user) {
                        context.read<FetchUsersCubit>().deleteUser(
                        userId: user.id,
                        roleId: user.roleId,
                        onError: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(seconds: 2),
                            content: Text('Xoá tài khoản thất bại. Vui lòng thử lại sau.', style: ColorConstants().fastStyle(16, FontWeight.w600, const Color(0xFFFFFFFF))),
                            behavior: SnackBarBehavior.fixed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ));
                        }
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        );
      }
    );
  }
}

// tach 2 widget de truyen 2 page storage key de giu scroll pos
class ListScraperUser extends StatefulWidget {
  const ListScraperUser({super.key});

  @override
  State<ListScraperUser> createState() => _ListScraperUserState();
}

class _ListScraperUserState extends State<ListScraperUser> {
    final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }


  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      final FetchUsersState fetchingState = context.read<FetchUsersCubit>().state;
      if (fetchingState.hasMoreScraper && !fetchingState.isLoadingMoreScraper) {
        context.read<FetchUsersCubit>().loadMoreUsers(roleId: 3);
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchUsersCubit, FetchUsersState>(
      builder: (context, state) {
        final List<User> listUsers = state.scraperUsers;

        return Column(
          children: [
            Expanded(
              child: RawScrollbar(
                controller: scrollController,
                padding: EdgeInsets.zero,
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(8),
                thumbColor:const Color(0xFFC1C1C2),
                child: ListView.builder(
                  controller: scrollController,
                  key: widget.key,
                  physics: const ClampingScrollPhysics(),
                  itemCount: listUsers.length + 5,  
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemBuilder: (context, index) {
                    if (index >= listUsers.length) {
                      if (!state.hasMoreScraper && !state.isLoadingMoreScraper && index == listUsers.length) {
                        return const Center(
                          child: Text(
                            "----- Không còn dữ liệu -----", style: TextStyle(
                            color: Color(0xFF808082),
                            fontSize: 12,
                            fontFamily: "Inter",
                          )),
                        );
                      }
                      if (!state.isLoadingMoreScraper) return const SizedBox();

                      return Shimmer.fromColors(
                        baseColor:  const Color(0xffe2e5e8),
                        highlightColor:  Colors.grey.shade100,
                        enabled: true,
                        child: Container(
                          height: 70,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)
                          ),
                        )
                      );
                    }
                    return UserWidget(
                      user: listUsers[index], 
                      index: index,
                      onDelete: (user) {
                         context.read<FetchUsersCubit>().deleteUser(
                          userId: user.id,
                          roleId: user.roleId,
                          onError: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: const Duration(seconds: 2),
                              content: Text('Xoá tài khoản thất bại. Vui lòng thử lại sau.', style: ColorConstants().fastStyle(16, FontWeight.w600, const Color(0xFFFFFFFF))),
                              behavior: SnackBarBehavior.fixed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ));
                          }
                        );
                      },
                    );
                }),
              ),
            ),
          ],
        );
      }
    );
  }
}

class UserWidget extends StatelessWidget {
  final int index;
  final Function(User) onDelete;
  final User user;
  const UserWidget({super.key, required this.user, required this.index, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final String name =  "${user.firstName} ${user.lastName}";
    Widget buildRowItem({required String text, required IconData icon}) {
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

    return Dismissible(
        key: ValueKey<int>(index),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          void onDeleteUser() async {
            if (context.mounted) {
              Navigator.pop(context);
            }
            onDelete(user);
          }

          return showDialog(
            context: context,
            builder: (context) => Platform.isAndroid 
            ? AlertDialog(
              backgroundColor: const Color(0xFFFFFFFF),
              title: const Text("Xoá tài khoản ?", style: TextStyle(color: Color(0xff333334), fontSize: 18, fontWeight: FontWeight.w700)),
              content: Text("Bạn chắc chắn muốn xoá tài khoản ${user.firstName} ${user.lastName} ?", style: const TextStyle(color: Color(0xff333334), fontSize: 14, fontWeight: FontWeight.w400)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Huỷ bỏ", style: TextStyle(color: Color(0xff333334), fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                TextButton(
                  onPressed: onDeleteUser,
                  child: const Text("Xoá", style: TextStyle(color: Color(0xffDB2E2E), fontSize: 14, fontWeight: FontWeight.w600),),
                ),
              ],
            )
            : CupertinoAlertDialog(
              title: const Text("Xoá tài khoản ?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: "Inter")),
              content: Text("Bạn chắc chắn muốn xoá tài khoản ${user.firstName} ${user.lastName} ?", style: const TextStyle(fontSize: 14, fontFamily: "Inter")),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: onDeleteUser,
                  child: const Text("Xoá", style: TextStyle(color: Color(0xffDB2E2E), fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Inter"),),
                ),
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Huỷ bỏ", style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Inter"))
                )
              ]),
          );
        },
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xffDB2E2E),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Icon(PhosphorIcons.regular.trashSimple, color: Colors.white, size: 35),
        ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context, 
                builder: (context) {
                  return UserInfoModal(user: user);
                }
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomCircleAvatar(
                    avatarUrl: user.avatarUrl,
                    size: 56,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildRowItem(text: name, icon: PhosphorIcons.regular.user),
                      buildRowItem(text: user.phoneNumber, icon: PhosphorIcons.regular.phone),
                      if (user.dateOfBirth != null)
                      buildRowItem(text: DateFormat('dd-MM-yyyy').format(user.dateOfBirth!),
                        icon: PhosphorIcons.regular.cake
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




class UserInfoModal extends StatelessWidget {
  final User user;
  const UserInfoModal({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String name =  "${user.firstName} ${user.lastName}";

    Widget buildRowItem({required String title, required IconData icon, required String? value, bool needEmphasis = false, bool needBorder = true}) {
      return Container(
        margin: !needBorder ? null : const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: !needBorder ? null : const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFDDE1E7)
            )
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF333334)),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(
                  color: Color(0xFF666667),
                  fontSize: 16,
                  fontWeight: FontWeight.w400
                )),
              ],
            ),
            Text(value ?? "Chưa đặt", style: TextStyle(
              color: needEmphasis ? const Color(0xFF4CAF50) : const Color(0xFF333334) ,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: needEmphasis ? TextDecoration.underline : null,
              decorationColor: const Color(0xFF4CAF50)
            ))
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Thông tin người đóng góp", style: ColorConstants().fastStyle(16, FontWeight.w700, ColorConstants().textBold)),
          const SizedBox(height: 20),
          CustomCircleAvatar(size: 100, avatarUrl: user.avatarUrl),
          const SizedBox(height: 6,),
          Text("  $name", style: ColorConstants().fastStyle(16, FontWeight.w700, const Color(0xFF333334))),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFEDEEEE),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildRowItem(title: "Tên", icon: PhosphorIcons.regular.user, value: name),
                buildRowItem(title: "Số điện thoại", icon: PhosphorIcons.regular.phone, value: user.phoneNumber, needEmphasis: true),
                if (user.dateOfBirth != null)
                buildRowItem(title: "Ngày sinh", icon: PhosphorIcons.regular.cake, value: user.dateOfBirth == null ? null : DateFormat('dd-MM-yyyy').format(user.dateOfBirth!)),
                buildRowItem(title: "Giới tính", icon: PhosphorIcons.regular.genderIntersex, value: convertGenderToString(user.gender)),
                buildRowItem(title: "Địa chỉ", icon: PhosphorIcons.regular.mapPin, value: user.location, needBorder: false),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}