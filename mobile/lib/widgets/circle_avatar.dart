import 'package:cached_network_image/cached_network_image.dart';
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
      decoration: avatarUrl != null ? null : const BoxDecoration(
        color: Color(0xFF66BB6A),
        shape: BoxShape.circle,
      ),
      child: avatarUrl != null 
        ? ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: CachedNetworkImage(imageUrl:  avatarUrl!, fit: BoxFit.cover)) 
        : Icon(PhosphorIcons.regular.user, size: iconSize, color: Colors.white),
    );
  }
}
