import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar({super.key, required this.size, this.avatarUrl});
  final double size;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final double iconSize = size * 3/8;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF66BB6A),
        image: avatarUrl != null ? DecorationImage(
          image: NetworkImage(avatarUrl!),
          fit: BoxFit.cover) : null,
        shape: BoxShape.circle,
      ),
      child: avatarUrl != null ? null : Icon(PhosphorIcons.regular.user, size: iconSize, color: Colors.white),
    );
  }
}
