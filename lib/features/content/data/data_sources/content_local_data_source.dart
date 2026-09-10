import 'dart:convert';

import 'package:benaiah_app/features/content/data/data_sources/content_api_data_source.dart';
import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_id.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Article bodies shipped inside the app bundle.
///
/// This is a snapshot of the same published articles the API serves, kept as a
/// safety net for offline use and for the window where the live article
/// endpoint is unavailable. It is real editorial copy, never placeholder text,
/// and it only answers for subtopics it genuinely has.
abstract class ContentLocalDataSource {
  /// Returns the bundled body for a `{type}_{lang}` slug, or null when this
  /// subtopic was published after the snapshot was taken.
  Future<ArticleBody?> getArticle(TopicId id, String articleSlug);

  /// Bundled authors for a `{type}_{lang}` slug, used when the live subtopic
  /// detail could not be reached.
  Future<List<Author>> getAuthors(TopicId id, String articleSlug);
}

@LazySingleton(as: ContentLocalDataSource)
class ContentLocalDataSourceImpl implements ContentLocalDataSource {
  static const _assetPath = 'assets/data/benaiah_content.json';

  Future<Map<String, Map<String, dynamic>>>? _topicsBySlug;

  @override
  Future<ArticleBody?> getArticle(TopicId id, String articleSlug) async {
    final article = await _article(id, articleSlug);
    final content = article?['content'];
    if (content is! String || content.isEmpty) return null;

    return ArticleBody(
      content: _stripMarkup(content),
      title: article?['title'] as String?,
      header: _extractHeader(content),
      youtubeUrl: article?['youtube_url'] as String?,
    );
  }

  @override
  Future<List<Author>> getAuthors(TopicId id, String articleSlug) async {
    final article = await _article(id, articleSlug);
    final authors = article?['authors'];
    if (authors is! List) return const [];

    return [
      for (final author in authors.whereType<Map<String, dynamic>>())
        if (author['name_en'] is String)
          Author(
            id: _slugify(author['name_en'] as String),
            name: author['name_en'] as String,
            nameAm: author['name_am'] as String?,
          ),
    ];
  }

  Future<Map<String, dynamic>?> _article(TopicId id, String articleSlug) async {
    final topics = await (_topicsBySlug ??= _loadTopics());
    final article = topics[id.subtopicSlug]?[articleSlug];
    return article is Map<String, dynamic> ? article : null;
  }

  Future<Map<String, Map<String, dynamic>>> _loadTopics() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final series = json.decode(raw) as List<dynamic>;

      return {
        for (final entry in series.whereType<Map<String, dynamic>>())
          for (final topic
              in (entry['topics'] as List<dynamic>? ?? const [])
                  .whereType<Map<String, dynamic>>())
            if (topic['id'] is String) topic['id'] as String: topic,
      };
    } on Exception {
      // A missing or malformed bundle just means no fallback is available.
      return const {};
    }
  }

  /// The API strips Svelte components and HTML from bodies before sending
  /// them; the bundled snapshot is raw, so match that contract here.
  static String _stripMarkup(String content) {
    return content
        .replaceAll(RegExp(r'<script[\s\S]*?</script>'), '')
        .replaceAll(RegExp('<[^>]*>'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Pulls the section header out of `<ArticleHeader content="..." />`.
  static String? _extractHeader(String content) {
    final match = RegExp(
      r'<ArticleHeader[^>]*content="([^"]*)"',
    ).firstMatch(content);
    final header = match?.group(1);
    return header != null && header.isNotEmpty ? header : null;
  }

  static String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
