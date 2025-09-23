import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GlassBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GlassBackButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: onPressed ?? () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}