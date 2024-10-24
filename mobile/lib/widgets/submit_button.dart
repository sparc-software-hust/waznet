import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SubmitButton extends StatefulWidget {
  const SubmitButton({super.key, required this.onTap, required this.text, this.isLoading = false, this.isDisable = false});
  final Function() onTap;
  final String text;
  final bool isLoading;
  final bool isDisable;

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isLoading ? null : widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 3),
              blurRadius: 8,
            )
          ],
          color: widget.isDisable ? Colors.grey[500] : ColorConstants().primaryDarkGreen
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.isLoading ? (
              const SpinKitFadingCircle(
                color: Colors.white,
                size: 19,
              )
            ) : Text(
              widget.text,
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
