import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_bloc.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_event.dart';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/circle_avatar.dart';
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
                  onTap: () => Utils.showDialogWarningError(context, false, "Chức năng đang được phát triển"),
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
              UserInfoItem(
                text: "Về chúng tôi",
                icon: PhosphorIcons.regular.users,
                onTap: () => Utils.showDialogWarningError(context, false, "Chức năng đang được phát triển"),
              ),
              UserInfoItem(
                text: "Đổi mật khẩu",
                icon: PhosphorIcons.regular.lock,
                onTap: () => Utils.showDialogWarningError(context, false, "Chức năng đang được phát triển"),
              ),
              UserInfoItem(
                text: "Đăng xuất",
                isLogout: true,
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

class UserInfoItem extends StatelessWidget {
  const UserInfoItem({super.key, required this.text, required this.icon, this.isLogout =  false, this.isBiometric = false, this.onTap});
  final String text;
  final IconData icon;
  final bool isLogout;
  final bool isBiometric;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isLogout ? const Color(0xFFFF4F3F) : const Color(0xFF4CAF50);
    final Color iconBgColor = isLogout ? const Color(0xFFFFE8D8) : const Color(0xFFE8F5E9).withOpacity(0.7);
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap == null ? null : onTap!(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(text, style: TextStyle(
                    color: !isLogout ? const Color(0xFF333334) : const Color(0xFFFF4F3F),
                    fontSize: 16,
                    fontWeight: FontWeight.w600)
                  ),
                ),
                Icon(PhosphorIcons.regular.caretRight, size: 20, color: const Color(0xFF4D4D4E)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
