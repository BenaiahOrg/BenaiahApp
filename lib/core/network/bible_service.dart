import 'dart:async';

import 'package:benaiah_app/core/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:youversion_sdk/youversion_sdk.dart';

@lazySingleton
class BibleService {
  BibleService() {
    final token = Env.youversionDeveloperToken;
    debugPrint(
      token.isEmpty
          ? 'BibleService: no YouVersion developer token configured'
          : 'BibleService: YouVersion developer token configured',
    );

    _client = YouVersionClient(
      developerToken: token,
    );
  }

  /// Parses a bible.com link of the form
  /// `https://www.bible.com/bible/{version}/{passage}`.
  ///
  /// Returns a record `(passageId, bibleId)` if valid, otherwise `null`.
  static (String, String)? parseBibleLink(String href) {
    try {
      final uri = Uri.parse(href);

      if ((uri.host == 'bible.com' || uri.host == 'www.bible.com') &&
          uri.pathSegments.isNotEmpty &&
          uri.pathSegments[0] == 'bible') {
        if (uri.pathSegments.length >= 3) {
          final bibleId = uri.pathSegments[1];
          // bible.com version IDs are numeric.
          if (RegExp(r'^\d+$').hasMatch(bibleId)) {
            final passageId = uri.pathSegments
                .sublist(2)
                .join('.')
                .toUpperCase();
            return (passageId, bibleId);
          }
        }
      }
    } on Object catch (e) {
      debugPrint('BibleService: could not parse Bible link: $e');
    }
    return null;
  }

  /// Splits a comma-separated passage ID into fully qualified passage IDs.
  /// Handles both "JHN.3.16,19" and "JHN.3.16,JHN.3.19".
  @visibleForTesting
  static List<String> parsePassageIds(String passageId) {
    if (!passageId.contains(',')) {
      return [passageId];
    }

    // Already fully qualified IDs, e.g. "JHN.3.16,JHN.3.19".
    final commaParts = passageId.split(',');
    var allFullyQualified = true;
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

    // One book and chapter with comma-separated verses, e.g. "JHN.3.16,19".
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

    return [passageId];
  }

  /// Combines multiple passage references into a single reference, e.g.
  /// "John 3:16" and "John 3:19" become "John 3: 16, 19".
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

    var allSharePrefix = true;
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

  /// The SDK turns HTTP 401/403 and 404 into these; both mean the key cannot
  /// read that version, as opposed to a slow or dropped request.
  static bool _isRefused(YouVersionException e) =>
      e is YouVersionAuthException || e is YouVersionNotFoundException;

  Future<Passage> _fetch(String bibleId, String passageId) => _client.bibles
      .getPassage(
        bibleId,
        passageId,
        includeHeadings: true,
        includeNotes: false,
      )
      .timeout(_requestTimeout);

  /// Version details (abbreviation, copyright) per Bible ID, fetched once per
  /// session. Each license requires its notice beside quoted text.
  final _bibles = <String, Future<Bible?>>{};

  Future<Bible?> _bibleInfo(String bibleId) {
    return _bibles[bibleId] ??= _client.bibles
        .get(bibleId)
        .timeout(_requestTimeout)
        .then<Bible?>((bible) => bible)
        .catchError((Object e) {
          // The verse still shows; retry the details on the next popover.
          debugPrint('BibleService: no details for Bible $bibleId ($e)');
          unawaited(_bibles.remove(bibleId));
          return null;
        });
  }

  /// Fetches a Bible passage using the `youversion_sdk`.
  ///
  /// [passageId] is the standard coordinate, e.g. 'JHN.3.16' or
  /// 'JHN.3.16,19'. [bibleId] is the translation's version ID.
  Future<ScripturePassage> getPassage(
    String passageId, {
    required String bibleId,
  }) async {
    try {
      return await _read(passageId, bibleId);
    } on YouVersionException catch (e) {
      // When the developer key cannot read a version (e.g. 403), fall back
      // to English (ASV, ID 12) so the passage is still readable. Timeouts
      // are not refusals: YouVersion is often slow on a passage's first
      // request, and swapping an Amharic reader to English for that would be
      // wrong, so those surface as a retryable error instead.
      if (bibleId != _fallbackBibleId && _isRefused(e)) {
        debugPrint(
          'BibleService: failed to fetch passage for translation '
          '$bibleId ($e). Falling back to English (ASV - 12).',
        );
        return _read(passageId, _fallbackBibleId);
      }
      rethrow;
    }
  }

  static const _fallbackBibleId = '12';

  Future<ScripturePassage> _read(String passageId, String bibleId) async {
    // Started first so the details load alongside the verses.
    final bibleFuture = _bibleInfo(bibleId);
    final subPassageIds = parsePassageIds(passageId);

    final Passage passage;
    if (subPassageIds.length <= 1) {
      passage = await _fetch(bibleId, subPassageIds.firstOrNull ?? passageId);
    } else {
      final passages = await Future.wait(
        subPassageIds.map((id) => _fetch(bibleId, id)),
      );
      passage = Passage(
        id: passageId,
        content: passages.map((p) => p.content).join(' '),
        reference: combineReferences(passages),
      );
    }

    // Details are usually back well before the verses. If they lag, show the
    // verse now; the request keeps going and the next popover has them.
    final bible = await bibleFuture.timeout(
      const Duration(seconds: 3),
      onTimeout: () => null,
    );
    return ScripturePassage(passage: passage, bible: bible);
  }
}

/// A passage plus the version it was read from, which can differ from the
/// one requested after a fallback, so the popover labels it truthfully.
class ScripturePassage {
  const ScripturePassage({required this.passage, this.bible});

  final Passage passage;

  /// Null when the version details could not be loaded.
  final Bible? bible;

  /// Short label to print after the reference, e.g. "NIV".
  String? get versionLabel => bible?.localizedAbbreviation;

  /// The notice the version's license asks for, e.g. "Copyright © 2011 by
  /// Biblica, Inc.® Used by Permission".
  String? get copyright {
    final text = bible?.copyright?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
