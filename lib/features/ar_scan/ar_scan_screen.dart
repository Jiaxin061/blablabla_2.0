import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/mock_farm_data.dart';
import '../../core/constants/tag_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/services/apriltag_platform_detector.dart';
import '../../core/services/tag_registry_provider.dart';
import '../../core/theme/theme.dart';
import '../digital_twin/widgets/plant_level_grid.dart';
import 'widgets/ar_camera_scanner.dart';

class ArScanScreen extends ConsumerStatefulWidget {
  const ArScanScreen({super.key});

  @override
  ConsumerState<ArScanScreen> createState() => _ArScanScreenState();
}

class _ArScanScreenState extends ConsumerState<ArScanScreen> with TickerProviderStateMixin {
  late final AnimationController _scanCtrl;
  late final Animation<double> _scanAnim;
  bool _scanned = false;
  bool _calendarAdded = false;
  bool _isScanning = false;
  int? _detectedTagId;
  Map<String, dynamic>? _rackData;
  Map<String, dynamic>? _plantData;
  bool _isPlantScan = false;
  String? _scanError;
  bool _isSupported = false;
  bool _checkingSupport = true;

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
    Future.microtask(() => ref.read(tagRegistryProvider.notifier).load());
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    final supported = await AprilTagPlatformDetector.checkSupported();
    if (mounted) {
      setState(() {
        _isSupported = supported;
        _checkingSupport = false;
      });
    }
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  bool get _useCameraScan => !kIsWeb && Platform.isAndroid;

  Map<int, String> _effectiveTagMap(TagRegistryState registry) {
    if (registry.isReady && registry.tagToRack.isNotEmpty) {
      return registry.tagToRack;
    }
    return TagConstants.defaultTagToRack;
  }

  Map<String, dynamic>? _rackDataForTag(int tagId, Map<int, String> tagMap) {
    final rackId = tagMap[tagId];
    if (rackId == null) return null;
    return MockFarmData.rackById(rackId);
  }

  Future<void> _completeScan(int tagId) async {
    if (_isScanning) return;

    final plantData = MockFarmData.tagToPlant[tagId];
    final registry = ref.read(tagRegistryProvider);
    final tagMap = _effectiveTagMap(registry);
    final rackData = plantData == null ? _rackDataForTag(tagId, tagMap) : null;

    if (plantData == null && rackData == null) {
      setState(() {
        _scanError = 'Tag $tagId is not assigned to a rack. Open Settings → Rack Tags.';
      });
      return;
    }

    setState(() {
      _isScanning = true;
      _scanError = null;
      _calendarAdded = false;
    });

    if (!_scanCtrl.isAnimating) {
      _scanCtrl
        ..reset()
        ..repeat(reverse: true);
    }

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _scanned = true;
      _detectedTagId = tagId;
      _isPlantScan = plantData != null;
      _plantData = plantData;
      _rackData = rackData;
    });
    _scanCtrl.stop();
  }

  void _resetScan() {
    setState(() {
      _scanned = false;
      _calendarAdded = false;
      _detectedTagId = null;
      _rackData = null;
      _plantData = null;
      _isPlantScan = false;
      _scanError = null;
      _isScanning = false;
    });
    _scanCtrl
      ..reset()
      ..repeat(reverse: true);
  }

  void _onClosePressed() => _resetScan();

  void _showCalendarSuccess() {
    setState(() => _calendarAdded = true);
    final rack = _rackData;
    showDialog(
      context: context,
      builder: (context) => _CalendarSuccessModal(
        rackId: rack?['id'] as String? ?? 'B',
        crop: rack?['crop'] as String? ?? 'Lettuce',
        daysToHarvest: rack?['daysToHarvest'] as int? ?? 3,
      ),
    );
  }

  Widget _buildTagChips({required bool showActiveState}) {
    return Row(
      children: TagConstants.demoTagIds.map((tagId) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: tagId == 0 ? 0 : 4,
              right: tagId == 2 ? 0 : 4,
            ),
            child: _TagScanChip(
              tagId: tagId,
              isLoading: _isScanning,
              isActive: showActiveState && _detectedTagId == tagId,
              onTap: () => _completeScan(tagId),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final registry = ref.watch(tagRegistryProvider);
    final tagMap = _effectiveTagMap(registry);
    final rack = _rackData;
    final crop = rack?['crop'] as String? ?? '—';
    final stage = rack?['stage'] as String? ?? '—';
    final moisture = rack?['moisture'] as int? ?? 0;
    final temperature = rack?['temperature'] as num? ?? 0;
    final daysToHarvest = rack?['daysToHarvest'] as int? ?? 0;
    final rackId = rack?['id'] as String? ?? 'B';

    final useCamera = !_scanned && !_checkingSupport && _useCameraScan;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (!useCamera)
            Positioned.fill(
              child: Image.asset(
                'assets/images/ar_scan_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: useCamera
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      if (_scanned)
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          tooltip: 'Close results and scan again',
                          onPressed: _onClosePressed,
                        ),
                      if (_scanned) const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _scanned ? 'Scan result' : 'vBlaFarm AI',
                              style: AppTypography.headlineMd.copyWith(color: Colors.white, fontSize: 20),
                            ),
                            Text(
                              _scanned
                                  ? _isPlantScan
                                      ? 'AprilTag $_detectedTagId → Plant ${_plantData?['plantId']}'
                                      : 'AprilTag $_detectedTagId → Rack $rackId'
                                  : 'Live Analysis Active',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                        tooltip: 'Rack tag setup',
                        onPressed: () => context.push(AppRoutes.rackTags),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _scanned && _isPlantScan && _plantData != null
                      ? _buildPlantScanResult(_plantData!)
                      : _scanned && rack != null
                          ? _buildScanResults(
                              rackId: rackId,
                              crop: crop,
                              stage: stage,
                              moisture: moisture,
                              temperature: temperature,
                              daysToHarvest: daysToHarvest,
                              tagMap: tagMap,
                            )
                          : _buildScanner(tagMap),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner(Map<int, String> tagMap) {
    final useCamera = !_checkingSupport && _useCameraScan;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cameraHeight = (constraints.maxHeight * 0.65).clamp(280.0, 520.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                SizedBox(
                  height: cameraHeight,
                  width: double.infinity,
                  child: _checkingSupport && _useCameraScan
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : useCamera
                          ? ArCameraScanner(
                              enabled: !_isScanning,
                              onTagDetected: _completeScan,
                              scanOverlay: _ScanFrame(animation: _scanAnim),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _ScanFrame(animation: _scanAnim),
                              ],
                            ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isScanning
                      ? 'Reading AprilTag…'
                      : useCamera
                          ? 'Point camera at printed AprilTag in the frame'
                          : 'Point camera at rack tag',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (_scanError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _scanError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
                  ),
                ],
                if (!_useCameraScan) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Tap the tag you are scanning',
                    style: AppTypography.caption.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _buildTagChips(showActiveState: false),
                ] else if (!_isSupported) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tag templates failed to load. Restart the app or open Rack Tags.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(color: Colors.orangeAccent),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlantScanResult(Map<String, dynamic> plant) {
    final status = plant['status'] as String;
    final health = plant['health'] as int;
    final issue = plant['issue'] as String;
    final confidence = plant['confidence'] as int;
    final recommendation = plant['recommendation'] as String;
    final crop = plant['crop'] as String;
    final stage = plant['stage'] as String;
    final daysToHarvest = plant['daysToHarvest'] as int;
    final plantId = plant['plantId'] as String;
    final rackId = plant['rackId'] as String;
    final zoomAsset = plant['zoomAsset'] as String;
    final statusAsset = plant['statusAsset'] as String;

    final Color statusColor = switch (status) {
      'healthy' => Colors.greenAccent,
      'warning' => Colors.amberAccent,
      _ => Colors.redAccent,
    };
    final Color progressColor = switch (status) {
      'healthy' => Colors.green,
      'warning' => Colors.amber,
      _ => Colors.red,
    };
    final Color issueBg = switch (status) {
      'warning' => Colors.amber.withValues(alpha: 0.15),
      _ => Colors.red.withValues(alpha: 0.15),
    };
    final Color issueBorder = switch (status) {
      'warning' => Colors.amber.withValues(alpha: 0.5),
      _ => Colors.red.withValues(alpha: 0.5),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Zoom image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Image.asset(
              zoomAsset,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: Colors.white10,
                child: const Center(child: Icon(Icons.eco_outlined, color: Colors.white38, size: 48)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Status row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Image.asset(
                  statusAsset,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Icon(Icons.image_not_supported_outlined, color: Colors.white38),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plantId,
                      style: AppTypography.headlineMd.copyWith(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: statusColor.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        '$health% Health',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Health bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Score: $health%',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: health / 100.0,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ),
          if (issue.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: issueBg,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: issueBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI Confidence: $confidence%',
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  if (recommendation.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      recommendation,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PlantStatItem(label: 'Crop', value: crop.split(' ').last),
                const _PlantStatDivider(),
                _PlantStatItem(label: 'Stage', value: stage),
                const _PlantStatDivider(),
                _PlantStatItem(
                  label: 'Harvest',
                  value: daysToHarvest <= 0 ? 'Now' : '${daysToHarvest}d',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // New scan button
          OutlinedButton.icon(
            onPressed: _resetScan,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
            label: const Text('New scan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
            ),
          ),
          const SizedBox(height: 12),
          _OperationalButton(
            label: 'View Rack $rackId',
            icon: Icons.account_tree_outlined,
            onPressed: () => context.push('${AppRoutes.farmOverview}/digital-twin/$rackId'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildScanResults({
    required String rackId,
    required String crop,
    required String stage,
    required int moisture,
    required num temperature,
    required int daysToHarvest,
    required Map<int, String> tagMap,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
            ),
            child: Text(
              'Rack $rackId identified',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _ArMetricCard(
              key: ValueKey('crop-$rackId'),
              title: 'CROP',
              value: crop.split(' ').last,
              icon: Icons.eco_outlined,
              delay: 200,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _ArMetricCard(
              key: ValueKey('stage-$rackId'),
              title: 'STAGE',
              value: stage,
              icon: Icons.grain_outlined,
              delay: 400,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ArSmallMetric(
                key: ValueKey('moisture-$rackId'),
                value: '$moisture%',
                icon: Icons.water_drop_outlined,
                delay: 600,
              ),
              const SizedBox(width: 16),
              _ArSmallMetric(
                key: ValueKey('temp-$rackId'),
                value: '${temperature.toStringAsFixed(1)}°C',
                icon: Icons.thermostat_outlined,
                delay: 800,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: _HarvestCard(
              key: ValueKey('harvest-$rackId'),
              daysToHarvest: daysToHarvest,
              onAddCalendar: _showCalendarSuccess,
              isAdded: _calendarAdded,
              delay: 1000,
            ),
          ),
          const SizedBox(height: 20),
          if (rackId == 'B') ...[
            const SizedBox(height: 4),
            Text(
              'Plant Monitor',
              style: AppTypography.headlineMd.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            PlantLevelGrid(level: 3),
            const SizedBox(height: 16),
            PlantLevelGrid(level: 5),
            const SizedBox(height: 8),
          ],
          if (!_useCameraScan) ...[
            Text(
              'Scan a different tag',
              style: AppTypography.caption.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            _buildTagChips(showActiveState: true),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: _resetScan,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
            label: const Text('New scan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          _OperationalButton(
            label: 'View AI Insight',
            icon: Icons.insights_rounded,
            onPressed: () => context.push('${AppRoutes.farmOverview}/digital-twin/$rackId'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TagScanChip extends StatelessWidget {
  final int tagId;
  final bool isLoading;
  final bool isActive;
  final VoidCallback onTap;

  const _TagScanChip({
    required this.tagId,
    required this.isLoading,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? AppColors.primary.withValues(alpha: 0.85)
          : Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            children: [
              Text(
                'Tag $tagId',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Container(
                height: 52,
                width: 52,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  TagConstants.assetPathForTagId(tagId),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      '$tagId',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            children: [
              Positioned(
                top: animation.value * 220,
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
    super.key,
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
                      Text(
                        title,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTypography.headlineMd.copyWith(fontSize: 22, color: AppColors.onSurface),
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

class _ArSmallMetric extends StatelessWidget {
  final String value;
  final IconData icon;
  final int delay;

  const _ArSmallMetric({
    super.key,
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
                  Text(
                    value,
                    style: AppTypography.headlineMd.copyWith(fontSize: 16, color: AppColors.onSurface),
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

class _HarvestCard extends StatelessWidget {
  final int daysToHarvest;
  final VoidCallback onAddCalendar;
  final bool isAdded;
  final int delay;

  const _HarvestCard({
    super.key,
    required this.daysToHarvest,
    required this.onAddCalendar,
    required this.isAdded,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final harvestLabel = daysToHarvest <= 0
        ? 'Ready now'
        : daysToHarvest == 1
            ? 'In 1 day'
            : 'In $daysToHarvest days';

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
                      Text(
                        'HARVEST',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    harvestLabel,
                    style: AppTypography.headlineMd.copyWith(fontSize: 22, color: AppColors.onSurface),
                  ),
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
                    label: Text(
                      isAdded ? 'Added to calendar' : 'Add to calendar',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
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

class _PlantStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _PlantStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _PlantStatDivider extends StatelessWidget {
  const _PlantStatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: Colors.white12);
  }
}

class _CalendarSuccessModal extends StatelessWidget {
  final String rackId;
  final String crop;
  final int daysToHarvest;

  const _CalendarSuccessModal({
    required this.rackId,
    required this.crop,
    required this.daysToHarvest,
  });

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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 24),
            Text('Event saved', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface, fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              'The harvest reminder has been added to your calendar.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
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
                        Text(
                          '🥬 Harvest: Rack $rackId $crop',
                          style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          daysToHarvest <= 0 ? 'Ready for pickup' : 'In $daysToHarvest days • 9:00 AM',
                          style: AppTypography.caption,
                        ),
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
