import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/core/utils/string_utils.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_host.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

// Kept as an interface to match the feature data-source pattern.
// ignore: one_member_abstracts
abstract class PodcastRemoteDataSource {
  Future<Result<List<PodcastEpisode>>> getEpisodes();
}

@LazySingleton(as: PodcastRemoteDataSource)
class PodcastRemoteDataSourceImpl implements PodcastRemoteDataSource {
  PodcastRemoteDataSourceImpl();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<Result<List<PodcastEpisode>>> getEpisodes() async {
    try {
      return Success(await _getEpisodesFromFirestore());
    } on Exception catch (e, st) {
      return Failure(GenericError(stackTrace: st, cause: e));
    }
  }

  Future<List<PodcastEpisode>> _getEpisodesFromFirestore() async {
    final contributorsById = await _getContributorsById();
    final snapshot = await _firestore
        .collection('podcastEpisodes')
        .where('isPublished', isEqualTo: true)
        .orderBy('publishDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PodcastEpisode(
        id: doc.id,
        title: _string(data, 'title'),
        description: StringUtils.fixMissingWordBoundary(
          _string(data, 'description'),
        ),
        audioUrl: _string(data, 'audioUrl'),
        durationSeconds: data['durationSeconds'] as int? ?? 0,
        imageUrl: _string(data, 'imageUrl'),
        publishDate: _dateTime(data['publishDate']),
        episodeNumber: data['episodeNumber'] as int? ?? 0,
        seasonNumber: data['seasonNumber'] as int? ?? 0,
        hosts: _hostsFromIds(
          data['contributorIds'] ?? data['hostIds'],
          contributorsById,
        ),
        category: _string(data, 'category', fallback: 'General'),
      );
    }).toList();
  }

  Future<Map<String, PodcastHost>> _getContributorsById() async {
    final snapshot = await _firestore.collection('contributors').get();
    if (snapshot.docs.isEmpty) {
      final legacySnapshot = await _firestore.collection('podcastHosts').get();
      return {
        for (final doc in legacySnapshot.docs)
          doc.id: PodcastHost(
            id: doc.id,
            name: _string(doc.data(), 'name'),
            bio: _string(doc.data(), 'bio'),
            imageUrl: _string(doc.data(), 'imageUrl'),
          ),
      };
    }

    return {
      for (final doc in snapshot.docs)
        doc.id: PodcastHost(
          id: doc.id,
          name: _string(doc.data(), 'name'),
          bio: _string(
            doc.data(),
            'bio',
            fallback: _string(doc.data(), 'role'),
          ),
          imageUrl: _string(
            doc.data(),
            'profileImageUrl',
            fallback: _string(doc.data(), 'imageUrl'),
          ),
        ),
    };
  }

  List<PodcastHost> _hostsFromIds(
    Object? value,
    Map<String, PodcastHost> hostsById,
  ) {
    if (value is! List || value.isEmpty) {
      return const [];
    }

    return value
        .whereType<String>()
        .map((id) => hostsById[id])
        .whereType<PodcastHost>()
        .toList();
  }


  DateTime _dateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _string(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    return data[key] as String? ?? fallback;
  }
}
