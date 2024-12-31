import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/repository/authentication_repository.dart';
import 'package:cecr_unwomen/features/home/view/component/toast_content.dart';
import 'package:cecr_unwomen/features/login/login.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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
  bool goToRegister = false;

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
              : goToRegister ? RegisterBox(
                callbackEditPhoneNumber: () => setState(() => goToRegister = false)
              )
              : PhoneNumberBox(
                  callbackGoToPassword: () => setState(() => goToPassword = true),
                  callbackGoToRegister: () => setState(() => goToRegister = true)
              ),
          )
        ),
      ),
    );
  }
}

class PhoneNumberBox extends StatefulWidget {
  const PhoneNumberBox({super.key, required this.callbackGoToPassword, required this.callbackGoToRegister});
  final Function callbackGoToPassword;
  final Function callbackGoToRegister;

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
          Text("Đăng nhập/Đăng ký tài khoản WazNet",
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
                    placeholder: "Nhập số điện thoại",
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
          ),

          const SizedBox(height: 24),
          Text("Chưa có tài khoản?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: colorConstants.textSubHeader
            )
          ),

          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              widget.callbackGoToRegister();
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colorConstants.bgClickable,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text("Đăng ký tài khoản mới",
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white
                  )
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RegisterBox extends StatefulWidget {
  const RegisterBox({super.key, required this.callbackEditPhoneNumber});
  final Function callbackEditPhoneNumber;

  @override
  State<RegisterBox> createState() => _RegisterBoxState();
}

class _RegisterBoxState extends State<RegisterBox> {
  final ColorConstants colorConstants = ColorConstants();
  DateTime? _selectedDate;
  bool isLoading = false;
  FToast fToast = FToast();

  Map registerData = {
    "first_name": "",
    "last_name": "",
    "phone_number": "",
    "password": "",
    "birth": "",
    "gender": 1,
    "role_id": 2,
    "location": ""
    // "avatar_url": avatarUrl,
    // "email": email,
  };

  @override
  void initState() {
    super.initState();
    fToast.init(context);
    registerData["birth"] = _selectedDate;
  }

  _callRegisterApi() async {
    print('registerApi: $registerData');
    final Map res = await AuthRepository.register(registerData);
    final bool isSuccess = res["success"];
    if (!isSuccess) {
      fToast.showToast(
        child: ToastContent(
          isSuccess: false, 
          title: res["message"] ?? 'Không thể đăng ký! Vui lòng kiểm tra lại thông tin.'
        ),
        gravity: ToastGravity.BOTTOM
      );
    //   ScaffoldMessenger.of(context)
    //   ..hideCurrentSnackBar()
    //   ..showSnackBar(
    //     SnackBar(content: Text(res["message"] ?? 'Không thể đăng ký! Vui lòng kiểm tra lại thông tin.')),
    //   );
    }
  }

  _buildHeaderWidget(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      alignment: Alignment.centerLeft,
      child: Text(text,
        style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: colorConstants.textSubHeader
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = registerData["first_name"].isNotEmpty && registerData["last_name"].isNotEmpty && _selectedDate != null && registerData["phone_number"].length == 10 && registerData["password"].length >= 8;

    return BackgroundWithTransparentBox(
      child: Column(children: [
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {
              widget.callbackEditPhoneNumber();
            },
            child: Icon(PhosphorIcons.regular.arrowLeft, size: 24, color: colorConstants.textHeader)),
        ),
        Text("Hoàn tất đăng ký",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w700, color: colorConstants.textHeader
          )
        ),
        const SizedBox(height: 12),
        Text("Bước cuối cùng để bắt đầu trải nghiệm WazNet",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: colorConstants.textSubHeader
          )
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: "Họ",
                placeholder: "họ",
                keyword: "first_name",
                hasBorder: false,
                callback: (value, keyword) {
                  setState(() { registerData["first_name"] = value.trim(); });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                placeholder: "tên",
                label: "Tên",
                keyword: "last_name",
                hasBorder: false,
                callback: (value, keyword) {
                  setState(() { registerData["last_name"] = value.trim(); });
                  // context.read<LoginBloc>().add(LoginNameChanged(name: value));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildHeaderWidget("Ngày sinh"),
        InkWell(
          radius: 8,
          // canRequestFocus: false,
          onTap: () => Utils.showDatePicker(
            context: context,
            initDate: _selectedDate ,
            onCancel: () {
              setState(() {
                _selectedDate = null;
              });
              registerData["birth"] = "";
              Navigator.pop(context);
            },
            onSave: () {
              setState(() {
                _selectedDate = _selectedDate ?? DateTime.now();    
              });
              registerData["birth"] = _selectedDate!.toIso8601String();
              Navigator.pop(context);
            },
            onDateTimeChanged: (date) {
              _selectedDate = date;
            }
          ),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_selectedDate != null)
                  Text(
                    "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    style: const TextStyle(
                      color: Color(0xFF333334),
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                  ) else Text("Chọn ngày sinh",
                    style: TextStyle(
                      color: colorConstants.textHeader,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                  ),
                  Icon(PhosphorIcons.regular.calendarBlank, size: 20, color: colorConstants.bgClickable),
                ],
              ),
            )
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: "Số điện thoại",
          placeholder: "số điện thoại",
          isOnlyNumber: true,
          keyword: "phone_number",
          hasBorder: false,
          callback: (value, keyword) {
            setState(() { registerData["phone_number"] = value; });
          },
        ),

        const SizedBox(height: 12),
        CustomTextField(
          label: "Mật khẩu",
          placeholder: "mật khẩu",
          keyword: "password",
          hasBorder: false,
          isPassword: true,
          callback: (value, keyword) {
            setState(() { registerData["password"] = value; });
          },
        ),

        const SizedBox(height: 12),
        _buildHeaderWidget("Giới tính"),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Radio(
                      activeColor: colorConstants.bgClickable,
                      fillColor: WidgetStateProperty.all(colorConstants.bgClickable),
                      value: 1,
                      groupValue: registerData["gender"],
                      onChanged: (_) => setState(() => registerData["gender"] = 1)
                    ),
                    Text("Nam",
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textHeader
                      )
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Radio(
                      activeColor: colorConstants.bgClickable,
                      fillColor: WidgetStateProperty.all(colorConstants.bgClickable),
                      value: 2,
                      groupValue: registerData["gender"],
                      onChanged: (_) => setState(() => registerData["gender"] = 2)
                    ),
                    Text("Nữ",
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textHeader
                      )
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Radio(
                      activeColor: colorConstants.bgClickable,
                      fillColor: WidgetStateProperty.all(colorConstants.bgClickable),
                      value: 3,
                      groupValue: registerData["gender"],
                      onChanged: (_) => setState(() => registerData["gender"] = 2)
                    ),
                    Text("Khác",
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textHeader
                      )
                    ),
                  ],
                ),
              ),
            )
          ],
        ),

        const SizedBox(height: 12),
        _buildHeaderWidget("Đối tượng"),
        Wrap(
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Radio(
                    activeColor: colorConstants.bgClickable,
                    fillColor: WidgetStateProperty.all(colorConstants.bgClickable),
                    value: 1,
                    groupValue: registerData["role_id"] ?? 0,
                    onChanged: (_) => setState(() => registerData["role_id"] = 1)
                  ),
                  Text("Admin",
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textHeader
                    )
                  ),
                ],
              ),
            ),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Radio(
                    activeColor: colorConstants.bgClickable,
                    fillColor: WidgetStateProperty.all(colorConstants.bgClickable),
                    value: 2,
                    groupValue: registerData["role_id"] ?? 0,
                    onChanged: (_) => setState(() => registerData["role_id"] = 2)
                  ),
                  Text("Hộ gia đình",
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textHeader
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Radio(
                    activeColor: colorConstants.bgClickable,
                    fillColor: WidgetStateProperty.all(colorConstants.bgClickable),
                    value: 3,
                    groupValue: registerData["role_id"] ?? 0,
                    onChanged: (_) => setState(() => registerData["role_id"] = 3)
                  ),
                  Text("Người thu gom",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textHeader
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
        if (registerData["role_id"] == 1)
        Column(
          children: [
            const SizedBox(height: 12),
            CustomTextField(
              label: "Mã",
              placeholder: "mã đăng ký admin",
              keyword: "code",
              hasBorder: false,
              callback: (value, keyword) {
                setState(() { registerData["code"] = value; });
              },
            ),
          ],
        ),

        const SizedBox(height: 12),
        CustomTextField(
          label: "Địa chỉ",
          placeholder: "địa chỉ",
          keyword: "location",
          hasBorder: false,
          multiline: true,
          callback: (value, keyword) {
            setState(() { registerData["location"] = value; });
          },
        ),
        const SizedBox(height: 24),
        InkWell(
          canRequestFocus: false,
          onTap: isValid && !isLoading ? () async {
            setState(() {
              isLoading = true;
            });
            await _callRegisterApi();
            setState(() {
              isLoading = false;
            });
          } : null,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isValid ? colorConstants.bgClickable : colorConstants.bgDisabled,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isLoading ? const CupertinoActivityIndicator() : 
              const Text("Đăng ký",
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white
                )
              ),
            ),
          ),
        )
      ]) 
    );
  }
}



class CustomTextField extends StatefulWidget {
  const CustomTextField({super.key, required this.placeholder, required this.callback, required this.keyword, this.label, this.hasBorder = false, this.multiline = false, this.isOnlyNumber = false, this.isPassword = false});
  final String placeholder;
  final Function callback;
  final String keyword;
  final String? label;
  final bool hasBorder;
  final bool multiline;
  final bool isOnlyNumber;
  final bool isPassword;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          alignment: Alignment.centerLeft,
          child: Text(widget.label!,
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: colorConstants.textSubHeader
            )
          ),
        ),
        Container(
          height: widget.multiline ? 80 : 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: widget.hasBorder ? Border.all(color: colorConstants.border) : null
          ),
          child: CupertinoTextField(
            autofocus: true,
            cursorColor: colorConstants.bgClickable,
            cursorHeight: 16,
            textInputAction: TextInputAction.next,
            obscureText: widget.isPassword ? !showPassword : false,
            maxLines: widget.multiline ? 3 : 1,
            controller: _controller,
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
            },
            padding: const EdgeInsets.only(left: 12),
            placeholder: "Nhập ${widget.placeholder}",
            keyboardType: widget.isOnlyNumber ? TextInputType.phone : null,
            placeholderStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textPlaceholder, fontFamily: "Inter"
            ),
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: colorConstants.textHeader, fontFamily: "Inter"
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(widget.multiline ? 200 : widget.isOnlyNumber ? 10 : 50),
            ],
            onChanged: (value) {
              setState(() {});
              widget.callback(value, widget.keyword);
            },
            suffix: _controller.text.isEmpty ? null : InkWell(
              canRequestFocus: false,
              onTap: () {
                if (widget.isPassword) {
                  setState(() {
                    showPassword = !showPassword;
                  });
                } else {
                  _controller.clear();
                  setState(() {});
                }
              },
              child: widget.isPassword ? Container(
                margin: const EdgeInsets.only(right: 12),
                child: Icon(showPassword ? PhosphorIcons.regular.eye :
                  PhosphorIcons.regular.eyeSlash, size: 20, color: colorConstants.textHeader)
              ) :
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: Icon(PhosphorIcons.regular.x, size: 20, color: colorConstants.textHeader)),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
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
              canRequestFocus: false,
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


