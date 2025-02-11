import 'package:cecr_unwomen/widgets/confirm_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton(
      {super.key,
      required this.text,
      required this.icon,
      this.isWarning = false,
      this.isIconWarning = false,
      this.hasSwitch = false,
      this.onTap,
      this.onToggleSwitch,
      this.valueSwitch,
      this.subTitleWidget});
  final String text;
  final IconData icon;
  final bool isWarning;
  final bool isIconWarning;
  final bool hasSwitch;
  final bool? valueSwitch;
  final Function(bool)? onToggleSwitch;
  final Function? onTap;
  final Widget? subTitleWidget;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        isIconWarning ? const Color(0xFFFF4F3F) : const Color(0xFF4CAF50);
    final Color iconBgColor =  isIconWarning
        ? const Color(0xFFFFE8D8)
        : const Color(0xFFE8F5E9).withOpacity(0.7);

    Widget option = Row(

      children: [
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: !isWarning
                      ? const Color(0xFF333334)
                      : const Color(0xFFFF4F3F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        hasSwitch
            ? FlutterSwitch(
                width: 55,
                height: 31,
                value: valueSwitch ?? false,
                onToggle: onToggleSwitch ?? (v) {},
                activeColor: const Color(0xff4CAF50),
              )
            : Icon(PhosphorIcons.regular.caretRight,
                size: 20, color: const Color(0xFF4D4D4E)),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            if (isWarning || isIconWarning) {
              final bool? isConfirm = await showDialog(
                context: context,
                builder: (context) => ConfirmCard(
                  title: "Xác nhận ${text.toLowerCase()}",
                  subtitle: "Bạn có chắc chắn muốn thực hiện hành động này?",
                  dangerousTextInButton: "Xác nhận",
                  onClick: () {
                    Navigator.pop(context, true);
                  },
                ),
              );
              if (isConfirm == null) return;
              onTap?.call();
            } else {
              onTap?.call();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: subTitleWidget != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                Flexible(
                  child: subTitleWidget != null
                      ? Column(
                          children: [
                            option,
                            subTitleWidget ?? Container(),
                          ],
                        )
                      : option,
                ),
              ],
            )),
        ),
      ),
    );
  }
}
