import 'package:equatable/equatable.dart';

class PodcastHost extends Equatable {
  const PodcastHost({
    required this.id,
    required this.name,
    required this.bio,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String bio;
  final String imageUrl;

  factory PodcastHost.fromJson(Map<String, dynamic> json) {
    return PodcastHost(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, bio, imageUrl];
}
