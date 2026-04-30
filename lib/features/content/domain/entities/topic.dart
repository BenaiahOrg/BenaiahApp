import 'package:benaiah_app/features/content/domain/entities/topic_content.dart';
import 'package:equatable/equatable.dart';

class Topic extends Equatable {
  const Topic({
    required this.id,
    required this.title,
    required this.devotional,
    required this.studyMaterial,
    required this.graphics,
  });
  final String id;
  final String title;
  final TopicContent<String> devotional;
  final TopicContent<String> studyMaterial;
  final TopicContent<List<String>> graphics;

  @override
  List<Object?> get props => [id, title, devotional, studyMaterial, graphics];
}
