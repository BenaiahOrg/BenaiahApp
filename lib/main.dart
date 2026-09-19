// Sentry options like profilesSampleRate and attachViewHierarchy are
// marked experimental but are stable and recommended by Sentry docs.
// ignore_for_file: experimental_member_use

import 'package:benaiah_app/app.dart';
import 'package:benaiah_app/core/config/env.dart';
import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/core/extensions/responsive_extension.dart';
import 'package:benaiah_app/firebase_options.dart';
import 'package:benaiah_app/flavors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Flutter's default image cache is 100MB. This app's full-bleed topic
  // heroes and 18-image graphics galleries can burn through that after just
  // a couple of screens, evicting a list's thumbnails so they visibly
  // re-decode (a "reload" flash) when you navigate back to it even though
  // no network request happens (content providers are already keepAlive).
  PaintingBinding.instance.imageCache.maximumSizeBytes = 250 << 20;

  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor?.toLowerCase(),
    orElse: () => Flavor.dev,
  );

  await EasyLocalization.ensureInitialized();
  await _initializeFirebase();
  configureDependencies();

  // Lets podcast playback continue when the app is backgrounded and shows
  // play/pause/seek controls in the system notification tray.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'org.benaiah.app.audio',
    androidNotificationChannelName: 'Benaiah Podcast Playback',
    androidNotificationOngoing: true,
  );

  ResponsiveConfig.init(designWidth: 375, designHeight: 812);

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = Env.sentryDsn
        ..environment = F.appFlavor.name
        ..tracesSampleRate = F.appFlavor == Flavor.prod ? 0.3 : 1.0
        ..profilesSampleRate = F.appFlavor == Flavor.prod ? 0.1 : 1.0
        ..attachScreenshot = true
        ..attachViewHierarchy = true
        ..sendDefaultPii = true;
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

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      debugPrint('Firebase initialization skipped: ${e.message}');
    }
  } on Object catch (e) {
    // DefaultFirebaseOptions throws an UnsupportedError (an Error, not an
    // Exception) for platforms it has no config for. Startup must survive
    // that: article content comes from the REST API, not Firebase.
    debugPrint('Firebase initialization skipped: $e');
  }
}
