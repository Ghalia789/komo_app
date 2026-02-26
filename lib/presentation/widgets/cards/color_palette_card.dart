import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/create_project/create_project_state.dart';

/// A selectable color palette card for the Style It step.
/// Shows palette name, mini preview with icon + name + color bars.
class ColorPaletteCard extends StatelessWidget {
  final ColorPalette palette;
  final String projectIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorPaletteCard({
    super.key,
    required this.palette,
    required this.projectIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.primaryDark.withOpacity(0.06),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with palette name and checkmark
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  palette.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Mini Preview Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and project name
                  Row(
                    children: [
                      Text(
                        projectIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Project Name',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Color bars
                  Row(
                    children: palette.colors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final color = entry.value;
                      final widths = [0.3, 0.35, 0.35];
                      
                      return Expanded(
                        flex: (widths[index % widths.length] * 100).toInt(),
                        child: Container(
                          height: 6,
                          margin: EdgeInsets.only(
                            right: index < palette.colors.length - 1 ? 6 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
