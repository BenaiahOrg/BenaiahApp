// Sentry options like profilesSampleRate and attachViewHierarchy are
// marked experimental but are stable and recommended by Sentry docs.
// ignore_for_file: experimental_member_use

import 'package:benaiah_app/app.dart';
import 'package:benaiah_app/core/config/env.dart';
import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/core/extensions/responsive_extension.dart';
import 'package:benaiah_app/flavors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  configureDependencies();
  ResponsiveConfig.init(designWidth: 375, designHeight: 812);

  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor?.toLowerCase(),
    orElse: () => Flavor.dev,
  );

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = Env.sentryDsn
        ..environment = F.appFlavor.name
        ..tracesSampleRate = F.appFlavor == Flavor.prod ? 0.3 : 1.0
        ..profilesSampleRate = F.appFlavor == Flavor.prod ? 0.1 : 1.0
        ..attachScreenshot = true
        ..attachViewHierarchy = true;
    },
    appRunner: () => runApp(
      ProviderScope(
        child: EasyLocalization(
          supportedLocales: const [
            Locale('en'),
            Locale('am'),
          ],
          path: 'assets/translations/langs.csv',
          fallbackLocale: const Locale('en'),
          useOnlyLangCode: true,
          assetLoader: CsvAssetLoader(),
          child: const App(),
        ),
      ),
    ),
  );
}
