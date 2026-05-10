import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'ai_pulse_indicator.dart';

/// AI Reasoning Timeline — displays step-by-step AI decision reasoning.
/// Used in Digital Twin and AI Chat screens.
class AIReasoningTimeline extends StatelessWidget {
  final List<AIReasoningStep> steps;
  final bool showConnector;

  const AIReasoningTimeline({
    super.key,
    required this.steps,
    this.showConnector = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    // Node
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: step.isActive
                            ? AppColors.primary
                            : AppColors.surfaceContainerHigh,
                        borderRadius: AppRadius.mdRadius,
                        boxShadow: step.isActive ? AppShadows.aiGlow() : null,
                      ),
                      child: step.isActive
                          ? const Center(child: AIPulseIndicator(size: 6))
                          : Icon(
                              step.icon ?? Icons.check_rounded,
                              color: step.isDone
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                              size: 16,
                            ),
                    ),
                    // Connector line
                    if (!isLast && showConnector)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.6),
                                AppColors.primary.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: AppRadius.fullRadius,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: AppTypography.labelLg.copyWith(
                          color: step.isActive
                              ? AppColors.primary
                              : AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (step.detail != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          step.detail!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class AIReasoningStep {
  final String title;
  final String? detail;
  final IconData? icon;
  final bool isActive;
  final bool isDone;

  const AIReasoningStep({
    required this.title,
    this.detail,
    this.icon,
    this.isActive = false,
    this.isDone = false,
  });
}
