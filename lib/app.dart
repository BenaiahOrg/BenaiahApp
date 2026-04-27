import 'package:benaiah_app/core/extensions/responsive_extension.dart';
import 'package:benaiah_app/core/router/app_router.dart';
import 'package:benaiah_app/core/theme/app_theme.dart';
import 'package:benaiah_app/core/theme/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class App extends HookConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);
    final fontFamily = context.locale.languageCode == 'am'
        ? 'BenaiahAm'
        : 'BenaiahEn';

    return MaterialApp.router(
      title: 'Benaiah',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.light(fontFamily),
      darkTheme: AppTheme.dark(fontFamily),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        ResponsiveConfig.context = context;
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
