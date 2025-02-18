import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key, required this.child, this.height = 124});
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFA5D6A7).withOpacity(0.55), const Color(0xFF81C784)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16)
        )
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          child,
        ],
      ),
    );
  }
}
