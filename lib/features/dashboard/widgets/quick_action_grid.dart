import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/routing/app_router.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Primary: AR Scan (tall)
            Expanded(
              child: _PrimaryAction(
                icon: Icons.center_focus_strong_rounded,
                label: 'Open AR Scan',
                onTap: () => context.go(AppRoutes.arScan),
              ),
            ),
            const SizedBox(width: 12),
            // Secondary actions column
            Expanded(
              child: Column(
                children: [
                  _SecondaryAction(
                    icon: Icons.water_drop_rounded,
                    label: 'Irrigate',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _SecondaryAction(
                    icon: Icons.light_mode_rounded,
                    label: 'Light Settings',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_PrimaryAction> createState() => _PrimaryActionState();
}

class _PrimaryActionState extends State<_PrimaryAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          height: 128,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryContainer, AppColors.primary],
            ),
            borderRadius: AppRadius.hugeRadius,
            boxShadow: AppShadows.buttonPrimary,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shimmer overlay on hover
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.hugeRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.label,
                    style: AppTypography.labelLg.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: AppRadius.xxlRadius,
          border: Border.all(color: AppColors.surfaceContainerHighest),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelLg.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
