import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../feedback/komo_avatar.dart';

class TeamMemberItem extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String? imageUrl;
  final Color? avatarColor;
  final VoidCallback? onMenuTap;

  const TeamMemberItem({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    this.imageUrl,
    this.avatarColor,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          KomoAvatar(
            name: name,
            imageUrl: imageUrl,
            size: 44,
            backgroundColor: avatarColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: role == 'Owner' 
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: role == 'Owner' 
                    ? AppColors.primary 
                    : AppColors.textSecondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: role == 'Owner' 
                    ? AppColors.primary 
                    : AppColors.textSecondary,
              ),
            ),
          ),
          if (onMenuTap != null) ...[
            const SizedBox(width: 4),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: onMenuTap,
                icon: const Icon(Icons.more_vert, size: 20),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
