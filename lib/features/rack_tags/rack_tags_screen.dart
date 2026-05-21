import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/tag_constants.dart';
import '../../core/services/tag_registry_provider.dart';
import '../../core/theme/theme.dart';

/// Farm setup: assign AprilTag IDs to racks.
class RackTagsScreen extends ConsumerStatefulWidget {
  const RackTagsScreen({super.key});

  @override
  ConsumerState<RackTagsScreen> createState() => _RackTagsScreenState();
}

class _RackTagsScreenState extends ConsumerState<RackTagsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tagRegistryProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final registry = ref.watch(tagRegistryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Rack Tags',
          style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
        ),
      ),
      body: registry.isReady
          ? ListView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              children: [
                _InfoBanner(
                  child: Text(
                    'Assign each printed AprilTag to a rack. AR Scan reads the tag ID and loads that rack\'s data.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                  ),
                ),
                const SizedBox(height: AppSpacing.stackSpace),
                Text('TAG REGISTRY', style: AppTypography.sectionLabel),
                const SizedBox(height: 10),
                ...TagConstants.demoTagIds.map((tagId) {
                  final rackId = registry.tagToRack[tagId] ?? '—';
                  return _TagMappingCard(
                    tagId: tagId,
                    rackId: rackId,
                    onRackChanged: (newRack) => ref
                        .read(tagRegistryProvider.notifier)
                        .assignTag(tagId: tagId, rackId: newRack),
                  );
                }),
                const SizedBox(height: AppSpacing.stackSpace),
                Center(
                  child: TextButton(
                    onPressed: () => ref.read(tagRegistryProvider.notifier).resetToDefaults(),
                    child: Text(
                      'Reset to default',
                      style: AppTypography.labelLg.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

}

class _TagMappingCard extends StatelessWidget {
  final int tagId;
  final String rackId;
  final ValueChanged<String> onRackChanged;

  const _TagMappingCard({
    required this.tagId,
    required this.rackId,
    required this.onRackChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TagPreview(tagId: tagId),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AprilTag $tagId',
                      style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      TagConstants.tagFamily,
                      style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Assigned rack', style: AppTypography.caption),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: AppConstants.rackIds.contains(rackId) ? rackId : AppConstants.rackIds.first,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: AppRadius.mdRadius),
            ),
            items: AppConstants.rackIds
                .map((id) => DropdownMenuItem(value: id, child: Text('Rack $id')))
                .toList(),
            onChanged: (value) {
              if (value != null) onRackChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _TagPreview extends StatelessWidget {
  final int tagId;
  const _TagPreview({required this.tagId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Image.asset(
        TagConstants.assetPathForTagId(tagId),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            '$tagId',
            style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final Widget child;
  const _InfoBanner({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: child,
    );
  }
}
