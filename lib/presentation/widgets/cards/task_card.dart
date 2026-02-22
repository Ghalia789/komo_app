import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../feedback/komo_avatar.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'design':
        return const Color(0xFF9600BF);
      case 'urgent':
        return const Color(0xFFB85C6E);
      case 'research':
        return const Color(0xFF4F9BD8);
      case 'planning':
        return const Color(0xFF5CDCC3);
      case 'dev':
        return const Color(0xFFE6A23C);
      case 'content':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left colored border
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: task.leftBorderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Tags
                      if (task.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: task.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTagColor(tag),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // Bottom row: Progress, Comments, Dot
                      Row(
                        children: [
                          // Checkbox with progress
                          if (task.hasSubtasks) ...[
                            Icon(
                              task.completedSubtasks == task.totalSubtasks
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.progressText,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          
                          // Comments
                          if (task.hasComments) ...[
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.commentCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          
                          const Spacer(),
                          
                          // Assignee avatar
                          if (task.assigneeName != null)
                            KomoAvatar(
                              name: task.assigneeName,
                              imageUrl: task.assigneePhotoUrl,
                              size: 24,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
