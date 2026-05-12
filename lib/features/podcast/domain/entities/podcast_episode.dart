import 'package:equatable/equatable.dart';
import 'podcast_host.dart';

class PodcastEpisode extends Equatable {
  const PodcastEpisode({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.durationSeconds,
    required this.imageUrl,
    required this.publishDate,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.hosts,
    required this.category,
  });

  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final int durationSeconds;
  final String imageUrl;
  final DateTime publishDate;
  final int episodeNumber;
  final int seasonNumber;
  final List<PodcastHost> hosts;
  final String category;

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      audioUrl: json['audioUrl'] as String,
      durationSeconds: json['durationSeconds'] as int,
      imageUrl: json['imageUrl'] as String,
      publishDate: DateTime.parse(json['publishDate'] as String),
      episodeNumber: json['episodeNumber'] as int,
      seasonNumber: json['seasonNumber'] as int,
      hosts: (json['hosts'] as List<dynamic>)
          .map((h) => PodcastHost.fromJson(h as Map<String, dynamic>))
          .toList(),
      category: json['category'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'durationSeconds': durationSeconds,
      'imageUrl': imageUrl,
      'publishDate': publishDate.toIso8601String(),
      'episodeNumber': episodeNumber,
      'seasonNumber': seasonNumber,
      'hosts': hosts.map((h) => h.toJson()).toList(),
      'category': category,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        audioUrl,
        durationSeconds,
        imageUrl,
        publishDate,
        episodeNumber,
        seasonNumber,
        hosts,
        category,
      ];
}
