import 'package:benaiah_app/features/content/data/models/topic_content_model.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:json_annotation/json_annotation.dart';

part 'topic_model.g.dart';

@JsonSerializable()
class TopicModel extends Topic {
  @override
  final TopicContentModel<String> devotional;
  @override
  final TopicContentModel<String> studyMaterial;
  @override
  final TopicContentModel<List<String>> graphics;
  @override
  final TopicContentModel<String> devotionalEn;
  @override
  final TopicContentModel<String> devotionalAm;
  @override
  final TopicContentModel<String> studyMaterialEn;
  @override
  final TopicContentModel<String> studyMaterialAm;

  const TopicModel({
    required super.id,
    required super.title,
    required this.devotional,
    required this.studyMaterial,
    required this.graphics,
    required super.titleEn,
    required super.titleAm,
    required this.devotionalEn,
    required this.devotionalAm,
    required this.studyMaterialEn,
    required this.studyMaterialAm,
  }) : super(
         devotional: devotional,
         studyMaterial: studyMaterial,
         graphics: graphics,
         devotionalEn: devotionalEn,
         devotionalAm: devotionalAm,
         studyMaterialEn: studyMaterialEn,
         studyMaterialAm: studyMaterialAm,
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
      titleEn: entity.titleEn,
      titleAm: entity.titleAm,
      devotionalEn: TopicContentModel<String>.fromEntity(entity.devotionalEn),
      devotionalAm: TopicContentModel<String>.fromEntity(entity.devotionalAm),
      studyMaterialEn: TopicContentModel<String>.fromEntity(
        entity.studyMaterialEn,
      ),
      studyMaterialAm: TopicContentModel<String>.fromEntity(
        entity.studyMaterialAm,
      ),
    );
  }
}
