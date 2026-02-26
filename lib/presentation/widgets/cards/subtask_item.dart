import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/subtask_model.dart';

class SubtaskItem extends StatelessWidget {
  final SubtaskModel subtask;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onDelete;

  const SubtaskItem({
    super.key,
    required this.subtask,
    this.onChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: subtask.isCompleted,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              activeColor: AppColors.primary,
              side: BorderSide(
                color: subtask.isCompleted 
                    ? AppColors.primary 
                    : AppColors.textSecondary.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Title
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                fontSize: 14,
                color: subtask.isCompleted 
                    ? AppColors.textSecondary 
                    : AppColors.textPrimary,
                decoration: subtask.isCompleted 
                    ? TextDecoration.lineThrough 
                    : null,
                decorationColor: AppColors.textSecondary,
              ),
            ),
          ),

          // Delete button
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.close,
                size: 18,
                color: AppColors.textHint,
              ),
            ),
        ],
      ),
    );
  }
}
