import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Settings', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          // Profile section
          _SettingsSection(
            title: 'PROFILE',
            children: [
              _SettingsTile(
                icon: Icons.person_rounded,
                label: 'Account',
                subtitle: 'Manage your profile',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.business_rounded,
                label: 'Farm Name',
                subtitle: 'vBlaFarm — Block 3A',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackSpace),
          _SettingsSection(
            title: 'AI PREFERENCES',
            children: [
              _SettingsTile(
                icon: Icons.psychology_rounded,
                label: 'AI Autonomy Level',
                subtitle: 'Full Auto — AI manages everything',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.notifications_active_rounded,
                label: 'AI Alert Sensitivity',
                subtitle: 'High — Immediate alerts',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackSpace),
          _SettingsSection(
            title: 'NOTIFICATIONS',
            children: [
              _SwitchTile(label: 'Harvest Reminders', value: true, onChanged: (_) {}),
              _SwitchTile(label: 'Anomaly Alerts', value: true, onChanged: (_) {}),
              _SwitchTile(label: 'Weekly AI Report', value: false, onChanged: (_) {}),
            ],
          ),
          const SizedBox(height: AppSpacing.stackSpace),
          _SettingsSection(
            title: 'APP',
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                label: 'Version',
                subtitle: 'vBlaFarm v1.0.0 — Hackathon Build',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackSpace),
          _SettingsSection(
            title: 'FARM SETUP',
            children: [
              _SettingsTile(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Rack Tags (AprilTag)',
                subtitle: 'Assign tag 0/1/2 to racks A/B/C',
                onTap: () => context.push(AppRoutes.rackTags),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackSpace),
          _SettingsSection(
            title: 'DEMO WORKFLOWS',
            children: [
              _SettingsTile(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'WhatsApp AI Demo',
                subtitle: 'Simulate accessibility workflow',
                onTap: () => context.push(AppRoutes.whatsappDemo),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.sectionLabel),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: AppTypography.labelLg.copyWith(color: AppColors.onSurface)),
      subtitle: Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatefulWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  const _SwitchTile({required this.label, required this.value, required this.onChanged});

  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  late bool _value;

  @override
  void initState() { super.initState(); _value = widget.value; }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: _value,
      onChanged: (v) { setState(() => _value = v); widget.onChanged(v); },
      title: Text(widget.label, style: AppTypography.labelLg.copyWith(color: AppColors.onSurface)),
      activeTrackColor: AppColors.primary,
    );
  }
}
