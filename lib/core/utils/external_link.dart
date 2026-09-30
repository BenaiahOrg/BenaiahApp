import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class ExternalLink {
  /// Opens [uri] in whatever handles it (browser, Telegram, mail app...) and
  /// reports whether that worked.
  ///
  /// Deliberately skips `canLaunchUrl`: on Android 11+ it answers false for
  /// every link unless the manifest lists the apps we may query, which left
  /// every external link a dead button. Launching directly needs no such
  /// declaration and still reports failure.
  static Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object catch (e) {
      debugPrint('Could not open $uri ($e)');
      return false;
    }
  }
}
