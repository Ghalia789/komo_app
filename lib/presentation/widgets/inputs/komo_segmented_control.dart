import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class KomoSegmentedControl<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelForOption;
  final void Function(T) onSelect;

  const KomoSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.labelForOption,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option == selected;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(option),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  labelForOption(option),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}