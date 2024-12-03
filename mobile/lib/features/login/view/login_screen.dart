import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';


class BackgroundWithTransparentBox extends StatelessWidget {
  const BackgroundWithTransparentBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            // height: 400,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            child: child
          )
        )
      )
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool goToPassword = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Material(
        color: Colors.transparent,
        child: BlocProvider(
          create: (context) => LoginBloc(),
          child: BlocListener<LoginBloc, LoginState>(
              listener: (ctxxx, state) {
                if (state.status == LoginStatus.fail) {
                  ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Không thể đăng nhập! Vui lòng kiểm tra lại mật khẩu hoặc số điện thoại.')),
                  );
                }
              },
              child: goToPassword ? PasswordBox(callbackEditPhoneNumber: () => setState(() => goToPassword = false)) 
                : PhoneNumberBox(callbackGoToPassword: () => setState(() => goToPassword = true)),
          )
        ),
      ),
    );
  }
}

class PhoneNumberBox extends StatefulWidget {
  const PhoneNumberBox({super.key, required this.callbackGoToPassword});
  final Function callbackGoToPassword;

  @override
  State<PhoneNumberBox> createState() => _PhoneNumberBoxState();
}

class _PhoneNumberBoxState extends State<PhoneNumberBox> {
  final ColorConstants colorConstants = ColorConstants();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<LoginBloc>().state.phoneNumber;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWithTransparentBox(
      child: Column(
        children: [
          Image.asset("assets/icon/logo_green.png", width: 60, height: 60),
          const SizedBox(height: 24),
          Text("Bắt đầu hành trình\nsống xanh",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w700, color: colorConstants.textHeader,
            )
          ),
          const SizedBox(height: 12),
          Text("Đăng nhập/Đăng ký tài khoản WazNet ngay",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: colorConstants.textSubHeader
            )
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Số điện thoại",
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: colorConstants.textSubHeader
              )
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorConstants.border)
            ),
            child: Row(
              children: [
                Container(
                  width: 82,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    border: Border(
                      right: BorderSide(color: colorConstants.border)
                    ) 
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/vietnam.png", width: 20, height: 20),
                      const SizedBox(width: 8),
                      Text("+84", style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500, color: colorConstants.textHeader
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoTextField(
                    cursorColor: colorConstants.bgClickable,
                    cursorHeight: 16,
                    controller: _controller,
                    onTapOutside: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    padding: const EdgeInsets.only(left: 12),
                    placeholder: "Nhập số điện thoại của bạn",
                    keyboardType: TextInputType.phone,
                    placeholderStyle: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textPlaceholder, fontFamily: "Inter"
                    ),
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textHeader, fontFamily: "Inter"
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    onChanged: (value) {
                      context.read<LoginBloc>().add(LoginPhoneNumberChanged(phoneNumber: value));
                      setState(() {});
                    },
                    suffix: _controller.text.isEmpty ? null : InkWell(
                      onTap: () {
                        _controller.clear();
                        context.read<LoginBloc>().add(LoginPhoneNumberChanged(phoneNumber: _controller.text));
                        setState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Icon(PhosphorIcons.regular.x, size: 20, color: colorConstants.textHeader)),
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                )
              ],  
            ),
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (context) {
              final bool isValid = context.select((LoginBloc bloc) => bloc.state.isValid);
              return InkWell(
                onTap: !isValid ? null : () {
                  widget.callbackGoToPassword();
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isValid ? colorConstants.bgClickable : colorConstants.bgDisabled,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text("Tiếp tục",
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white
                      )
                    ),
                  ),
                ),
              );
            }
          )
        ],
      ),
    );
  }
}

class PasswordBox extends StatefulWidget {
  const PasswordBox({super.key, required this.callbackEditPhoneNumber});
  final Function callbackEditPhoneNumber;

  @override
  State<PasswordBox> createState() => _PasswordBoxState();
}

class _PasswordBoxState extends State<PasswordBox> {
  final ColorConstants colorConstants = ColorConstants();
  final TextEditingController _controller = TextEditingController();
  bool showPassword = false;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BackgroundWithTransparentBox(
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () => widget.callbackEditPhoneNumber(),
            child: Icon(PhosphorIcons.regular.arrowLeft, size: 24, color: colorConstants.textHeader)),
        ),
        Text("Nhập mật khẩu",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w700, color: colorConstants.textHeader
          )
        ),
        const SizedBox(height: 12),
        Text("Bạn đang đăng nhập với số điện thoại",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: colorConstants.textSubHeader
          )
        ),
        Builder(
          builder: (context) {
            final String phoneNumber = context.select((LoginBloc bloc) => bloc.state.phoneNumber);
            return Text(phoneNumber,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: colorConstants.textSubHeader
              )
            );
          }
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Mật khẩu",
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: colorConstants.textSubHeader
            )
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorConstants.border)
          ),
          child: CupertinoTextField(
            controller: _controller,
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
            },
            cursorHeight: 16,
            cursorColor: colorConstants.bgClickable,
            autofocus: true,
            obscureText: showPassword ? false : true,
            padding: const EdgeInsets.only(left: 12),
            placeholder: "Nhập mật khẩu của bạn",
            prefix: Container(
              margin: const EdgeInsets.only(left: 12),
              child: Icon(PhosphorIcons.regular.lock, size: 20, color: colorConstants.textPlaceholder)),
            placeholderStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textPlaceholder, fontFamily: "Inter",
            ),
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textHeader, fontFamily: "Inter"
            ),
            onChanged: (value) {
              context.read<LoginBloc>().add(LoginPasswordChanged(password: value));
              setState(() {});
            },
            suffix: InkWell(
              onTap: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                child: Icon(showPassword ? PhosphorIcons.regular.eye :
                  PhosphorIcons.regular.eyeSlash, size: 20, color: colorConstants.textHeader)
                ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Builder(
          builder: (context) {
            final bool isLoading = context.select((LoginBloc bloc) => bloc.state.status == LoginStatus.inProcess);
            return InkWell(
              onTap: () {
                context.read<LoginBloc>().add(LoginSubmitted());
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: colorConstants.bgClickable,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isLoading ? const CupertinoActivityIndicator() : 
                  const Text("Đăng nhập",
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white
                    )
                  ),
                ),
              ),
            );
          }
        )
      ]) 
    );
  }
}


