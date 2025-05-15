import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/authentication.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/toast_content.dart';
import 'package:cecr_unwomen/features/user/domain/bloc/change_password_bloc/change_password_bloc.dart';
import 'package:cecr_unwomen/features/user/domain/bloc/change_password_bloc/change_password_event.dart';
import 'package:cecr_unwomen/features/user/domain/bloc/change_password_bloc/change_password_state.dart';
import 'package:cecr_unwomen/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ColorConstants colorConstants = ColorConstants();
  String newPassword = "";
  String oldPassword = "";
  FToast fToast = FToast();

  @override
  void initState() {
    super.initState();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    final String phoneNumber =
        context.watch<AuthenticationBloc>().state.user?.phoneNumber ?? "";

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
                      child: Icon(
                        PhosphorIcons.regular.arrowLeft,
                        size: 20,
                        color: const Color(0xff29292A),
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(
                      'Thay đổi mật khẩu',
                      style: colorConstants.fastStyle(16, FontWeight.w600, const Color(0xff29292A)),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
              decoration: BoxDecoration(
                color: const Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(12)
              ),
              padding: const EdgeInsets.all(24),
              child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                builder: (context, state) {
                  if (state.status == ProgressStatus.notAuthenticated ||  state.status == ProgressStatus.init) {
                    return Column(
                      children: [
                        Text(
                          "Nhập mật khẩu hiện tại",
                          style: colorConstants.fastStyle(20, FontWeight.w700, const Color(0xff333334)),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                          builder: (context, state) {
                            return CustomTextField(
                              label: "Mật khẩu",
                              placeholder: "Nhập mật khẩu của bạn",
                              keyword: "password",
                              hasBorder: true,
                              validator: (value) {
                                if (state.status ==
                                        ProgressStatus.notAuthenticated ||
                                    state.passwordStatus ==
                                        PasswordStatus.notValid) {
                                  return false;
                                }
                                return true;
                              },
                            errorText: state.status ==
                                    ProgressStatus.notAuthenticated
                                ? "Sai mật khẩu"
                                : "Mật khẩu phải có ít nhất 8 ký tự",
                            isPassword: true,
                            callback: (value, keyword) {
                              setState(() {
                                oldPassword = value;
                              });
                              context
                                  .read<ChangePasswordBloc>()
                                  .add(OnTypePassword(password: value));
                            },
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Quên mật khẩu",
                              style: colorConstants.fastStyle(14, FontWeight.w500, const Color(0xff4CAF50))
                            )
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            context
                                .read<ChangePasswordBloc>()
                                .add(CheckPassWord(phoneNumber: phoneNumber));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Tiếp tục',
                            style: colorConstants.fastStyle(16, FontWeight.w700, const Color(0xffFFFFFF)),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Text(
                        "Nhập mật khẩu mới",
                        style: colorConstants.fastStyle(20, FontWeight.w700, const Color(0xff333334)),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "Mật khẩu mới của bạn phải khác với những mật khẩu đã sử dụng trước đây",
                        style: colorConstants.fastStyle(14, FontWeight.w500, const Color(0xff666667)),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                        builder: (context, state) {
                          bool valid =  state.passwordStatus == PasswordStatus.valid && state.status == ProgressStatus.authenticated;

                          return Column(
                            children: [
                              CustomTextField(
                                prefix: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(
                                    PhosphorIcons.regular.lock,
                                    size: 20,
                                    color: const Color(0xff808082),
                                  ),
                                ),
                                label: "Mật khẩu mới",
                                placeholder: "Nhập mật khẩu mới",
                                keyword: "password",
                                hasBorder: true,
                                validator: (value) {
                                  if (state.passwordStatus == PasswordStatus.sameAsOld || state.passwordStatus ==  PasswordStatus.notValid) {
                                    return false;
                                  }
                                  return true;
                                },
                                errorText: state.passwordStatus == PasswordStatus.sameAsOld
                                    ? "Mật khẩu mới phải khác mật khẩu cũ"
                                    : "Mật khẩu phải có ít nhất 8 ký tự",
                                isPassword: true,
                                callback: (value, keyword) {
                                  setState(() {
                                    newPassword = value;
                                  });
                                  context.read<ChangePasswordBloc>().add(
                                      OnTypeNewPassword(
                                          password: value,
                                          oldPassword: oldPassword));
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 30.0),
                                child: CustomTextField(
                                  prefix: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Icon(
                                      PhosphorIcons.regular.lock,
                                      size: 20,
                                      color: const Color(0xff808082),
                                    ),
                                  ),
                                  label: "Xác nhật mật khẩu mới",
                                  placeholder: "Xác nhận mật khẩu mới",
                                  keyword: "password",
                                  hasBorder: true,
                                  validator: (value) {
                                    if (state.passwordStatus ==  PasswordStatus.notMatch 
                                        || state.passwordStatus == PasswordStatus.notValid
                                        || state.status == ProgressStatus.fail) {
                                          
                                      return false;
                                    }
                                    return true;
                                  },
                                  errorText: state.status == ProgressStatus.fail
                                      ? "Vui lòng thử lại sau"
                                      : state.passwordStatus ==
                                              PasswordStatus.notMatch
                                          ? "Vui lòng đảm bảo rằng mật khẩu mới khớp nhau"
                                          : "Mật khẩu phải có ít nhất 8 ký tự",
                                  isPassword: true,
                                  callback: (value, keyword) {
                                    setState(() {});
                                    context.read<ChangePasswordBloc>().add(
                                        OnTypeConfirmPassword(
                                            confirmPassword: value,
                                            password: newPassword));
                                  },
                                ),
                              ),
                              ElevatedButton(
                                onPressed: valid
                                    ? () async {
                                      context.read<ChangePasswordBloc>().add(
                                        OnSubmitted(
                                            newPassword: newPassword,
                                            oldPassword: oldPassword,
                                            callback: (value) {
                                              fToast.showToast(
                                                child: ToastContent(
                                                  isSuccess: value, 
                                                  title: value ? 'Cập nhật thành công' : 'Cập nhật thất bại. Vui lòng thử lại sau'
                                                ),
                                                gravity: ToastGravity.BOTTOM
                                              );
                                              Navigator.pop(context);
                                            }
                                          )
                                        );                                        
                                    }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: valid
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xffC1C1C2),
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Lưu lại',
                                  style: colorConstants.fastStyle(16, FontWeight.w700, valid ? const Color(0xffFFFFFF) : const Color(0xffF4F4F5)),
                                ),
                              ),
                            ],
                          );
                        }
                      ),
                    ],
                  );
                }
              )
            )
          ]
        )
      )
    );
  }
}
