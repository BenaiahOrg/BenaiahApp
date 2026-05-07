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

  late final YouVersionClient _client;

  /// Map of default Bible version/translation IDs by language code.
  ///
  /// In YouVersion API:
  /// - '12' is ESV (English Standard Version)
  /// - '3198' is አማ05 (አማርኛ አዲሱ መደበኛ ትርጉም - New Amharic Standard Version)
  /// - Alternative Amharic IDs:
  ///   - '3867' is አማ54 (መጽሐፍ ቅዱስ 1954 እትም - Standard Historic Version)
  ///   - '3200' is አማ2000 (የአማርኛ መጽሐፍ ቅዱስ ሰማንያ አሃዱ - 81-book Orthodox Version)
  static const Map<String, String> defaultBibles = {
    'en': '12',
    'am': '1260',
  };

  /// Fetches a Bible passage using the `youversion_sdk`.
  ///
  /// [passageId] is the standard coordinate (e.g., 'JHN.3.16').
  /// [languageCode] is used to select the default translation if [bibleId] is omitted.
  /// [bibleId] overrides the default translation if specified.
  Future<Passage> getPassage(
    String passageId, {
    required String languageCode,
    String? bibleId,
  }) async {
    final finalBibleId = bibleId ?? defaultBibles[languageCode] ?? '12';
    try {
      return await _client.bibles.getPassage(
        finalBibleId,
        passageId,
        format: 'text',
        includeHeadings: true,
        includeNotes: false,
      );
    } catch (e) {
      // If a non-English Bible version request fails (e.g. 403 Access Denied due to developer key limitations),
      // gracefully fall back to the English ESV (ID: 12) version so the passage is still readable.
      if (finalBibleId != '12') {
        debugPrint(
          '⚠️ BibleService: Failed to fetch passage for translation $finalBibleId ($e). '
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
