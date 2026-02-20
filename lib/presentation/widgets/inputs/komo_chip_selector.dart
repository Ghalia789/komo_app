import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class KomoChipSelector<T> extends StatelessWidget {
  final String? label;
  final List<T> options;
  final List<T> selected;
  final Color Function(T) colorForOption;
  final String Function(T) labelForOption;
  final void Function(T) onToggle;

  const KomoChipSelector({
    super.key,
    this.label,
    required this.options,
    required this.selected,
    required this.colorForOption,
    required this.labelForOption,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            final color = colorForOption(option);
            
            return GestureDetector(
              onTap: () => onToggle(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  labelForOption(option),
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}