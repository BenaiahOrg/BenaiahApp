import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/core/network/http_client.dart';
import 'package:benaiah_app/features/podcast/domain/entities/podcast_episode.dart';

abstract class PodcastRemoteDataSource {
  HttpClient get client;
  Future<Result<List<PodcastEpisode>>> getEpisodes();
}

@LazySingleton(as: PodcastRemoteDataSource)
class PodcastRemoteDataSourceImpl implements PodcastRemoteDataSource {
  PodcastRemoteDataSourceImpl(this.client);

  @override
  final HttpClient client;

  @override
  Future<Result<List<PodcastEpisode>>> getEpisodes() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/benaiah_podcasts.json',
      );
      final jsonList = json.decode(jsonString) as List<dynamic>;

      final episodes = jsonList
          .map((item) => PodcastEpisode.fromJson(item as Map<String, dynamic>))
          .toList();

      return Success(episodes);
    } on Exception catch (e, st) {
      return Failure(GenericError(stackTrace: st, cause: e.toString()));
    }
  }
}
