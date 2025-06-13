import 'package:flutter/material.dart';

class LoadingPlaceholder extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const LoadingPlaceholder({
    Key? key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}