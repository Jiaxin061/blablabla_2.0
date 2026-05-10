import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../constants/app_constants.dart';

/// Smart primary action button — chunky, full-width, with active scale.
/// Implements the design spec: min 56px height, rounded, high-contrast.
class SmartActionButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SmartActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.isPrimary = true,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<SmartActionButton> createState() => _SmartActionButtonState();
}

class _SmartActionButtonState extends State<SmartActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animFast,
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) {
    _controller.reverse();
    widget.onTap?.call();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ??
        (widget.isPrimary ? AppColors.primary : AppColors.surfaceContainerHigh);
    final fg = widget.foregroundColor ??
        (widget.isPrimary ? AppColors.onPrimary : AppColors.onSurface);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          height: AppSpacing.touchTargetMin,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.xlRadius,
            boxShadow: widget.isPrimary ? AppShadows.buttonPrimary : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: fg,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: fg, size: 22),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        widget.label,
                        style: AppTypography.buttonText.copyWith(color: fg),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
