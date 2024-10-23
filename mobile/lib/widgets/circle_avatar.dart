import 'package:flutter/material.dart';

class CachedAvatar extends StatelessWidget {
  const CachedAvatar({super.key, required this.size, this.imageUrl, this.name});
  final double size;
  final String? imageUrl;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Container();
    // return CircleAvatar(
    //   radius: size,
    //   backgroundColor: Colors.transparent,
    //   backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : ,
    // )
  }
}
