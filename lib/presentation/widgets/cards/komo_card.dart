import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class KomoCard extends StatelessWidget {
  final Widget child;
  final Color? leftBorderColor;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;

  const KomoCard({
    super.key,
    required this.child,
    this.leftBorderColor,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Row(
            children: [
              if (leftBorderColor != null)
                Container(
                  width: 4,
                  color: leftBorderColor,
                ),
              Expanded(
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}