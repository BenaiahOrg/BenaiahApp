import 'package:benaiah_app/core/config/env.dart';
import 'package:benaiah_app/core/network/api_endpoints.dart';
import 'package:benaiah_app/core/network/http_client.dart';
import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:benaiah_app/features/content/domain/entities/series.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_content.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_id.dart';
import 'package:injectable/injectable.dart';

/// Article body plus the frontmatter Endpoint 4 extracts for us.
class ArticleBody {
  const ArticleBody({
    required this.content,
    this.title,
    this.date,
    this.header,
    this.youtubeUrl,
  });

  final String content;
  final String? title;
  final String? date;
  final String? header;
  final String? youtubeUrl;
}

/// Authors and availability flags for one subtopic (Endpoint 3).
class SubtopicDetail {
  const SubtopicDetail({
    required this.authorsByArticleSlug,
    required this.artists,
    required this.availability,
  });

  final Map<String, List<Author>> authorsByArticleSlug;
  final List<Author> artists;

  /// `{type}_{lang}` slugs the server claims to have content for.
  final Set<String> availability;

  List<Author> authorsFor(String articleSlug) =>
      authorsByArticleSlug[articleSlug] ?? const [];
}

/// Talks to the Benaiah Articles public REST API.
///
/// Endpoints 1-3 back the catalog; Endpoint 4 backs article bodies. Callers are
/// expected to tolerate [getArticle] failing — see [ContentRepositoryImpl].
abstract class ContentApiDataSource {
  /// Endpoint 1: the whole catalog in one request.
  Future<List<Series>> getCatalog();

  /// Endpoint 3: authors, artists and availability for one subtopic.
  Future<SubtopicDetail> getSubtopicDetail(TopicId id);

  /// Endpoint 4: one parsed article body.
  Future<ArticleBody> getArticle(TopicId id, String articleSlug);
}

@LazySingleton(as: ContentApiDataSource)
class ContentApiDataSourceImpl implements ContentApiDataSource {
  ContentApiDataSourceImpl(this._client);

  final HttpClient _client;

  @override
  Future<List<Series>> getCatalog() async {
    final response = await _client.get(
      ApiEndpoints.articles,
    );

    final themes = _asList(response.data);
    return [
      for (final theme in themes) _seriesFrom(_asMap(theme)),
    ].where((series) => series.topics.isNotEmpty).toList();
  }

  @override
  Future<SubtopicDetail> getSubtopicDetail(TopicId id) async {
    final response = await _client.get(
      ApiEndpoints.subtopic(id.themeSlug, id.subtopicSlug),
    );

    final data = _asMap(response.data);
    final authorsJson = _asMap(data['authors']);

    return SubtopicDetail(
      authorsByArticleSlug: {
        for (final entry in authorsJson.entries)
          entry.key: _people(entry.value),
      },
      artists: _people(data['artists']),
      availability: _availability(_asMap(data['available_content'])),
    );
  }

  @override
  Future<ArticleBody> getArticle(TopicId id, String articleSlug) async {
    final response = await _client.get(
      ApiEndpoints.article(id.themeSlug, id.subtopicSlug, articleSlug),
    );

    final data = _asMap(response.data);
    return ArticleBody(
      content: _string(data['content']),
      title: _nullableString(data['title']),
      date: _nullableString(data['date']),
      header: _nullableString(data['header']),
      youtubeUrl: _youtubeUrl(_nullableString(data['audio'])),
    );
  }

  // --- Mapping -------------------------------------------------------------

  Series _seriesFrom(Map<String, dynamic> json) {
    final themeSlug = _string(json['slug']);
    final title = _asMap(json['title']);
    final topics = [
      for (final subtopic in _asList(json['subtopics']))
        _topicFrom(themeSlug, _asMap(subtopic)),
    ];

    return Series(
      id: themeSlug,
      title: _string(title['en']),
      titleEn: _string(title['en']),
      titleAm: _localized(title, 'am'),
      // The API exposes no theme-level description. Rather than invent copy,
      // leave it blank and let the UI drop the section.
      description: '',
      descriptionEn: '',
      descriptionAm: '',
      imageUrl:
          topics
              .map((topic) => topic.graphics.data)
              .firstWhere((urls) => urls.isNotEmpty, orElse: () => const [])
              .firstOrNull ??
          '',
      topics: topics,
    );
  }

  Topic _topicFrom(String themeSlug, Map<String, dynamic> json) {
    final title = _asMap(json['title']);
    final description = _asMap(json['description']);
    final artists = _people(json['artists']);
    final id = TopicId(
      themeSlug: themeSlug,
      subtopicSlug: _subtopicSlugFrom(json),
    );

    // Endpoint 1 carries graphics but no article text; bodies arrive later via
    // Endpoint 4, so the content slots start empty.
    const empty = TopicContent<String>(data: '', authors: []);

    return Topic(
      id: id.value,
      title: _string(title['en']),
      titleEn: _string(title['en']),
      titleAm: _localized(title, 'am'),
      descriptionEn: _string(description['en']),
      descriptionAm: _localized(description, 'am'),
      devotional: empty,
      devotionalEn: empty,
      devotionalAm: empty,
      studyMaterial: empty,
      studyMaterialEn: empty,
      studyMaterialAm: empty,
      graphics: TopicContent<List<String>>(
        data: _graphicUrls(_asMap(json['images']), _asMap(json['covers'])),
        authors: artists,
      ),
    );
  }

  /// Endpoint 1 and 2 omit the subtopic `slug` the docs promise, so recover it
  /// from an article path: `/api/v1/articles/{theme}/{subtopic}/{type}_{lang}`.
  String _subtopicSlugFrom(Map<String, dynamic> json) {
    final direct = _nullableString(json['slug']);
    if (direct != null) return direct;

    for (final byType in _asMap(json['articles']).values) {
      for (final path in _asMap(byType).values) {
        final segments = _string(path).split('/');
        if (segments.length >= 2) {
          return segments[segments.length - 2];
        }
      }
    }
    return '';
  }

  /// Square and story artwork for both languages, cover first, de-duplicated.
  List<String> _graphicUrls(
    Map<String, dynamic> images,
    Map<String, dynamic> covers,
  ) {
    final urls = <String>{};

    for (final lang in const ['en', 'am']) {
      final cover = _nullableString(covers[lang]);
      if (cover != null) urls.add(cover);
    }

    for (final shape in const ['square', 'story']) {
      final byLang = _asMap(images[shape]);
      for (final lang in const ['en', 'am']) {
        urls.addAll(_asList(byLang[lang]).whereType<String>());
      }
    }

    return urls.toList();
  }

  List<Author> _people(Object? value) {
    return [
      for (final person in _asList(value)) _person(_asMap(person)),
    ];
  }

  Author _person(Map<String, dynamic> json) {
    final nameEn = _string(json['fullname_en']);
    final photo = _nullableString(json['photo']);

    return Author(
      id: _slugify(nameEn),
      name: nameEn,
      nameAm: _nullableString(json['fullname_am']),
      profileImageUrl: photo == null ? null : _absoluteUrl(photo),
    );
  }

  /// Author and artist photos come back as site-relative paths.
  String _absoluteUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '${Env.apiUrl}${path.startsWith('/') ? '' : '/'}$path';
  }

  /// `{"devotional": {"en": true}}` becomes `{"devotional_en"}`.
  Set<String> _availability(Map<String, dynamic> json) {
    return {
      for (final type in json.entries)
        for (final lang in _asMap(type.value).entries)
          if (lang.value == true) '${type.key}_${lang.key}',
    };
  }

  /// Frontmatter gives `youtube/{id}`; the player wants a watchable URL.
  String? _youtubeUrl(String? audio) {
    if (audio == null || audio.isEmpty) return null;
    if (audio.startsWith('http')) return audio;

    const prefix = 'youtube/';
    if (audio.startsWith(prefix)) {
      final id = audio.substring(prefix.length);
      return id.isEmpty ? null : 'https://www.youtube.com/watch?v=$id';
    }
    return null;
  }

  // --- Coercion helpers ----------------------------------------------------

  /// The API is untyped JSON; every read is defensive so one malformed field
  /// degrades that field instead of failing the whole screen.
  static List<dynamic> _asList(Object? value) =>
      value is List ? value : const [];

  static Map<String, dynamic> _asMap(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  static String _string(Object? value) => value is String ? value : '';

  static String? _nullableString(Object? value) {
    return value is String && value.isNotEmpty ? value : null;
  }

  /// Falls back to English when a translation is missing rather than blanking.
  static String _localized(Map<String, dynamic> json, String lang) {
    return _nullableString(json[lang]) ?? _string(json['en']);
  }

  static String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
