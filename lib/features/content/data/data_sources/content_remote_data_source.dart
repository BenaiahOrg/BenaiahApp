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

      for (var i = 0; i < (jsonList?.length as num).toInt(); i++) {
        final seriesJson = jsonList[i] as Map<String, dynamic>;
        final topicsJson = seriesJson['topics'] as List<dynamic>;

        final topics = <Topic>[];

        List<Author> parseAuthors(Map<String, dynamic>? parentJson) {
          if (parentJson == null) return const [defaultAuthor];
          final list = parentJson['authors'] as List<dynamic>?;
          if (list == null || list.isEmpty) return const [defaultAuthor];
          return list.map((a) {
            final map = a as Map<String, dynamic>;
            final nameEn = map['name_en'] as String? ?? 'Benaiah Team';
            final nameAm = map['name_am'] as String?;
            return Author(
              id: nameEn.toLowerCase().replaceAll(' ', '-'),
              name: nameEn,
              nameAm: nameAm,
            );
          }).toList();
        }

        for (var j = 0; j < topicsJson.length; j++) {
          final topicJson = topicsJson[j] as Map<String, dynamic>;

          final titleEn =
              topicJson['title_en'] as String? ?? topicJson['title'] as String;
          final titleAm =
              topicJson['title_am'] as String? ?? topicJson['title'] as String;

          final devEnJson = topicJson['devotional_en'] as Map<String, dynamic>? ??
              topicJson['devotional'] as Map<String, dynamic>?;
          final devAmJson = topicJson['devotional_am'] as Map<String, dynamic>? ??
              topicJson['devotional'] as Map<String, dynamic>?;
          final studyEnJson =
              topicJson['study_material_en'] as Map<String, dynamic>? ??
              topicJson['study_material'] as Map<String, dynamic>?;
          final studyAmJson =
              topicJson['study_material_am'] as Map<String, dynamic>? ??
              topicJson['study_material'] as Map<String, dynamic>?;

          final graphicsJson = topicJson['graphics'] as Map<String, dynamic>?;
          final graphicsList = (graphicsJson?['data'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList();
          final List<String> finalGraphics =
              (graphicsList != null && graphicsList.isNotEmpty)
              ? graphicsList
              : [_getImageUrl(i + j + 100)];

          topics.add(
            Topic(
              id: topicJson['id'] as String,
              title: topicJson['title'] as String,
              titleEn: titleEn,
              titleAm: titleAm,
              devotional: TopicContent(
                data: devEnJson != null
                    ? devEnJson['content'] as String
                    : 'Content coming soon...',
                authors: parseAuthors(devEnJson),
              ),
              devotionalEn: TopicContent(
                data: devEnJson != null
                    ? devEnJson['content'] as String
                    : 'Content coming soon...',
                authors: parseAuthors(devEnJson),
              ),
              devotionalAm: TopicContent(
                data: devAmJson != null
                    ? devAmJson['content'] as String
                    : 'ይዘቱ በቅርቡ ይቀርባል...',
                authors: parseAuthors(devAmJson),
              ),
              studyMaterial: TopicContent(
                data: studyEnJson != null
                    ? studyEnJson['content'] as String
                    : 'Study material coming soon...',
                authors: parseAuthors(studyEnJson),
              ),
              studyMaterialEn: TopicContent(
                data: studyEnJson != null
                    ? studyEnJson['content'] as String
                    : 'Study material coming soon...',
                authors: parseAuthors(studyEnJson),
              ),
              studyMaterialAm: TopicContent(
                data: studyAmJson != null
                    ? studyAmJson['content'] as String
                    : 'የጥናት ቁሳቁስ በቅርቡ ይቀርባል...',
                authors: parseAuthors(studyAmJson),
              ),
              graphics: TopicContent(
                data: finalGraphics,
                authors: parseAuthors(graphicsJson),
              ),
            ),
          );
        }

        final seriesTitleEn =
            seriesJson['series_en'] as String? ??
            seriesJson['series'] as String;
        final seriesTitleAm =
            seriesJson['series_am'] as String? ??
            seriesJson['series'] as String;

        seriesList.add(
          Series(
            id: 's$i',
            title: seriesJson['series'] as String,
            titleEn: seriesTitleEn,
            titleAm: seriesTitleAm,
            description:
                'Exploring the ${seriesJson['series']} theme with depth and biblical insight.',
            descriptionEn:
                'Exploring the $seriesTitleEn theme with depth and biblical insight.',
            descriptionAm: seriesJson['series_am'] != null
                ? 'የ$seriesTitleAmን ጭብጥ በጥልቀት እና በመጽሐፍ ቅዱሳዊ ግንዛቤ መመርመር።'
                : 'Exploring the ${seriesJson['series']} theme with depth and biblical insight.',
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
