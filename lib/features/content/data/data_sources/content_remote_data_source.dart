import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/core/network/http_client.dart';
import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:benaiah_app/features/content/domain/entities/series.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_content.dart';

abstract class ContentRemoteDataSource {
  HttpClient get client;
  Future<Result<List<Series>>> getSeriesList();
  Future<Result<Series>> getSeriesById(String id);
  Future<Result<Topic>> getTopicById(String id);
}

@LazySingleton(as: ContentRemoteDataSource)
class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  ContentRemoteDataSourceImpl(this.client);

  @override
  final HttpClient client;

  static const _biblicalImages = [
    'https://picsum.photos/id/1011/800/600', // Bible/Old feeling
    'https://picsum.photos/id/1015/800/600', // Nature
    'https://picsum.photos/id/1016/800/600', // Mountains
    'https://picsum.photos/id/1018/800/600', // World
    'https://picsum.photos/id/1019/800/600', // Light
    'https://picsum.photos/id/1020/800/600', // Ancient
    'https://picsum.photos/id/1021/800/600', // People
  ];

  String _getImageUrl(int index) {
    return _biblicalImages[index % _biblicalImages.length];
  }

  @override
  Future<Result<List<Series>>> getSeriesList() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/benaiah_content.json',
      );
      final jsonList = json.decode(jsonString) as List<dynamic>;

      final seriesList = <Series>[];
      const defaultAuthor = Author(id: 'benaiah_team', name: 'Benaiah Team');

      for (var i = 0; i < jsonList.length; i++) {
        final seriesJson = jsonList[i] as Map<String, dynamic>;
        final topicsJson = seriesJson['topics'] as List<dynamic>;

        final topics = <Topic>[];
        for (var j = 0; j < topicsJson.length; j++) {
          final topicJson = topicsJson[j] as Map<String, dynamic>;
          final devJson =
              topicJson['devotional'] as Map<String, dynamic>?;
          final studyJson =
              topicJson['study_material'] as Map<String, dynamic>?;

          topics.add(
            Topic(
              id: topicJson['id'] as String,
              title: topicJson['title'] as String,
              devotional: TopicContent(
                data: devJson != null
                    ? devJson['content'] as String
                    : 'Content coming soon...',
                authors: const [defaultAuthor],
              ),
              studyMaterial: TopicContent(
                data: studyJson != null
                    ? studyJson['content'] as String
                    : 'Study material coming soon...',
                authors: const [defaultAuthor],
              ),
              graphics: const TopicContent(
                data: [],
                authors: [defaultAuthor],
              ),
            ),
          );
        }

        seriesList.add(
          Series(
            id: 's$i',
            title: seriesJson['series'] as String,
            description: 'Exploring the ${seriesJson['series']} '
                'theme with depth and biblical insight.',
            imageUrl: _getImageUrl(i),
            topics: topics,
          ),
        );
      }

      return Success(seriesList);
    } on Exception catch (e, st) {
      return Failure(GenericError(stackTrace: st, cause: e.toString()));
    }
  }

  @override
  Future<Result<Series>> getSeriesById(String id) async {
    final result = await getSeriesList();
    return switch (result) {
      Success(data: final list) => Success(list.firstWhere((s) => s.id == id)),
      Failure(error: final e) => Failure(e),
    };
  }

  @override
  Future<Result<Topic>> getTopicById(String id) async {
    final result = await getSeriesList();
    return switch (result) {
      Success(data: final list) => Success(
        list.expand((s) => s.topics).firstWhere((t) => t.id == id),
      ),
      Failure(error: final e) => Failure(e),
    };
  }
}
