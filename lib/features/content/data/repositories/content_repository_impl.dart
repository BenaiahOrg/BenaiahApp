import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/error/app_error_parser.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/core/network/api_endpoints.dart';
import 'package:benaiah_app/features/content/data/data_sources/content_api_data_source.dart';
import 'package:benaiah_app/features/content/data/data_sources/content_local_data_source.dart';
import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:benaiah_app/features/content/domain/entities/series.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_content.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_id.dart';
import 'package:benaiah_app/features/content/domain/repositories/content_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ContentRepository)
class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl(this._api, this._local);

  final ContentApiDataSource _api;
  final ContentLocalDataSource _local;

  /// The catalog is one request for the whole app, so hold it for the session
  /// instead of re-fetching per screen.
  Future<List<Series>>? _catalog;

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

  Future<List<Series>> _loadCatalog() {
    return _catalog ??= _api.getCatalog();
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

  /// Live body first; the bundled snapshot covers the gap when the live
  /// article endpoint fails. Returns null when neither has the article, which
  /// the UI renders as an explicit "not available" state.
  Future<MapEntry<String, TopicContent<String>>?> _loadBody(
    TopicId id,
    String slug,
    Future<SubtopicDetail?> detailFuture,
  ) async {
    // Fired before awaiting detail so the body request is in flight
    // concurrently with it, not queued behind it.
    final liveBodyFuture = _tryLiveBody(id, slug);
    final detail = await detailFuture;
    var body = await liveBodyFuture;

    // Trust the server's own availability flags when we have them.
    if (detail != null &&
        detail.availability.isNotEmpty &&
        !detail.availability.contains(slug)) {
      return null;
    }

    body ??= await _local.getArticle(id, slug);
    if (body == null) return null;

    var authors = detail?.authorsFor(slug) ?? const <Author>[];
    if (authors.isEmpty) {
      authors = await _local.getAuthors(id, slug);
    }

    return MapEntry(
      slug,
      TopicContent<String>(
        data: body.content,
        authors: authors,
        youtubeUrl: body.youtubeUrl,
      ),
    );
  }

  // ponytail: Endpoint 4 (article body) currently 404s for all 72 published
  // articles — a server bug, see docs/BACKEND_API_NOTES.md. Until it's fixed
  // every article view was eating a ~900ms guaranteed-failing round trip
  // before falling back to the bundled snapshot it was going to show anyway.
  // Flip this back on (or delete the check) once
  // `flutter test test/live_api_smoke_test.dart --tags live` shows bodies
  // being served.
  static const _liveArticleBodyEnabled = false;

  Future<ArticleBody?> _tryLiveBody(TopicId id, String slug) async {
    if (!_liveArticleBodyEnabled) return null;
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
