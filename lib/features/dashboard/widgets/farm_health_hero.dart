import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/app_constants.dart';

/// The hero farm health card at the top of the dashboard.
class FarmHealthHero extends StatelessWidget {
  final int healthScore;
  final bool isSyncing;
  final VoidCallback onRefresh;

  const FarmHealthHero({
    super.key,
    required this.healthScore,
    required this.isSyncing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.massiveRadius,
        boxShadow: AppShadows.cardHero,
        border: Border.all(color: AppColors.surfaceContainerHigh, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pulsing icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farm Healthy',
                        style: AppTypography.headlineLg.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        isSyncing ? 'Syncing...' : 'Last updated 2 min ago',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Auto mode toggle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'AUTO MODE',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _AutoModeToggle(),
                  ],
                ),
              ],
            ),
          ),

          // ── AI Insight Banner ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: AppRadius.xlRadius,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurface,
                    height: 1.5,
                  ),
                  children: const [
                    TextSpan(
                      text:
                          '"Detected stable growing conditions today. Rack B moisture trending lower than optimal. ',
                    ),
                    TextSpan(
                      text: 'Auto irrigation scheduled.',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: '"'),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Farm preview image ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: AppRadius.xxxlRadius,
              child: Stack(
                children: [
                  SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/dashboard_feed.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Labels overlay
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        _OverlayChip(label: 'LIVE FEED', isGlass: true),
                        const SizedBox(width: 8),
                        _OverlayChip(label: 'RACK A', isPrimary: true),
                        const Spacer(),
                        // Expand icon
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.crop_free_rounded, color: Colors.white, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _AutoModeToggle extends StatefulWidget {
  @override
  State<_AutoModeToggle> createState() => _AutoModeToggleState();
}

class _AutoModeToggleState extends State<_AutoModeToggle> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
      child: AnimatedContainer(
        duration: AppConstants.animMedium,
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          color: _on ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: AppRadius.fullRadius,
        ),
        padding: const EdgeInsets.all(4),
        child: AnimatedAlign(
          duration: AppConstants.animMedium,
          curve: Curves.easeOutCubic,
          alignment:
              _on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}


class _OverlayChip extends StatelessWidget {
  final String label;
  final bool isGlass;
  final bool isPrimary;

  const _OverlayChip({
    required this.label,
    this.isGlass = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: AppRadius.smRadius,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
