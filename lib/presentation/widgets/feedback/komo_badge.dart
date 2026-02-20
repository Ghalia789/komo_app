import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class KomoBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isFilled;

  const KomoBadge({
    super.key,
    required this.text,
    required this.color,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isFilled ? null : Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isFilled ? Colors.white : color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}