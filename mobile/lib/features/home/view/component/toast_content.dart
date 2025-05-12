import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ToastContent extends StatelessWidget {
  final bool isSuccess;
  final String title;
  const ToastContent({super.key, required this.isSuccess, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 4,spreadRadius: -2,color: const Color(0xff18274B).withOpacity(0.08),offset: const Offset(0, 4)),
          BoxShadow(blurRadius: 4,spreadRadius: -2,color: const Color(0xff18274B).withOpacity(0.12),offset: const Offset(0, 2)),
        ]
      ),
      child: Text.rich(
        TextSpan(children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              height: 24,
              width: 24,
              margin: const EdgeInsets.only(right: 5),
              child: isSuccess 
                ? Icon(PhosphorIcons.fill.checkCircle,color: const Color(0xff1AAF4E)) 
                : Icon(PhosphorIcons.fill.xCircle,color: const Color(0xFFFF3048))
                )
              ),
          TextSpan(text: title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1D2939))),
          ]
        )
      )
    );
  }
}