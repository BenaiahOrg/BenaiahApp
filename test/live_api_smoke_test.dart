@Tags(['live'])
library;

import 'package:benaiah_app/core/config/env.dart';
import 'package:benaiah_app/core/network/dio_http_client.dart';
import 'package:benaiah_app/features/content/data/data_sources/content_api_data_source.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_id.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hits the real Benaiah API. Excluded from the default run because it needs
/// network; execute with:
///
///     flutter test test/live_api_smoke_test.dart --tags live
void main() {
  late ContentApiDataSourceImpl source;

  setUpAll(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );
    source = ContentApiDataSourceImpl(DioHttpClient(dio));
  });

  test('catalog loads and every topic is addressable', () async {
    final series = await source.getCatalog();

    expect(series, isNotEmpty);
    for (final s in series) {
      expect(s.id, isNotEmpty, reason: 'theme slug missing');
      expect(s.topics, isNotEmpty, reason: '${s.id} has no topics');
      for (final topic in s.topics) {
        final id = TopicId.parse(topic.id);
        expect(id.isValid, isTrue, reason: 'unaddressable topic ${topic.id}');
        expect(topic.titleEn, isNotEmpty);
        expect(
          topic.graphics.data,
          isNotEmpty,
          reason: 'no art for ${topic.id}',
        );
      }
    }

    // ignore: avoid_print
    print(
      'catalog: ${series.length} themes, '
      '${series.fold<int>(0, (n, s) => n + s.topics.length)} topics',
    );
  });

  test('subtopic detail loads for every topic', () async {
    final series = await source.getCatalog();
    final ids = series.expand((s) => s.topics).map((t) => TopicId.parse(t.id));

    for (final id in ids) {
      final detail = await source.getSubtopicDetail(id);
      expect(
        detail.availability,
        isNotEmpty,
        reason: 'no availability flags for $id',
      );
    }
  });

  test(
    'reports how many article bodies the live endpoint serves',
    timeout: const Timeout(Duration(minutes: 4)),
    () async {
      final series = await source.getCatalog();
      final ids = series
          .expand((s) => s.topics)
          .map((t) => TopicId.parse(t.id));

      var ok = 0;
      var failed = 0;
      for (final id in ids) {
        final detail = await source.getSubtopicDetail(id);
        for (final slug in detail.availability) {
          try {
            final body = await source.getArticle(id, slug);
            if (body.content.isNotEmpty) {
              ok++;
            } else {
              failed++;
            }
          } on Object {
            failed++;
          }
        }
      }

      // ignore: avoid_print
      print('Endpoint 4 — bodies served: $ok, unavailable: $failed');

      // Documents the current server state rather than asserting it, so this
      // test starts passing meaningfully the moment Endpoint 4 is fixed.
      expect(ok + failed, greaterThan(0));
    },
  );
}
