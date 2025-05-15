import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/tab_bar_widget.dart';
import 'package:cecr_unwomen/features/user/domain/bloc/fetch_users/fetch_users_cubit.dart';
import 'package:cecr_unwomen/features/user/domain/bloc/fetch_users/fetch_users_state.dart';
import 'package:cecr_unwomen/features/user/repository/user_repository.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final ColorConstants colorCons = ColorConstants();
  final ColorConstants colorConstants = ColorConstants();
  ValueNotifier<bool> isHouseholdTab = ValueNotifier<bool>(true);

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

    return listUsers.isEmpty ? _buildEmptyResult() : ListView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: listUsers.length,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemBuilder: (context, index) {
        return buildUserItem(listUsers[index]);
    });
  }

  Widget buildUserItem(User user) {
    final String name =  "${user.firstName} ${user.lastName}";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12)
      ),
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
              _buildRowItem(text: name, icon: PhosphorIcons.regular.user),
              _buildRowItem(text: user.phoneNumber, icon: PhosphorIcons.regular.phone),
              if (user.dateOfBirth != null)
              _buildRowItem(text: DateFormat('dd-MM-yyyy').format(user.dateOfBirth!),
                icon: PhosphorIcons.regular.cake
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem({required String text, required IconData icon}) {
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