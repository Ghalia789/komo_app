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

  final List<String> _inactiveIcons = const [
    'assets/icons/folder_outline.png',
    'assets/icons/bell_outline.png',
    'assets/icons/user_outlined.png',
    'assets/icons/gear_outline.png',
  ];

  final List<String> _activeIcons = const [
    'assets/icons/folder_filled.png',
    'assets/icons/bell_filled.svg',
    'assets/icons/user_filled.png',
    'assets/icons/gear_filled.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none, // Allow FAB to overflow
      children: [
        // BOTTOM NAV BAR - Lighter, more transparent like Figma
        Container(
          height: 80,
          decoration: BoxDecoration(
            // Lighter purple with more opacity (more transparent)
            color: const Color(0xFFA96EB9).withOpacity(0.85), // Rose/purple tint
            // OR use: AppColors.primary.withOpacity(0.75)
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  inactiveIcon: _inactiveIcons[0],
                  activeIcon: _activeIcons[0],
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  inactiveIcon: _inactiveIcons[1],
                  activeIcon: _activeIcons[1],
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                const SizedBox(width: 56),
                _NavItem(
                  inactiveIcon: _inactiveIcons[2],
                  activeIcon: _activeIcons[2],
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  inactiveIcon: _inactiveIcons[3],
                  activeIcon: _activeIcons[3],
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
        
        // FAB - Bigger, more shadow, popping up more
        Positioned(
          bottom: 30, // Higher up (was 40, now 30 = more pop)
          child: Container(
            width: 64, // Slightly bigger
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Bigger, softer shadow
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.4),
                  blurRadius: 12, // Bigger blur
                  spreadRadius: 2, // Spread out
                  offset: const Offset(0, 6), // Deeper shadow
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: onFabPressed,
              backgroundColor: AppColors.primary,
              elevation: 0, // Remove default, use custom shadow
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32, // Bigger icon
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final String inactiveIcon;
  final String activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.inactiveIcon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconPath = isActive ? activeIcon : inactiveIcon;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        child: iconPath.endsWith('.svg')
          ? Icon(
              isActive ? Icons.notifications : Icons.notifications_outlined,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
              size: 28,
            ) // Fallback for SVG - replace with SvgPicture if using flutter_svg
          : Image.asset(
              iconPath,
              width: 32,
              height: 32,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.error,
                  color: Colors.red.withOpacity(0.5),
                  size: 24,
                );
              },
            ),
      ),
    );
  }
}