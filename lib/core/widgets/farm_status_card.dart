import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Farm status card for rack/shelf overview display.
enum FarmStatus { healthy, warning, critical, unknown }

extension FarmStatusEx on FarmStatus {
  Color get color {
    switch (this) {
      case FarmStatus.healthy:
        return AppColors.primary;
      case FarmStatus.warning:
        return const Color(0xFFF57F17);
      case FarmStatus.critical:
        return AppColors.error;
      case FarmStatus.unknown:
        return AppColors.onSurfaceVariant;
    }
  }

  Color get bgColor {
    switch (this) {
      case FarmStatus.healthy:
        return AppColors.primaryFixed.withValues(alpha: 0.3);
      case FarmStatus.warning:
        return AppColors.secondaryContainer.withValues(alpha: 0.5);
      case FarmStatus.critical:
        return AppColors.errorContainer.withValues(alpha: 0.5);
      case FarmStatus.unknown:
        return AppColors.surfaceContainerHigh;
    }
  }

  IconData get icon {
    switch (this) {
      case FarmStatus.healthy:
        return Icons.check_circle_rounded;
      case FarmStatus.warning:
        return Icons.report_rounded;
      case FarmStatus.critical:
        return Icons.error_rounded;
      case FarmStatus.unknown:
        return Icons.help_rounded;
    }
  }

  String get label {
    switch (this) {
      case FarmStatus.healthy:
        return 'Healthy';
      case FarmStatus.warning:
        return 'At Risk';
      case FarmStatus.critical:
        return 'Critical';
      case FarmStatus.unknown:
        return 'Unknown';
    }
  }

  static FarmStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'healthy':
        return FarmStatus.healthy;
      case 'warning':
        return FarmStatus.warning;
      case 'critical':
        return FarmStatus.critical;
      default:
        return FarmStatus.unknown;
    }
  }
}

/// Expandable rack status card — shows a plant photo and collapses/expands
/// plant-level monitoring metrics on tap.
class FarmStatusCard extends StatefulWidget {
  final String rackId;
  final String cropName;
  final FarmStatus status;
  /// Path to the plant image asset shown on the card header.
  final String? imagePath;
  /// Full rack data map used to populate the expanded monitoring section.
  final Map<String, dynamic>? details;
  final String? metric;
  final String? metricLabel;
  /// Optional external tap handler called in addition to internal expand toggle.
  final VoidCallback? onTap;

  const FarmStatusCard({
    super.key,
    required this.rackId,
    required this.cropName,
    required this.status,
    this.imagePath,
    this.details,
    this.metric,
    this.metricLabel,
    this.onTap,
  });

  @override
  State<FarmStatusCard> createState() => _FarmStatusCardState();
}

class _FarmStatusCardState extends State<FarmStatusCard> {
  bool _expanded = false;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.status.color;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: widget.status.bgColor,
          borderRadius: AppRadius.xlRadius,
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: _expanded ? 0.12 : 0.06),
              blurRadius: _expanded ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Card header (always visible) ──────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Plant photo
                  _PlantPhoto(
                    imagePath: widget.imagePath,
                    fallbackIcon: widget.status.icon,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  // Info column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'RACK ${widget.rackId}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            _StatusBadge(status: widget.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.cropName,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.metric != null)
                          Text(
                            '${widget.metricLabel ?? 'Moisture'}: ${widget.metric}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Expand chevron
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // ── Expandable plant monitoring detail ────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _expanded && widget.details != null
                  ? _MonitoringDetail(
                      details: widget.details!,
                      statusColor: color,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Plant Photo ──────────────────────────────────────────────────────────────

class _PlantPhoto extends StatelessWidget {
  final String? imagePath;
  final IconData fallbackIcon;
  final Color color;

  const _PlantPhoto({
    required this.imagePath,
    required this.fallbackIcon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: AppRadius.mdRadius,
        child: Image.asset(
          imagePath!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(color, fallbackIcon),
        ),
      );
    }
    return _fallback(color, fallbackIcon);
  }

  Widget _fallback(Color c, IconData icon) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Icon(icon, color: c, size: 30),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final FarmStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, color: status.color, size: 11),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Expandable Monitoring Detail ─────────────────────────────────────────────

class _MonitoringDetail extends StatelessWidget {
  final Map<String, dynamic> details;
  final Color statusColor;

  const _MonitoringDetail({
    required this.details,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final levels = details['levels'] as List<dynamic>?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: statusColor.withValues(alpha: 0.2), height: 16),
          Text(
            'PLANT LEVELS',
            style: AppTypography.caption.copyWith(
              color: statusColor,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (levels != null && levels.isNotEmpty)
            ...levels.map((lvl) => _LevelRow(level: lvl as Map<String, dynamic>, accentColor: statusColor))
          else ...[
            // Fallback: show rack-level metrics pills when no levels data
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricPill(
                  icon: Icons.water_drop_rounded,
                  label: 'Moisture',
                  value: '${details['moisture']}%',
                  color: statusColor,
                ),
                _MetricPill(
                  icon: Icons.thermostat_rounded,
                  label: 'Temp',
                  value: '${details['temperature']}°C',
                  color: statusColor,
                ),
                _MetricPill(
                  icon: Icons.science_rounded,
                  label: 'pH',
                  value: '${details['ph']}',
                  color: statusColor,
                ),
                _MetricPill(
                  icon: Icons.bolt_rounded,
                  label: 'EC',
                  value: '${details['ec']}',
                  color: statusColor,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Level Row ────────────────────────────────────────────────────────────────

class _LevelRow extends StatelessWidget {
  final Map<String, dynamic> level;
  final Color accentColor;

  const _LevelRow({required this.level, required this.accentColor});

  Color get _statusColor {
    switch ((level['status'] as String? ?? '').toLowerCase()) {
      case 'healthy':
        return AppColors.primary;
      case 'warning':
        return const Color(0xFFF57F17);
      case 'critical':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lvlNum = level['level'] as int? ?? 0;
    final plantName = level['plantName'] as String? ?? '—';
    final moisture = level['moisture'] as int? ?? 0;
    final growthStage = level['growthStage'] as String? ?? '—';
    final statusColor = _statusColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.06),
          borderRadius: AppRadius.smRadius,
          border: Border.all(color: statusColor.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            // Level badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'L$lvlNum',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Plant name + growth stage
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plantName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    growthStage,
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Moisture
            Row(
              children: [
                Icon(Icons.water_drop_rounded, size: 11, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 2),
                Text(
                  '$moisture%',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Status dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Metric Pill ─────────────────────────────────────────────────────────────

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppRadius.smRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
