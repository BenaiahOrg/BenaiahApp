import 'package:benaiah_app/core/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:youversion_sdk/youversion_sdk.dart';

@lazySingleton
class BibleService {
  BibleService() {
    final token = Env.youversionDeveloperToken;
    if (token.isEmpty || token == 'mock_dev_token') {
      debugPrint(
        '⚠️ BibleService: No developer token provided or using fallback ($token)!',
      );
    } else {
      final safePreview = token.length > 8
          ? '${token.substring(0, 4)}...${token.substring(token.length - 4)}'
          : token;
      debugPrint(
        '✅ BibleService: Initialized successfully with token: $safePreview',
      );
    }

    _client = YouVersionClient(
      developerToken: token,
    );
  }

  /// Parses a Bible link from standard bible.com URLs: https://www.bible.com/bible/[version]/[passage]
  ///
  /// Returns a record `(passageId, bibleId)` if valid, otherwise `null`.
  static (String, String)? parseBibleLink(String href) {
    try {
      final uri = Uri.parse(href);

      // Handle standard bible.com URLs: https://www.bible.com/bible/[version]/[passage]
      if ((uri.host == 'bible.com' || uri.host == 'www.bible.com') &&
          uri.pathSegments.isNotEmpty &&
          uri.pathSegments[0] == 'bible') {
        if (uri.pathSegments.length >= 3) {
          final bibleId = uri.pathSegments[1];
          // Check if the second segment is numeric (valid version ID on bible.com)
          if (RegExp(r'^\d+$').hasMatch(bibleId)) {
            final passageId = uri.pathSegments
                .sublist(2)
                .join('.')
                .toUpperCase();
            return (passageId, bibleId);
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing Bible link: $e');
    }
    return null;
  }

  late final YouVersionClient _client;

  /// Fetches a Bible passage using the `youversion_sdk`.
  ///
  /// [passageId] is the standard coordinate (e.g., 'JHN.3.16').
  /// [bibleId] is the specific translation version ID.
  Future<Passage> getPassage(
    String passageId, {
    required String bibleId,
  }) async {
    try {
      return await _client.bibles.getPassage(
        bibleId,
        passageId,
        includeHeadings: true,
        includeNotes: false,
      );
    } catch (e) {
      // If a non-English Bible version request fails (e.g. 403 Access Denied due to developer key limitations),
      // gracefully fall back to the English ESV (ID: 12) version so the passage is still readable.
      if (bibleId != '12') {
        debugPrint(
          '⚠️ BibleService: Failed to fetch passage for translation $bibleId ($e). '
          'Gracefully falling back to English (ESV - 12)...',
        );
        return _client.bibles.getPassage(
          '12',
          passageId,
          format: 'text',
          includeHeadings: true,
          includeNotes: false,
        );
      }
      rethrow;
    }
  }
}
