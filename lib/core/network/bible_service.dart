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

  /// Parses a comma-separated passage ID into individual fully qualified passage IDs.
  /// Handles both "JHN.3.16,19" and "JHN.3.16,JHN.3.19" patterns.
  @visibleForTesting
  static List<String> parsePassageIds(String passageId) {
    if (!passageId.contains(',')) {
      return [passageId];
    }

    // Pattern 1: Check if the string is already fully qualified IDs separated by commas,
    // e.g. "JHN.3.16,JHN.3.19"
    final commaParts = passageId.split(',');
    bool allFullyQualified = true;
    for (final part in commaParts) {
      final dotParts = part.trim().split('.');
      if (dotParts.length < 3) {
        allFullyQualified = false;
        break;
      }
    }

    if (allFullyQualified) {
      return commaParts.map((part) => part.trim().toUpperCase()).toList();
    }

    // Pattern 2: Single book/chapter with comma-separated verses,
    // e.g. "JHN.3.16,19"
    final dotParts = passageId.split('.');
    if (dotParts.length == 3 && dotParts[2].contains(',')) {
      final book = dotParts[0].trim().toUpperCase();
      final chapter = dotParts[1].trim().toUpperCase();
      final verseSpecs = dotParts[2].split(',');

      return verseSpecs
          .map((v) => '$book.$chapter.${v.trim().toUpperCase()}')
          .where((id) => id.isNotEmpty)
          .toList();
    }

    // Fallback: return the original passageId in a list
    return [passageId];
  }

  /// Combines multiple passage references into a single clean reference.
  /// E.g. "John 3:16" and "John 3:19" becomes "John 3: 16, 19"
  @visibleForTesting
  String combineReferences(List<Passage> passages) {
    if (passages.isEmpty) return '';
    if (passages.length == 1) return passages.first.reference;

    final firstRef = passages.first.reference;
    final colonIndex = firstRef.lastIndexOf(':');
    if (colonIndex == -1) {
      return passages.map((p) => p.reference).join(', ');
    }

    final prefix = firstRef.substring(0, colonIndex + 1); // e.g. "John 3:"

    bool allSharePrefix = true;
    final verses = <String>[];

    for (final p in passages) {
      final ref = p.reference;
      final cIdx = ref.lastIndexOf(':');
      if (cIdx == -1 || ref.substring(0, cIdx + 1).trim() != prefix.trim()) {
        allSharePrefix = false;
        break;
      }
      verses.add(ref.substring(cIdx + 1).trim());
    }

    if (allSharePrefix) {
      return '$prefix ${verses.join(', ')}';
    } else {
      return passages.map((p) => p.reference).join(', ');
    }
  }

  late final YouVersionClient _client;

  /// The SDK builds its Dio client with no connect or receive timeout, so a
  /// throttled or stalled request never completes and the overlay spins
  /// forever. Bound it here instead of forking the package.
  static const _requestTimeout = Duration(seconds: 15);

  Future<Passage> _fetch(String bibleId, String passageId) => _client.bibles
      .getPassage(
        bibleId,
        passageId,
        includeHeadings: true,
        includeNotes: false,
      )
      .timeout(_requestTimeout);

  /// Fetches a Bible passage using the `youversion_sdk`.
  ///
  /// [passageId] is the standard coordinate (e.g., 'JHN.3.16' or 'JHN.3.16,19').
  /// [bibleId] is the specific translation version ID.
  Future<Passage> getPassage(
    String passageId, {
    required String bibleId,
  }) async {
    final subPassageIds = parsePassageIds(passageId);

    if (subPassageIds.length <= 1) {
      final targetId = subPassageIds.firstOrNull ?? passageId;
      try {
        return await _fetch(bibleId, targetId);
      } catch (e) {
        // If a non-default Bible version request fails (e.g. 403 Access
        // Denied due to developer key limitations), gracefully fall back to
        // English (ASV, ID 12) so the passage is still readable.
        if (bibleId != '12') {
          debugPrint(
            '⚠️ BibleService: Failed to fetch passage for translation '
            '$bibleId ($e). Falling back to English (ASV - 12)...',
          );
          return _fetch('12', targetId);
        }
        rethrow;
      }
    }

    // Fetch multiple passages in parallel recursively
    final passages = await Future.wait(
      subPassageIds.map((id) => getPassage(id, bibleId: bibleId)),
    );

    // Merge contents and references
    final combinedReference = combineReferences(passages);
    final combinedContent = passages.map((p) => p.content).join(' ');

    return Passage(
      id: passageId,
      content: combinedContent,
      reference: combinedReference,
    );
  }
}
