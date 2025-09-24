import 'package:flutter/material.dart';
import 'dart:math' as math;

class OrbitalLoadingAnimation extends StatefulWidget {
  final double size;
  final Color satelliteColor;
  final double satelliteSize;
  final Duration duration;

  const OrbitalLoadingAnimation({
    super.key,
    this.size = 44.0,
    this.satelliteColor = Colors.white,
    this.satelliteSize = 4.0,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<OrbitalLoadingAnimation> createState() => _OrbitalLoadingAnimationState();
}

class _OrbitalLoadingAnimationState extends State<OrbitalLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Central send icon (stationary)
              const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
              // Orbiting satellite dot
              Transform.rotate(
                angle: _rotationAnimation.value,
                child: Transform.translate(
                  offset: Offset(widget.size * 0.3, 0), // Orbital radius
                  child: Container(
                    width: widget.satelliteSize,
                    height: widget.satelliteSize,
                    decoration: BoxDecoration(
                      color: widget.satelliteColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.satelliteColor.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}