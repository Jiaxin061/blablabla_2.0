import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../theme/theme.dart';

/// Main app scaffold with the persistent bottom navigation bar.
/// Uses StatefulShellRoute for state preservation across tabs.
class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: _VBlaBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _VBlaBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _VBlaBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.huge),
          topRight: Radius.circular(AppRadius.huge),
        ),
        boxShadow: AppShadows.bottomNav,
        border: const Border(
          top: BorderSide(color: AppColors.surfaceContainerHigh, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: 12,
            bottom: bottomPadding > 0 ? 4 : 12,
            left: 8,
            right: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.psychology_alt_rounded,
                label: 'Chat',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.center_focus_strong_rounded,
                label: 'Scan',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.insights_rounded,
                label: 'Insights',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _AlertNavItem(
                isActive: currentIndex == 4,
                hasUnread: true,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppConstants.animMedium,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryFixed.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: AppRadius.fullRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppConstants.animFast,
              child: Icon(
                icon,
                key: ValueKey(isActive),
                color:
                    isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelLg.copyWith(
                fontSize: 12,
                color:
                    isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AlertNavItem extends StatelessWidget {
  final bool isActive;
  final bool hasUnread;
  final VoidCallback onTap;

  const _AlertNavItem({
    required this.isActive,
    required this.hasUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppConstants.animMedium,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryFixed.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: AppRadius.fullRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_rounded,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 26,
                ),
                if (hasUnread)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Alerts',
              style: AppTypography.labelLg.copyWith(
                fontSize: 12,
                color:
                    isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
