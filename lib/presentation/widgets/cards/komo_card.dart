import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class KomoCard extends StatelessWidget {
  final Widget child;
  final Color? leftBorderColor;
  final double leftBorderWidth;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;

  const KomoCard({
    super.key,
    required this.child,
    this.leftBorderColor,
    this.leftBorderWidth = 16,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicHeight( // Makes left bar match content height
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fill height
            children: [
              if (leftBorderColor != null)
                Container(
                  width: leftBorderWidth,
                  decoration: BoxDecoration(
                    color: leftBorderColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      bottomLeft: Radius.circular(borderRadius),
                    ),
                  ),
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