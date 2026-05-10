import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/farm_overview/farm_overview_screen.dart';
import '../../features/ar_scan/ar_scan_screen.dart';
import '../../features/digital_twin/digital_twin_screen.dart';
import '../../features/chatbot/chat_screen.dart';
import '../../features/alerts/alerts_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/whatsapp_demo/whatsapp_demo_screen.dart';
import '../widgets/app_scaffold.dart';

/// Route name constants for type-safe navigation.
abstract final class AppRoutes {
  static const String home = '/';
  static const String farmOverview = '/farm-overview';
  static const String arScan = '/ar-scan';
  static const String digitalTwin = '/digital-twin';
  static const String chat = '/chat';
  static const String alerts = '/alerts';
  static const String settings = '/settings';
  static const String whatsappDemo = '/whatsapp-demo';
}

/// Global router using StatefulShellRoute for persistent bottom nav.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        // ── Home / Dashboard ─────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: DashboardScreen(),
              ),
            ),
          ],
        ),
        // ── AI Chat ──────────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.chat,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ChatScreen(),
              ),
            ),
          ],
        ),
        // ── AR Scan ──────────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.arScan,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ArScanScreen(),
              ),
            ),
          ],
        ),
        // ── Farm Overview / Insights ──────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.farmOverview,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: FarmOverviewScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'digital-twin/:rackId',
                  pageBuilder: (context, state) {
                    final rackId = state.pathParameters['rackId'] ?? 'B';
                    return CustomTransitionPage(
                      child: DigitalTwinScreen(rackId: rackId),
                      transitionsBuilder: (context, animation, _, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // ── Alerts ───────────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.alerts,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AlertsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),

    // ─── Settings (outside shell) ─────────────────────────────────────────
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    ),
    // ─── WhatsApp Demo (outside shell) ───────────────────────────────────
    GoRoute(
      path: AppRoutes.whatsappDemo,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const WhatsAppDemoScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    ),
  ],
);
