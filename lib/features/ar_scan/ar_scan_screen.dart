import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../core/routing/app_router.dart';

class ArScanScreen extends StatefulWidget {
  const ArScanScreen({super.key});

  @override
  State<ArScanScreen> createState() => _ArScanScreenState();
}

class _ArScanScreenState extends State<ArScanScreen> with TickerProviderStateMixin {
  late final AnimationController _scanCtrl;
  late final Animation<double> _scanAnim;
  bool _scanned = false;
  bool _calendarAdded = false;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut),
    );

    // Auto-scan after 2 seconds for demo impact
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _scanned = true);
    });
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  void _showCalendarSuccess() {
    setState(() => _calendarAdded = true);
    showDialog(
      context: context,
      builder: (context) => const _CalendarSuccessModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Background Image ───────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/ar_scan_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── Translucent Overlay & Blur ──────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),

          // ── Top Bar ──────────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('vBlaFarm AI',
                            style: AppTypography.headlineMd.copyWith(color: Colors.white, fontSize: 20)),
                        const Row(
                          children: [
                            AIPulseIndicator(size: 6, color: Colors.greenAccent),
                            SizedBox(width: 5),
                            Text('Live Analysis Active',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scan Frame ───────────────────────────────────────────────────
          if (!_scanned)
            Center(
              child: _ScanFrame(animation: _scanAnim),
            ),

          // ── Floating Metric Cards ─────────────────────────────────────────
          if (_scanned) ...[
            // Top Right: Crop & Stage
            Positioned(
              top: 180, right: 20,
              child: _ArMetricCard(
                title: 'CROP',
                value: 'Lettuce',
                icon: Icons.eco_outlined,
                delay: 200,
              ),
            ),
            Positioned(
              top: 275, right: 20,
              child: _ArMetricCard(
                title: 'STAGE',
                value: 'Seedling',
                icon: Icons.grain_outlined,
                delay: 400,
              ),
            ),

            // Middle: Humidity & Temp
            Positioned(
              top: 380, right: 100,
              child: _ArSmallMetric(
                value: '75%',
                icon: Icons.water_drop_outlined,
                delay: 600,
              ),
            ),
            Positioned(
              top: 380, right: 20,
              child: _ArSmallMetric(
                value: '22°C',
                icon: Icons.thermostat_outlined,
                delay: 800,
              ),
            ),

            // Bottom Right: Harvest
            Positioned(
              bottom: 180, right: 20,
              child: _HarvestCard(
                onAddCalendar: _showCalendarSuccess,
                isAdded: _calendarAdded,
                delay: 1000,
              ),
            ),
          ],

          // ── Bottom Action Button ──────────────────────────────────────────
          Positioned(
            bottom: 40, left: 24, right: 24,
            child: _OperationalButton(
              label: 'View AI Insight',
              icon: Icons.insights_rounded,
              onPressed: () => context.push('/farm-overview/digital-twin/B'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  final Animation<double> animation;
  const _ScanFrame({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            children: [
              // Corner markers could be added here
              Positioned(
                top: animation.value * 280,
                left: 10,
                right: 10,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final int delay;

  const _ArMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - val)),
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(title, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: AppTypography.headlineMd.copyWith(fontSize: 22, color: AppColors.onSurface)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArSmallMetric extends StatelessWidget {
  final String value;
  final IconData icon;
  final int delay;

  const _ArSmallMetric({required this.value, required this.icon, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - val)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(value, style: AppTypography.headlineMd.copyWith(fontSize: 16, color: AppColors.onSurface)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HarvestCard extends StatelessWidget {
  final VoidCallback onAddCalendar;
  final bool isAdded;
  final int delay;

  const _HarvestCard({required this.onAddCalendar, required this.isAdded, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - val)),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text('HARVEST', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('In 3 days', style: AppTypography.headlineMd.copyWith(fontSize: 22, color: AppColors.onSurface)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: isAdded ? null : onAddCalendar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAdded ? AppColors.surfaceContainerHighest : AppColors.primary,
                      foregroundColor: isAdded ? AppColors.primary : Colors.white,
                      disabledBackgroundColor: AppColors.surfaceContainerHighest,
                      disabledForegroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: isAdded ? 0 : 2,
                    ),
                    icon: Icon(isAdded ? Icons.check_circle_rounded : Icons.edit_calendar_outlined, size: 18),
                    label: Text(isAdded ? 'Added to calendar' : 'Add to calendar', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OperationalButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _OperationalButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarSuccessModal extends StatelessWidget {
  const _CalendarSuccessModal();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 24),
            Text('Event saved', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface, fontSize: 24)),
            const SizedBox(height: 8),
            Text('The harvest reminder has been added to your calendar.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🥬 Harvest: Rack B Lettuce', style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold)),
                        Text('Thursday, Oct 26 • 9:00 – 10:00 AM', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            Text('Connected via Google Workspace', style: AppTypography.caption.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
