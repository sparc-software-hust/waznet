import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({super.key, required this.text, required this.icon, this.isWarning =  false, this.hasSwitch = false, this.onTap, this.onToggleSwitch, this.valueSwitch});
  final String text;
  final IconData icon;
  final bool isWarning;
  final bool hasSwitch;
  final bool? valueSwitch;
  final Function(bool)? onToggleSwitch;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isWarning ? const Color(0xFFFF4F3F) : const Color(0xFF4CAF50);
    final Color iconBgColor = isWarning ? const Color(0xFFFFE8D8) : const Color(0xFFE8F5E9).withOpacity(0.7);
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
                    color: !isWarning ? const Color(0xFF333334) : const Color(0xFFFF4F3F),
                    fontSize: 16,
                    fontWeight: FontWeight.w600)
                  ),
                ),
                hasSwitch
                ? FlutterSwitch(
                  width: 55,
                  height: 31,
                  value: valueSwitch ?? false,
                  onToggle: onToggleSwitch ?? (v) {},
                  activeColor: const Color(0xff4CAF50),
                )
                : Icon(PhosphorIcons.regular.caretRight, size: 20, color: const Color(0xFF4D4D4E)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
