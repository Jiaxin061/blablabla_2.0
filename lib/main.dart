import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Portrait orientation only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: VBlaFarmApp()));
}

class VBlaFarmApp extends StatelessWidget {
  const VBlaFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'vBlaFarm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      // Web only: letterboxed phone-width column on desktop browsers.
      // Native Android/iOS: `kIsWeb` is false — this branch is skipped and the
      // widget tree matches a MaterialApp.router with no builder (full screen).
      builder: (context, child) {
        if (!kIsWeb) {
          return child ?? const SizedBox.shrink();
        }
        final mq = MediaQuery.of(context);
        final maxW = AppConstants.webMobileViewportMaxWidth;
        final effectiveWidth =
            mq.size.width > maxW ? maxW : mq.size.width;
        return ColoredBox(
          color: AppColors.background,
          child: Center(
            child: MediaQuery(
              data: mq.copyWith(
                size: Size(effectiveWidth, mq.size.height),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
