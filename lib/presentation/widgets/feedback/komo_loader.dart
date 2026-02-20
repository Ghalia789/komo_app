import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class KomoLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const KomoLoader({
    super.key,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}