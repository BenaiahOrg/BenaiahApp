import 'dart:convert';

import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:benaiah_app/features/content/domain/entities/series.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

abstract class ContentRemoteDataSource {
  Future<Result<List<Series>>> getSeriesList();
  Future<Result<Series>> getSeriesById(String id);
  Future<Result<Topic>> getTopicById(String id);
}

@LazySingleton(as: ContentRemoteDataSource)
class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  ContentRemoteDataSourceImpl();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static const _defaultAuthor = Author(
    id: 'benaiah-team',
    name: 'Benaiah Team',
  );

  @override
  Future<Result<List<Series>>> getSeriesList() async {
    try {
      return Success(await _getSeriesListFromFirestore());
    } on Exception {
      return _getSeriesListFromSeedJson();
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

  Future<List<Series>> _getSeriesListFromFirestore() async {
    final contributors = await _getContributorsById();
    final snapshot = await _firestore
        .collection('series')
        .where('isPublished', isEqualTo: true)
        .orderBy('order')
        .get();

    return Future.wait(
      snapshot.docs.map((doc) async {
        final topicsSnapshot = await doc.reference
            .collection('topics')
            .where('isPublished', isEqualTo: true)
            .orderBy('order')
            .get();

        final topics = topicsSnapshot.docs
            .map((topicDoc) => _topicFromFirestore(topicDoc, contributors))
            .toList();
        final data = doc.data();

        return Series(
          id: doc.id,
          title: _string(data, 'title'),
          titleEn: _string(data, 'titleEn', fallback: _string(data, 'title')),
          titleAm: _string(data, 'titleAm', fallback: _string(data, 'title')),
          description: _string(data, 'description'),
          descriptionEn: _string(
            data,
            'descriptionEn',
            fallback: _string(data, 'description'),
          ),
          descriptionAm: _string(
            data,
            'descriptionAm',
            fallback: _string(data, 'description'),
          ),
          imageUrl: _string(data, 'imageUrl'),
          topics: topics,
        );
      }),
    );
  }

  Future<Map<String, Author>> _getContributorsById() async {
    final snapshot = await _firestore.collection('contributors').get();
    if (snapshot.docs.isEmpty) {
      final legacySnapshot = await _firestore.collection('authors').get();
      return {
        for (final doc in legacySnapshot.docs)
          doc.id: Author(
            id: doc.id,
            name: _string(doc.data(), 'name'),
            nameAm: doc.data()['nameAm'] as String?,
            profileImageUrl: _nullableString(
              doc.data(),
              'profileImageUrl',
              fallbackKey: 'imageUrl',
            ),
          ),
      };
    }

    return {
      for (final doc in snapshot.docs)
        doc.id: Author(
          id: doc.id,
          name: _string(doc.data(), 'name'),
          nameAm: doc.data()['nameAm'] as String?,
          profileImageUrl: _nullableString(
            doc.data(),
            'profileImageUrl',
            fallbackKey: 'imageUrl',
          ),
        ),
    };
  }

  Topic _topicFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, Author> contributors,
  ) {
    final data = doc.data();
    final devotionalEn = _textContent(data['devotionalEn'], contributors);
    final devotionalAm = _textContent(data['devotionalAm'], contributors);
    final studyMaterialEn = _textContent(data['studyMaterialEn'], contributors);
    final studyMaterialAm = _textContent(data['studyMaterialAm'], contributors);
    final graphics = _graphicsContent(data['graphics'], contributors);

    return Topic(
      id: doc.id,
      title: _string(data, 'title'),
      titleEn: _string(data, 'titleEn', fallback: _string(data, 'title')),
      titleAm: _string(data, 'titleAm', fallback: _string(data, 'title')),
      devotional: devotionalEn,
      devotionalEn: devotionalEn,
      devotionalAm: devotionalAm,
      studyMaterial: studyMaterialEn,
      studyMaterialEn: studyMaterialEn,
      studyMaterialAm: studyMaterialAm,
      graphics: graphics,
    );
  }

  TopicContent<String> _textContent(
    Object? value,
    Map<String, Author> contributors,
  ) {
    final data = value is Map<String, dynamic> ? value : <String, dynamic>{};
    return TopicContent<String>(
      data: _string(data, 'content'),
      authors: _authorsFromIds(
        data['contributorIds'] ?? data['authorIds'],
        contributors,
      ),
      youtubeUrl: data['youtubeUrl'] as String?,
    );
  }

  TopicContent<List<String>> _graphicsContent(
    Object? value,
    Map<String, Author> contributors,
  ) {
    final data = value is Map<String, dynamic> ? value : <String, dynamic>{};
    final urls = data['urls'] is List
        ? (data['urls'] as List).whereType<String>().toList()
        : const <String>[];

    return TopicContent<List<String>>(
      data: urls,
      authors: _authorsFromIds(
        data['contributorIds'] ?? data['authorIds'],
        contributors,
      ),
    );
  }

  List<Author> _authorsFromIds(Object? value, Map<String, Author> authors) {
    if (value is! List || value.isEmpty) {
      return const [_defaultAuthor];
    }

    final resolved = value
        .whereType<String>()
        .map((id) => authors[id])
        .whereType<Author>()
        .toList();

    return resolved.isEmpty ? const [_defaultAuthor] : resolved;
  }

  Future<Result<List<Series>>> _getSeriesListFromSeedJson() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/benaiah_content.json',
      );
      final jsonList = json.decode(jsonString) as List<dynamic>;

      return Success(
        [
          for (var i = 0; i < jsonList.length; i++)
            _seriesFromSeedJson(i, jsonList[i] as Map<String, dynamic>),
        ],
      );
    } on Exception catch (e, st) {
      return Failure(GenericError(stackTrace: st, cause: e));
    }
  }

  Series _seriesFromSeedJson(int index, Map<String, dynamic> json) {
    final topicsJson = json['topics'] as List<dynamic>? ?? const [];
    final topics = [
      for (final topicJson in topicsJson)
        _topicFromSeedJson(topicJson as Map<String, dynamic>),
    ];
    final titleEn = json['series_en'] as String? ?? json['series'] as String;
    final titleAm = json['series_am'] as String? ?? json['series'] as String;
    final imageUrl = topics
        .expand((topic) => topic.graphics.data)
        .cast<String?>()
        .firstWhere((url) => url != null, orElse: () => null);

    return Series(
      id: 's$index',
      title: json['series'] as String,
      titleEn: titleEn,
      titleAm: titleAm,
      description:
          'Exploring the ${json['series']} theme with depth and '
          'biblical insight.',
      descriptionEn:
          'Exploring the $titleEn theme with depth and biblical '
          'insight.',
      descriptionAm: json['series_am'] != null
          ? 'የ$titleAmን ጭብጥ በጥልቀት እና በመጽሐፍ ቅዱሳዊ ግንዛቤ መመርመር።'
          : 'Exploring the ${json['series']} theme with depth and biblical '
                'insight.',
      imageUrl: imageUrl ?? '',
      topics: topics,
    );
  }

  Topic _topicFromSeedJson(Map<String, dynamic> json) {
    final titleEn = json['title_en'] as String? ?? json['title'] as String;
    final titleAm = json['title_am'] as String? ?? json['title'] as String;
    final devotionalEn = _seedTextContent(
      json['devotional_en'] as Map<String, dynamic>?,
      fallback: 'Content coming soon...',
    );
    final devotionalAm = _seedTextContent(
      json['devotional_am'] as Map<String, dynamic>?,
      fallback: 'ይዘቱ በቅርቡ ይቀርባል...',
    );
    final studyMaterialEn = _seedTextContent(
      json['study_material_en'] as Map<String, dynamic>?,
      fallback: 'Study material coming soon...',
    );
    final studyMaterialAm = _seedTextContent(
      json['study_material_am'] as Map<String, dynamic>?,
      fallback: 'የጥናት ቁሳቁስ በቅርቡ ይቀርባል...',
    );
    final graphicsJson = json['graphics'] as Map<String, dynamic>?;

    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      titleEn: titleEn,
      titleAm: titleAm,
      devotional: devotionalEn,
      devotionalEn: devotionalEn,
      devotionalAm: devotionalAm,
      studyMaterial: studyMaterialEn,
      studyMaterialEn: studyMaterialEn,
      studyMaterialAm: studyMaterialAm,
      graphics: TopicContent<List<String>>(
        data:
            (graphicsJson?['data'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            const <String>[],
        authors: _seedAuthors(graphicsJson),
      ),
    );
  }

  TopicContent<String> _seedTextContent(
    Map<String, dynamic>? json, {
    required String fallback,
  }) {
    return TopicContent<String>(
      data: json?['content'] as String? ?? fallback,
      authors: _seedAuthors(json),
      youtubeUrl: json?['youtube_url'] as String?,
    );
  }

  List<Author> _seedAuthors(Map<String, dynamic>? json) {
    final authorsJson = json?['authors'] as List<dynamic>?;
    if (authorsJson == null || authorsJson.isEmpty) {
      return const [_defaultAuthor];
    }

    return authorsJson.map((authorJson) {
      final map = authorJson as Map<String, dynamic>;
      final name = map['name_en'] as String? ?? 'Benaiah Team';
      return Author(
        id: _slugify(name),
        name: name,
        nameAm: map['name_am'] as String?,
      );
    }).toList();
  }

  String _string(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    return data[key] as String? ?? fallback;
  }

  String? _nullableString(
    Map<String, dynamic> data,
    String key, {
    String? fallbackKey,
  }) {
    final direct = data[key] as String?;
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }
    if (fallbackKey == null) {
      return null;
    }
    final fallback = data[fallbackKey] as String?;
    return fallback != null && fallback.isNotEmpty ? fallback : null;
  }

  String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
