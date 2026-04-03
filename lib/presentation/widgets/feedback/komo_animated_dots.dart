import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class KomoAnimatedDots extends StatefulWidget {
  final double size;
  
  const KomoAnimatedDots({
    super.key,
    this.size = 48,
  });

  @override
  State<KomoAnimatedDots> createState() => _KomoAnimatedDotsState();
}

class _KomoAnimatedDotsState extends State<KomoAnimatedDots>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animation = (_controller.value - delay + 1.0) % 1.0;
            final pulse = animation < 0.5
                ? animation * 2
                : (1 - animation) * 2;
            final scale = (0.5 + pulse * 0.5).clamp(0.5, 1.0);
            final opacity = (0.5 + pulse * 0.5).clamp(0.5, 1.0);
            
            return Container(
              width: widget.size / 3,
              height: widget.size / 3,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.identity()..scale(scale),
            );
          },
        );
      }),
    );
  }
}