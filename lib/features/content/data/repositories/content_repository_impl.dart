import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/error/app_error_parser.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/core/network/api_endpoints.dart';
import 'package:benaiah_app/features/content/data/data_sources/content_api_data_source.dart';
import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:benaiah_app/features/content/domain/entities/author_credit.dart';
import 'package:benaiah_app/features/content/domain/entities/series.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_content.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_id.dart';
import 'package:benaiah_app/features/content/domain/repositories/content_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ContentRepository)
class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl(this._api);

  final ContentApiDataSource _api;

  /// The catalog is one request for the whole app, so hold it for the session
  /// instead of re-fetching per screen.
  Future<List<Series>>? _catalog;

  /// Subtopic detail (bylines) for every topic in the catalog, keyed by topic
  /// id. Only Endpoint 3 carries bylines — the catalog doesn't — so building
  /// an author's full credit list means fetching all of them once. Held for
  /// the session like the catalog above.
  Future<Map<String, SubtopicDetail>>? _allSubtopicDetails;

  @override
  Future<Result<List<Series>>> getSeriesList() async {
    try {
      return Success(await _loadCatalog());
    } on Object catch (e, st) {
      _catalog = null;
      return Failure(AppErrorParser.parse(e, st));
    }
  }

  @override
  Future<Result<Series>> getSeriesById(String id) async {
    try {
      final catalog = await _loadCatalog();
      final series = catalog.firstWhere(
        (s) => s.id == id,
        orElse: () => throw const NotFoundError(),
      );
      return Success(series);
    } on Object catch (e, st) {
      return Failure(_toError(e, st));
    }
  }

  @override
  Future<Result<Topic>> getTopicById(String id) async {
    try {
      return Success(await _loadTopic(TopicId.parse(id)));
    } on Object catch (e, st) {
      return Failure(_toError(e, st));
    }
  }

  @override
  Future<Result<AuthorProfile>> getCreditsForAuthor(String authorId) async {
    try {
      final catalog = await _loadCatalog();
      final detailsByTopicId = await _loadAllSubtopicDetails(catalog);

      Author? author;
      final credits = <AuthorCredit>[];

      for (final series in catalog) {
        for (final topic in series.topics) {
          final roles = <ArticleRole>{};

          for (final artist in topic.graphics.authors) {
            if (artist.id == authorId) {
              roles.add(ArticleRole.graphics);
              author = artist;
            }
          }

          final detail = detailsByTopicId[topic.id];
          if (detail != null) {
            for (final slug in const ['devotional_en', 'devotional_am']) {
              final match = detail.authorsFor(slug).where((a) => a.id == authorId);
              if (match.isNotEmpty) {
                roles.add(ArticleRole.devotional);
                author = match.first;
              }
            }
            for (final slug in const [
              'study_material_en',
              'study_material_am',
            ]) {
              final match = detail.authorsFor(slug).where((a) => a.id == authorId);
              if (match.isNotEmpty) {
                roles.add(ArticleRole.studyMaterial);
                author = match.first;
              }
            }
          }

          if (roles.isNotEmpty) {
            credits.add(AuthorCredit(topic: topic, roles: roles));
          }
        }
      }

      if (author == null) throw const NotFoundError();
      return Success(AuthorProfile(author: author, credits: credits));
    } on Object catch (e, st) {
      return Failure(_toError(e, st));
    }
  }

  Future<List<Series>> _loadCatalog() {
    return _catalog ??= _api.getCatalog();
  }

  Future<Map<String, SubtopicDetail>> _loadAllSubtopicDetails(
    List<Series> catalog,
  ) {
    return _allSubtopicDetails ??= _fetchAllSubtopicDetails(catalog);
  }

  Future<Map<String, SubtopicDetail>> _fetchAllSubtopicDetails(
    List<Series> catalog,
  ) async {
    final ids = [
      for (final series in catalog)
        for (final topic in series.topics) TopicId.parse(topic.id),
    ];

    final details = await Future.wait([
      for (final id in ids) _trySubtopicDetail(id),
    ]);

    return {
      for (var i = 0; i < ids.length; i++)
        if (details[i] != null) ids[i].value: details[i]!,
    };
  }

  /// Builds a fully populated topic: catalog entry for artwork and titles,
  /// Endpoint 3 for bylines, Endpoint 4 for each article body.
  Future<Topic> _loadTopic(TopicId id) async {
    final base = await _findTopic(id);

    // Started here (not awaited) so it resolves in parallel with the body
    // fetches below instead of serializing two round-trips per article.
    final detailFuture = _trySubtopicDetail(id);
    final bodies = await _loadBodies(id, detailFuture);

    TopicContent<String> content(ArticleType type, String lang) {
      final slug = type.slugFor(lang);
      return bodies[slug] ?? const TopicContent<String>(data: '', authors: []);
    }

    final devotionalEn = content(ArticleType.devotional, 'en');
    final studyEn = content(ArticleType.studyMaterial, 'en');

    return Topic(
      id: base.id,
      title: base.title,
      titleEn: base.titleEn,
      titleAm: base.titleAm,
      descriptionEn: base.descriptionEn,
      descriptionAm: base.descriptionAm,
      devotional: devotionalEn,
      devotionalEn: devotionalEn,
      devotionalAm: content(ArticleType.devotional, 'am'),
      studyMaterial: studyEn,
      studyMaterialEn: studyEn,
      studyMaterialAm: content(ArticleType.studyMaterial, 'am'),
      graphics: base.graphics,
    );
  }

  Future<Topic> _findTopic(TopicId id) async {
    final catalog = await _loadCatalog();
    for (final series in catalog) {
      for (final topic in series.topics) {
        if (topic.id == id.value) return topic;
      }
    }
    throw const NotFoundError();
  }

  /// Endpoint 3 supplies bylines. Losing it should not cost us the article, so
  /// a failure degrades to "no detail" rather than propagating.
  Future<SubtopicDetail?> _trySubtopicDetail(TopicId id) async {
    try {
      return await _api.getSubtopicDetail(id);
    } on Object catch (e) {
      debugPrint('Benaiah: subtopic detail unavailable for $id ($e)');
      return null;
    }
  }

  Future<Map<String, TopicContent<String>>> _loadBodies(
    TopicId id,
    Future<SubtopicDetail?> detailFuture,
  ) async {
    final slugs = [
      for (final type in ArticleType.values)
        for (final lang in const ['en', 'am']) type.slugFor(lang),
    ];

    final entries = await Future.wait([
      for (final slug in slugs) _loadBody(id, slug, detailFuture),
    ]);

    return {
      for (final entry in entries)
        if (entry != null) entry.key: entry.value,
    };
  }

  /// Fetches one article body from the live endpoint. Returns null when the
  /// server has no article, which the UI renders as an explicit
  /// "not available" state — there is no bundled copy to fall back to.
  Future<MapEntry<String, TopicContent<String>>?> _loadBody(
    TopicId id,
    String slug,
    Future<SubtopicDetail?> detailFuture,
  ) async {
    // Fired before awaiting detail so the body request is in flight
    // concurrently with it, not queued behind it.
    final liveBodyFuture = _tryLiveBody(id, slug);
    final detail = await detailFuture;
    final body = await liveBodyFuture;

    // Trust the server's own availability flags when we have them.
    if (detail != null &&
        detail.availability.isNotEmpty &&
        !detail.availability.contains(slug)) {
      return null;
    }

    if (body == null) return null;

    final authors = detail?.authorsFor(slug) ?? const <Author>[];

    return MapEntry(
      slug,
      TopicContent<String>(
        data: body.content,
        authors: authors,
        youtubeUrl: body.youtubeUrl,
      ),
    );
  }

  Future<ArticleBody?> _tryLiveBody(TopicId id, String slug) async {
    try {
      final body = await _api.getArticle(id, slug);
      return body.content.isEmpty ? null : body;
    } on Object catch (e) {
      debugPrint('Benaiah: live article $slug unavailable for $id ($e)');
      return null;
    }
  }

  AppError _toError(Object error, StackTrace stackTrace) {
    return error is AppError ? error : AppErrorParser.parse(error, stackTrace);
  }
}
