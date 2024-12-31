import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key,
      required this.placeholder,
      required this.callback,
      required this.keyword,
      this.label,
      this.hasBorder = false,
      this.multiline = false,
      this.isOnlyNumber = false,
      this.isPassword = false,
      this.validator,
      this.errorText,
      this.prefix});

  final Widget? prefix;
  final String placeholder;
  final Function callback;
  final String keyword;
  final String? label;
  final bool hasBorder;
  final bool multiline;
  final bool isOnlyNumber;
  final bool isPassword;
  final String? errorText;
  final bool Function(String?)? validator;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final ColorConstants colorConstants = ColorConstants();
  final TextEditingController _controller = TextEditingController();
  bool showPassword = false;
  bool isValid = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText || widget.validator!(_controller.text) != oldWidget.validator!(_controller.text)) {
      isValid = widget.validator != null
          ? widget.validator!(_controller.text)
          : false;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isError = !isValid && widget.validator != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            alignment: Alignment.centerLeft,
            child: Text(widget.label!,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorConstants.textSubHeader)),
          ),
        SizedBox(
          height: widget.multiline ? 80 : 44,
          child: TextFormField(
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
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 12),
              prefixIcon: widget.prefix,
              suffix: _controller.text.isEmpty
                  ? null
                  : InkWell(
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
                      child: widget.isPassword
                          ? Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Icon(
                                  showPassword
                                      ? PhosphorIcons.regular.eye
                                      : PhosphorIcons.regular.eyeSlash,
                                  size: 20,
                                  color: colorConstants.textHeader))
                          : Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Icon(PhosphorIcons.regular.x,
                                  size: 20, color: colorConstants.textHeader)),
                    ),
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorConstants.textPlaceholder,
                  fontFamily: "Inter"),
              fillColor: widget.hasBorder ? const Color(0xffF4F4F5) : Colors.white,
              filled: true,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFFF4F3F)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: isError
                        ? const Color(0xffFF4F3F)
                        : const Color(0xFF4CAF50)),
              ),
            ),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorConstants.textHeader,
                fontFamily: "Inter"),
            keyboardType: widget.isOnlyNumber ? TextInputType.phone : null,
            inputFormatters: [
              LengthLimitingTextInputFormatter(widget.multiline
                  ? 200
                  : widget.isOnlyNumber
                      ? 10
                      : 50),
            ],
            onChanged: (value) {
              bool check =
                  widget.validator != null ? widget.validator!(value) : true;
              if (check != isValid) {
                setState(() {
                  isValid = check;
                });
              }
              widget.callback(value, widget.keyword);
            },
          ),
        ),
        if (isError)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              widget.errorText ?? "",
              style: colorConstants.fastStyle(
                  12, FontWeight.w500, const Color(0xffFF4F3F)),
            ),
          )
      ],
    );
  }
}
