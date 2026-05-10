import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

class ArScanScreen extends StatefulWidget {
  const ArScanScreen({super.key});

  @override
  State<ArScanScreen> createState() => _ArScanScreenState();
}

class _ArScanScreenState extends State<ArScanScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scanCtrl;
  late final Animation<double> _scanAnim;
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_scanCtrl);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Simulated camera background ──────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1A2E1C),
                    const Color(0xFF0D1A0F),
                    const Color(0xFF1A2E1C),
                  ],
                ),
              ),
              child: Opacity(
                opacity: 0.6,
                child: GridView.count(
                  crossAxisCount: 8,
                  children: List.generate(
                    80,
                    (i) => Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.05 + (i % 5) * 0.02),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Dark gradient overlays
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Top bar ──────────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile, vertical: 12),
                child: Row(
                  children: [
                    Text('AR Scan',
                        style: AppTypography.headlineMd.copyWith(color: Colors.white)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: const Row(
                        children: [
                          AIPulseIndicator(size: 6, color: Colors.greenAccent),
                          SizedBox(width: 5),
                          Text('AI Ready',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scan frame ───────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    children: [
                      // Dark outer shadow
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.hugeRadius,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 40,
                                spreadRadius: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Corner brackets
                      ..._buildCorners(),
                      // Scanning line
                      AnimatedBuilder(
                        animation: _scanAnim,
                        builder: (_, __) => Positioned(
                          top: _scanAnim.value * 240,
                          left: 0, right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.primary.withValues(alpha: 0.8),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _scanned ? 'Rack B Detected!' : 'Point at a rack to scan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ── Floating metric cards ─────────────────────────────────────────
          if (_scanned) ...[
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              right: 20,
              child: _ArOverlayCard(
                label: 'CROP',
                value: 'Lettuce',
                icon: Icons.grass_rounded,
                borderColor: AppColors.primary,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              right: 30,
              child: _ArOverlayCard(
                label: 'STAGE',
                value: 'Seedling',
                icon: Icons.eco_rounded,
                borderColor: AppColors.secondary,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45,
              right: 20,
              child: _ArOverlayCard(
                label: 'HARVEST',
                value: 'In 3 days',
                icon: Icons.calendar_today_rounded,
                borderColor: AppColors.tertiaryContainer,
              ),
            ),
          ],

          // ── Bottom actions ────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  children: [
                    SmartActionButton(
                      label: _scanned ? 'View Digital Twin' : 'Tap to Scan Rack B',
                      icon: _scanned ? Icons.insights_rounded : Icons.center_focus_strong_rounded,
                      onTap: () => setState(() => _scanned = !_scanned),
                      backgroundColor: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    SmartActionButton(
                      label: 'Activate Irrigation',
                      icon: Icons.water_drop_rounded,
                      isPrimary: false,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      foregroundColor: Colors.white,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const size = 28.0;
    const stroke = 4.0;
    final color = AppColors.primary;
    return [
      Positioned(top: 0, left: 0,
          child: _Corner(color: color, size: size, stroke: stroke, topLeft: true)),
      Positioned(top: 0, right: 0,
          child: _Corner(color: color, size: size, stroke: stroke, topRight: true)),
      Positioned(bottom: 0, left: 0,
          child: _Corner(color: color, size: size, stroke: stroke, bottomLeft: true)),
      Positioned(bottom: 0, right: 0,
          child: _Corner(color: color, size: size, stroke: stroke, bottomRight: true)),
    ];
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double size;
  final double stroke;
  final bool topLeft, topRight, bottomLeft, bottomRight;

  const _Corner({
    required this.color,
    required this.size,
    required this.stroke,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color, stroke: stroke,
          topLeft: topLeft, topRight: topRight,
          bottomLeft: bottomLeft, bottomRight: bottomRight,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double stroke;
  final bool topLeft, topRight, bottomLeft, bottomRight;

  _CornerPainter({
    required this.color, required this.stroke,
    this.topLeft = false, this.topRight = false,
    this.bottomLeft = false, this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (topLeft) {
      canvas.drawLine(Offset(0, size.height * 0.6), Offset.zero, paint);
      canvas.drawLine(Offset.zero, Offset(size.width * 0.6, 0), paint);
    }
    if (topRight) {
      canvas.drawLine(Offset(size.width, size.height * 0.6), Offset(size.width, 0), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(size.width * 0.4, 0), paint);
    }
    if (bottomLeft) {
      canvas.drawLine(Offset(0, size.height * 0.4), Offset(0, size.height), paint);
      canvas.drawLine(Offset(0, size.height), Offset(size.width * 0.6, size.height), paint);
    }
    if (bottomRight) {
      canvas.drawLine(Offset(size.width, size.height * 0.4), Offset(size.width, size.height), paint);
      canvas.drawLine(Offset(size.width, size.height), Offset(size.width * 0.4, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArOverlayCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color borderColor;

  const _ArOverlayCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: AppRadius.xlRadius,
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: AppShadows.cardHero,
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant, letterSpacing: 1)),
              Text(value,
                  style: AppTypography.headlineMd.copyWith(
                      color: AppColors.onSurface, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
