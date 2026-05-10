import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../constants/app_constants.dart';

/// Animated AI pulse indicator — pulsing dot with glow effect.
/// Used across all screens to indicate live AI monitoring.
class AIPulseIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final bool showLabel;
  final String label;

  const AIPulseIndicator({
    super.key,
    this.size = 8,
    this.color,
    this.showLabel = false,
    this.label = 'AI Active',
  });

  @override
  State<AIPulseIndicator> createState() => _AIPulseIndicatorState();
}

class _AIPulseIndicatorState extends State<AIPulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animPulse,
    )..repeat();

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.color ?? AppColors.primary;

    final dot = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Opacity(
              opacity: 1 - _controller.value,
              child: Container(
                width: widget.size * _scaleAnim.value * 2.5,
                height: widget.size * _scaleAnim.value * 2.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            // Core dot
            Opacity(
              opacity: _opacityAnim.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: AppShadows.aiGlow(radius: widget.size),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!widget.showLabel) return dot;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 6),
        Text(
          widget.label,
          style: AppTypography.caption.copyWith(
            color: dotColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
