import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/create_task/create_task_state.dart';

/// A horizontal list of selectable avatar chips for assigning team members.
class AssigneeSelector extends StatelessWidget {
  final List<Assignee> assignees;
  final List<String> selectedIds;
  final ValueChanged<String> onToggle;

  const AssigneeSelector({
    super.key,
    required this.assignees,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_outline,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Assign to',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: assignees.map((assignee) {
            final isSelected = selectedIds.contains(assignee.id);
            return _AssigneeChip(
              assignee: assignee,
              isSelected: isSelected,
              onTap: () => onToggle(assignee.id),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AssigneeChip extends StatelessWidget {
  final Assignee assignee;
  final bool isSelected;
  final VoidCallback onTap;

  const _AssigneeChip({
    required this.assignee,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? assignee.color.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? assignee.color : AppColors.textHint.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: assignee.color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  assignee.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Name
            Text(
              assignee.name.split(' ').first, // First name only
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? assignee.color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
