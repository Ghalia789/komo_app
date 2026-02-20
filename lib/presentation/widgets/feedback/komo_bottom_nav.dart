import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class KomoBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onFabPressed;

  const KomoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Bottom nav bar
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Projects
                _NavItem(
                  icon: Icons.folder_outlined,
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                // Activity
                _NavItem(
                  icon: Icons.notifications_outlined,
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                // Spacer for FAB
                const SizedBox(width: 56),
                // Profile
                _NavItem(
                  icon: Icons.person_outline,
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                // Settings
                _NavItem(
                  icon: Icons.settings_outlined,
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
        // FAB
        Positioned(
          bottom: 40,
          child: FloatingActionButton(
            onPressed: onFabPressed,
            backgroundColor: AppColors.primary,
            elevation: 4,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        color: Colors.transparent,
        child: Icon(
          icon,
          color: isActive ? Colors.white : const Color(0xFFE0D0E8),
          size: 24,
        ),
      ),
    );
  }
}