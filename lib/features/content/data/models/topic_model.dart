import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/topic.dart';
import 'topic_content_model.dart';

part 'topic_model.g.dart';

@JsonSerializable()
class TopicModel extends Topic {
  @override
  final TopicContentModel<String> devotional;
  @override
  final TopicContentModel<String> studyMaterial;
  @override
  final TopicContentModel<List<String>> graphics;

  const TopicModel({
    required super.id,
    required super.title,
    required this.devotional,
    required this.studyMaterial,
    required this.graphics,
  }) : super(
          devotional: devotional,
          studyMaterial: studyMaterial,
          graphics: graphics,
        );

  factory TopicModel.fromJson(Map<String, dynamic> json) =>
      _$TopicModelFromJson(json);

  Map<String, dynamic> toJson() => _$TopicModelToJson(this);

  factory TopicModel.fromEntity(Topic entity) {
    return TopicModel(
      id: entity.id,
      title: entity.title,
      devotional: TopicContentModel<String>.fromEntity(entity.devotional),
      studyMaterial: TopicContentModel<String>.fromEntity(entity.studyMaterial),
      graphics: TopicContentModel<List<String>>.fromEntity(entity.graphics),
    );
  }
}
