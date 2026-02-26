import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A preview card showing project icon, name, description, and colored progress bars.
/// Used in the Create Project flow to show real-time preview.
class ProjectPreviewCard extends StatelessWidget {
  final String icon;
  final String name;
  final String description;
  final List<Color> paletteColors;

  const ProjectPreviewCard({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    required this.paletteColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Title Row
          Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Project Name' : name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: name.isEmpty
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description.isEmpty
                          ? 'Your project description will appear here...'
                          : description,
                      style: TextStyle(
                        fontSize: 13,
                        color: description.isEmpty
                            ? AppColors.textHint
                            : AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Color Progress Bars
          Row(
            children: [
              ...paletteColors.asMap().entries.map((entry) {
                final widths = [0.3, 0.35, 0.35];
                final index = entry.key;
                final color = entry.value;
                return Expanded(
                  flex: (widths[index % widths.length] * 100).toInt(),
                  child: Container(
                    height: 8,
                    margin: EdgeInsets.only(
                      right: index < paletteColors.length - 1 ? 8 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
