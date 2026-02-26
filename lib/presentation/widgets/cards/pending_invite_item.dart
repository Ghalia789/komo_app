import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PendingInviteItem extends StatelessWidget {
  final String email;
  final VoidCallback onResend;
  final VoidCallback onRemove;

  const PendingInviteItem({
    super.key,
    required this.email,
    required this.onResend,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: onResend,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              'Resend',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.error,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
