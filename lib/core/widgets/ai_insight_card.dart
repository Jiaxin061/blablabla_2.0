import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Premium AI insight card — the signature card of vBlaFarm.
/// Displays AI-generated insights with reasoning context.
class AIInsightCard extends StatelessWidget {
  final String insight;
  final String? reasoning;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AIInsightCard({
    super.key,
    required this.insight,
    this.reasoning,
    this.icon,
    this.accentColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.06),
          borderRadius: AppRadius.card,
          border: Border.all(
            color: accent.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Icon(
                    icon ?? Icons.psychology_rounded,
                    color: accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'AI Insight',
                  style: AppTypography.sectionLabel.copyWith(
                    color: accent,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '"$insight"',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            if (reasoning != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                reasoning!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
