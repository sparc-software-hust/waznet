import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_bloc.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_event.dart';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/user/view/screen/app_info.dart';
import 'package:cecr_unwomen/features/user/view/screen/change_info_screen.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/circle_avatar.dart';
import 'package:cecr_unwomen/widgets/navigation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final ColorConstants colorCons = ColorConstants();

  @override
  Widget build(BuildContext context) {
    final User user = context.watch<AuthenticationBloc>().state.user!;
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CustomCircleAvatar(
                size: 104,
                avatarUrl: user.avatarUrl,
              ),
              const SizedBox(height: 10),
              Text("${user.firstName} ${user.lastName}", style: colorCons.fastStyle(18,FontWeight.w700, const Color(0xFF333334))),
              const SizedBox(height: 10),
              Text(user.roleId == 1 ? "Admin" :
                user.roleId == 2 ? "Hộ gia đình" : "Người thu gom",
                style: colorCons.fastStyle(16, FontWeight.w400, colorCons.textSubHeader)),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                     Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => BlocProvider.value(
                        value: BlocProvider.of<AuthenticationBloc>(this.context),
                        child: const ChangeInfoScreen()))
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("Sửa thông tin", style: colorCons.fastStyle(16, FontWeight.w600, const Color(0xFF4CAF50))),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              NavigationButton(
                text: "Về chúng tôi",
                icon: PhosphorIcons.regular.users,
                onTap: () =>  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => AppInfo())
                  ),
              ),
              NavigationButton(
                text: "Thay đổi mật khẩu",
                icon: PhosphorIcons.regular.lock,
                onTap: () => Utils.showDialogWarningError(context, false, "Chức năng đang được phát triển"),
              ),
              NavigationButton(
                text: "Xác thực sinh trắc học",
                icon: PhosphorIcons.regular.fingerprint,
                hasSwitch: true,
                onToggleSwitch: (p0) {
                  return Utils.showDialogWarningError(context, false, "Chức năng đang được phát triển");
                },
              ),
              NavigationButton(
                text: "Đăng xuất",
                isWarning: true,
                icon: PhosphorIcons.regular.signOut,
                onTap: () {
                  context.read<AuthenticationBloc>().add(LogoutRequest());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
