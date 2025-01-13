import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_bloc.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_event.dart';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/home/view/component/toast_content.dart';
import 'package:cecr_unwomen/features/user/repository/user_api.dart';
import 'package:cecr_unwomen/features/user/view/bloc/change_password_bloc/change_password_bloc.dart';
import 'package:cecr_unwomen/features/user/view/screen/app_info.dart';
import 'package:cecr_unwomen/features/user/view/screen/change_info_screen.dart';
import 'package:cecr_unwomen/features/user/view/screen/change_password_screen.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/circle_avatar.dart';
import 'package:cecr_unwomen/widgets/navigation_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final ColorConstants colorCons = ColorConstants();
  DateTime? remindedTime;
  DateTime trackingTime = DateTime.now();
  FToast fToast = FToast();

  @override
  void initState() {
    super.initState();
    final User user = context.read<AuthenticationBloc>().state.user!;
    remindedTime = user.timeReminded;
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    final User user = context.watch<AuthenticationBloc>().state.user!;

    void updateTimeReminded() async {
      Map updatedUser = await UserApi.setTimeReminded({'time_reminded': remindedTime?.toIso8601String()});
      if (context.mounted) {
        if (updatedUser.isNotEmpty) {
          context.read<AuthenticationBloc>().add(UpdateInfo(User.fromJson(updatedUser)));
          fToast.showToast(
            child: const ToastContent(
              isSuccess: true, 
              title: 'Cập nhật thành công'
            ),
            gravity: ToastGravity.BOTTOM
          );
        } else {
          fToast.showToast(
            child: const ToastContent(
              isSuccess: false, 
              title: 'Cập nhật thất bại. Vui lòng thử lại sau'
            ),
            gravity: ToastGravity.BOTTOM
          );
        }
      }
    }

    void showTimePicker() => Utils.showDatePicker(
      context: context,
      onCancel: () {
        trackingTime = DateTime.now();
        Navigator.pop(context);
      },
      onSave: () async {
        setState(() {
          remindedTime = trackingTime;
        });
        Navigator.pop(context);
        
        updateTimeReminded();       
      },
      onDateTimeChanged: (time) {
        trackingTime = time;
      },
      mode: CupertinoDatePickerMode.time,
      initDate: user.timeReminded ?? trackingTime
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                ClipRRect(
                borderRadius: BorderRadius.circular(104),
                child: CustomCircleAvatar(
                    size: 104,
                    avatarUrl: user.avatarUrl,
                  ),
              ),
                const SizedBox(height: 10),
                Text("${user.firstName} ${user.lastName}", style: colorCons.fastStyle(18,FontWeight.w700, const Color(0xFF333334))),
                const SizedBox(height: 10),
                Text(
                    user.roleId == 1
                        ? "Admin"
                        : user.roleId == 2
                            ? "Hộ gia đình"
                            : "Người thu gom",
                    style: colorCons.fastStyle(
                        16, FontWeight.w400, colorCons.textSubHeader)),
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChangeInfoScreen()));
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
                if (user.roleId != 1)
                NavigationButton(
                  text: "Nhắc nhập liệu",
                  icon: PhosphorIcons.regular.alarm,
                  hasSwitch: true,
                  valueSwitch: user.timeReminded != null,
                  onToggleSwitch: (toggle) async {
                    if (toggle) {
                      showTimePicker();
                      updateTimeReminded();
                    } else {
                      // tat switch -> reset time
                      if (!toggle && remindedTime != null) {
                        remindedTime = null;
                      }
                      updateTimeReminded();
                    }
                  },
                  subTitleWidget: Column(
                    children: [
                      Text(
                        "Ứng dụng sẽ gửi thông báo nhắc bạn nhập dữ liệu mỗi ngày",
                        style: colorCons.fastStyle(14, FontWeight.w400, const Color(0xff666667)),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        child: Divider(color: Color(0xffF4F4F5)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Thời gian", style: colorCons.fastStyle(16, FontWeight.w600, const Color(0xff333334)),),
                          InkWell(
                            onTap: showTimePicker,
                            child: Text(remindedTime == null ? "--:--" : DateFormat("HH:mm").format(remindedTime!) , 
                              style: colorCons.fastStyle(14, FontWeight.w500, const Color(0xff4CAF50)),
                            )
                          )
                        ],
                      )
                    ],
                  ),
                ),
                NavigationButton(
                  text: "Về chúng tôi",
                  icon: PhosphorIcons.regular.users,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AppInfo())),
                ),
                NavigationButton(
                  text: "Thay đổi mật khẩu",
                  icon: PhosphorIcons.regular.lock,
                  onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => ChangePasswordBloc(),
                                child: const ChangePasswordScreen())));
                    },
                ),
                // NavigationButton(
                //   text: "Xác thực sinh trắc học",
                //   icon: PhosphorIcons.regular.fingerprint,
                //   hasSwitch: true,
                //   onToggleSwitch: (p0) => Utils.showDialogWarningError(
                //       context, false, "Chức năng đang được phát triển"),
                // ),
                NavigationButton(
                  text: "Đăng xuất",
                  isWarning: true,
                  icon: PhosphorIcons.regular.signOut,
                  onTap: () {
                    context.read<AuthenticationBloc>().add(LogoutRequest());
                  },
                ),
                NavigationButton(
                  text: "Xóa tài khoản",
                  isWarning: true,
                  icon: PhosphorIcons.regular.userMinus,
                  onTap: () {
                    context.read<AuthenticationBloc>().add(DeleteAccount());
                    // context.read<AuthenticationBloc>().add(LogoutRequest());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
