import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBg,
                Color.lerp(AppTheme.darkBg, AppTheme.primaryBlue.withOpacity(0.1),
                    _controller.value)!,
                Color.lerp(AppTheme.darkBg, AppTheme.accentPurple.withOpacity(0.1),
                    1 - _controller.value)!,
                AppTheme.darkBg,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        );
      },
    );
  }
}