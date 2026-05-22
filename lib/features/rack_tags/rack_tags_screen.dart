import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/tag_constants.dart';
import '../../core/models/tag_credential.dart';
import '../../core/services/tag_certificate_pdf_service.dart';
import '../../core/services/tag_registry_provider.dart';
import '../../core/theme/theme.dart';

/// Farm setup: register tags, mock generate API (JSON), PDF print/share.
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

  Future<void> _generate() async {
    await ref.read(tagRegistryProvider.notifier).generateCredentials();
    if (!mounted) return;
    final registry = ref.read(tagRegistryProvider);
    if (!registry.hasGeneratedPack) return;

    try {
      final paths = await TagCertificatePdfService.saveAllToStorage(
        registry.credentials.values.toList(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Credentials synced. ${paths.length} PDFs saved to ${TagCertificatePdfService.lastSaveFolderLabel}',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credentials synced. PDF save failed: $e')),
      );
    }
  }

  void _showJsonSheet(TagCredential credential) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tag credential details', style: AppTypography.headlineMd.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.mdRadius,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: SelectableText(
                credential.toJsonPretty(),
                style: AppTypography.caption.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: credential.toJsonPretty()));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Details copied')),
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy details'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
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
          'Tag Registry',
          style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
        ),
      ),
      body: registry.isReady
          ? ListView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              children: [
                const _RegistryHeroCard(),
                const SizedBox(height: AppSpacing.stackSpace),
                _GenerateApiCard(
                  isGenerating: registry.isGenerating,
                  hasGenerated: registry.hasGeneratedPack,
                  onGenerate: _generate,
                ),
                const SizedBox(height: AppSpacing.stackSpace),
                Text('REGISTERED TAGS', style: AppTypography.sectionLabel),
                const SizedBox(height: 10),
                ...TagConstants.demoTagIds.map((tagId) {
                  final rackId = registry.tagToRack[tagId] ?? '—';
                  final credential = registry.credentialForTag(tagId);
                  return _TagRegistryCard(
                    tagId: tagId,
                    rackId: rackId,
                    credential: credential,
                    onRackChanged: (newRack) => ref
                        .read(tagRegistryProvider.notifier)
                        .assignTag(tagId: tagId, rackId: newRack),
                    onViewJson: credential != null ? () => _showJsonSheet(credential) : null,
                    onPrint: credential != null
                        ? () => TagCertificatePdfService.printCertificate(credential)
                        : null,
                    onShare: credential != null
                        ? () => TagCertificatePdfService.shareCertificate(credential)
                        : null,
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

class _RegistryHeroCard extends StatelessWidget {
  const _RegistryHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.92),
            AppColors.primaryContainer.withValues(alpha: 0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadius.mdRadius,
                ),
                child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Rack tag registry',
                  style: AppTypography.headlineMd.copyWith(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Generate issues credentials (JSON) and auto-saves PDFs to your phone. '
            'Register racks, print/share certificates, affix tags, then AR Scan.',
            style: AppTypography.bodyMd.copyWith(color: Colors.white.withValues(alpha: 0.92)),
          ),
        ],
      ),
    );
  }
}

class _GenerateApiCard extends StatelessWidget {
  final bool isGenerating;
  final bool hasGenerated;
  final VoidCallback onGenerate;

  const _GenerateApiCard({
    required this.isGenerating,
    required this.hasGenerated,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_sync_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Generate API',
                style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (hasGenerated)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withValues(alpha: 0.6),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    'Synced',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onPrimaryFixed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isGenerating ? null : onGenerate,
            icon: isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(isGenerating ? 'Generating…' : 'Generate tag credentials'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagRegistryCard extends StatelessWidget {
  final int tagId;
  final String rackId;
  final TagCredential? credential;
  final ValueChanged<String> onRackChanged;
  final VoidCallback? onViewJson;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;

  const _TagRegistryCard({
    required this.tagId,
    required this.rackId,
    required this.credential,
    required this.onRackChanged,
    this.onViewJson,
    this.onPrint,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isRegistered = credential != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isRegistered
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.outlineVariant,
          width: isRegistered ? 1.5 : 1,
        ),
        boxShadow: isRegistered
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isRegistered
                  ? AppColors.primaryFixed.withValues(alpha: 0.45)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            child: Row(
              children: [
                Text(
                  'AprilTag $tagId',
                  style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _StatusChip(
                  label: isRegistered ? 'Registered' : 'Pending generate',
                  isActive: isRegistered,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TagPreview(tagId: tagId),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(TagConstants.tagFamily, style: AppTypography.caption),
                          if (credential != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'ID ${credential!.credentialId}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Assigned rack', style: AppTypography.caption),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue:
                      AppConstants.rackIds.contains(rackId) ? rackId : AppConstants.rackIds.first,
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
                if (isRegistered) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _RegistryActionButton(
                          label: 'Detail',
                          icon: Icons.data_object_rounded,
                          onPressed: onViewJson,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _RegistryActionButton(
                          label: 'Print',
                          icon: Icons.print_rounded,
                          onPressed: onPrint,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _RegistryActionButton(
                          label: 'Share',
                          icon: Icons.ios_share_rounded,
                          onPressed: onShare,
                          filled: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  const _RegistryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  static const Size _buttonSize = Size(double.infinity, 44);

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: AppRadius.mdRadius);
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: _buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: shape,
        ),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: _buttonSize,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        side: const BorderSide(color: AppColors.primary),
        shape: shape,
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StatusChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceContainerHighest,
        borderRadius: AppRadius.fullRadius,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: isActive ? Colors.white : AppColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
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
