import 'dart:convert';
import 'dart:io';

import 'package:benaiah_app/core/network/api_endpoints.dart';
import 'package:benaiah_app/core/network/http_client.dart';
import 'package:benaiah_app/features/content/data/data_sources/content_api_data_source.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_id.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves captured responses from the live Benaiah API so the mapping is
/// exercised against payloads the server actually returns, not idealised ones.
class _FixtureHttpClient implements HttpClient {
  _FixtureHttpClient(this.body);

  final dynamic body;
  String? lastEndpoint;

  @override
  Future<HttpResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) async {
    lastEndpoint = endpoint;
    return HttpResponse(statusCode: 200, data: body);
  }

  @override
  Future<HttpResponse> post(
    String e, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError();
  @override
  Future<HttpResponse> put(
    String e, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError();
  @override
  Future<HttpResponse> patch(
    String e, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError();
  @override
  Future<HttpResponse> delete(
    String e, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError();
}

dynamic _fixture(String name) =>
    json.decode(File('test/fixtures/$name').readAsStringSync());

void main() {
  group('getCatalog', () {
    late List<dynamic> catalogJson;

    setUp(
      () => catalogJson = _fixture('articles_catalog.json') as List<dynamic>,
    );

    test('maps every theme and subtopic from the live payload', () async {
      final source = ContentApiDataSourceImpl(_FixtureHttpClient(catalogJson));

      final series = await source.getCatalog();

      expect(series, hasLength(3));
      expect(series.map((s) => s.id), [
        'love-faith-and-hope',
        'names-of-god',
        'the-full-armor-of-god',
      ]);
      expect(series.map((s) => s.topics.length), [3, 10, 5]);
    });

    test('recovers the subtopic slug the API omits', () async {
      final source = ContentApiDataSourceImpl(_FixtureHttpClient(catalogJson));

      final series = await source.getCatalog();
      final topicIds = series.first.topics.map((t) => TopicId.parse(t.id));

      // The payload carries no `slug` field, so this must come from the
      // article paths.
      expect(
        topicIds.map((id) => id.subtopicSlug),
        ['love', 'faith', 'hope'],
      );
      expect(topicIds.every((id) => id.isValid), isTrue);
      expect(topicIds.first.themeSlug, 'love-faith-and-hope');
    });

    test(
      'keeps bilingual titles and collects artwork for both languages',
      () async {
        final source = ContentApiDataSourceImpl(
          _FixtureHttpClient(catalogJson),
        );

        final love = (await source.getCatalog()).first.topics.first;

        expect(love.titleEn, 'Love');
        expect(love.titleAm, isNot('Love'));
        expect(love.localizedTitle('am'), love.titleAm);

        // 2 covers + 6 square + 6 square(am) + 3 story + 3 story(am), deduped.
        expect(love.graphics.data.length, greaterThan(10));
        expect(
          love.graphics.data.every((u) => u.startsWith('https://')),
          isTrue,
        );
        expect(love.graphics.data.toSet().length, love.graphics.data.length);
      },
    );

    test('maps artists as graphics credits', () async {
      final source = ContentApiDataSourceImpl(_FixtureHttpClient(catalogJson));

      final love = (await source.getCatalog()).first.topics.first;

      expect(love.graphics.authors, isNotEmpty);
      final artist = love.graphics.authors.first;
      expect(artist.name, isNotEmpty);
      // Site-relative photo paths must be absolute before they reach the UI.
      expect(artist.profileImageUrl, startsWith('https://'));
    });

    test(
      'article bodies are absent until the detail screen loads them',
      () async {
        final source = ContentApiDataSourceImpl(
          _FixtureHttpClient(catalogJson),
        );

        final love = (await source.getCatalog()).first.topics.first;

        expect(love.devotionalEn.data, isEmpty);
        expect(love.studyMaterialAm.data, isEmpty);
      },
    );
  });

  group('getSubtopicDetail', () {
    test('reads bylines and availability flags', () async {
      final source = ContentApiDataSourceImpl(
        _FixtureHttpClient(_fixture('subtopic_detail.json')),
      );

      final detail = await source.getSubtopicDetail(
        const TopicId(themeSlug: 'love-faith-and-hope', subtopicSlug: 'love'),
      );

      expect(detail.availability, {
        'devotional_en',
        'devotional_am',
        'study_material_en',
        'study_material_am',
      });
      expect(detail.authorsFor('devotional_en').single.name, 'Hawi Fikru');
      expect(detail.authorsFor('devotional_am').single.name, 'Kibru Abebe');
      expect(detail.authorsFor('nonexistent_en'), isEmpty);
      expect(detail.artists, isNotEmpty);
    });
  });

  group('getArticle', () {
    test('turns a youtube frontmatter id into a watchable url', () async {
      final client = _FixtureHttpClient({
        'content': 'Body text',
        'title': 'True Love',
        'date': 'December 30, 2025',
        'header': 'A header',
        'audio': 'youtube/_cMxraX_5RE',
      });
      final source = ContentApiDataSourceImpl(client);

      final article = await source.getArticle(
        const TopicId(themeSlug: 'love-faith-and-hope', subtopicSlug: 'love'),
        'devotional_en',
      );

      expect(article.content, 'Body text');
      expect(article.title, 'True Love');
      expect(article.youtubeUrl, 'https://www.youtube.com/watch?v=_cMxraX_5RE');
      expect(
        client.lastEndpoint,
        '/api/v1/articles/love-faith-and-hope/love/devotional_en',
      );
    });

    test('leaves youtubeUrl null when frontmatter has no audio', () async {
      final source = ContentApiDataSourceImpl(
        _FixtureHttpClient({'content': 'Body', 'audio': null}),
      );

      final article = await source.getArticle(
        const TopicId(themeSlug: 't', subtopicSlug: 's'),
        'devotional_en',
      );

      expect(article.youtubeUrl, isNull);
    });

    test('survives a malformed payload instead of throwing', () async {
      final source = ContentApiDataSourceImpl(
        _FixtureHttpClient({'content': 42, 'graphics': 'not-an-object'}),
      );

      final article = await source.getArticle(
        const TopicId(themeSlug: 't', subtopicSlug: 's'),
        'devotional_en',
      );

      expect(article.content, isEmpty);
    });
  });

  group('TopicId', () {
    test('round trips through its route value', () {
      const id = TopicId(
        themeSlug: 'names-of-god',
        subtopicSlug: 'jehovah-jireh',
      );

      expect(id.value, 'names-of-god~jehovah-jireh');
      expect(TopicId.parse(id.value), id);
    });

    test('treats a legacy bare slug as invalid rather than crashing', () {
      final id = TopicId.parse('love');

      expect(id.subtopicSlug, 'love');
      expect(id.isValid, isFalse);
    });
  });

  group('ArticleType', () {
    test('builds the slugs Endpoint 4 expects', () {
      expect(ArticleType.devotional.slugFor('en'), 'devotional_en');
      expect(ArticleType.studyMaterial.slugFor('am'), 'study_material_am');
      // Unsupported locales fall back to English rather than 404ing.
      expect(ArticleType.devotional.slugFor('fr'), 'devotional_en');
    });
  });
}
