import 'package:benaiah_app/features/content/domain/entities/topic_content.dart';
import 'package:equatable/equatable.dart';

class Topic extends Equatable {
  const Topic({
    required this.id,
    required this.title,
    required this.devotional,
    required this.studyMaterial,
    required this.graphics,
    required this.titleEn,
    required this.titleAm,
    required this.devotionalEn,
    required this.devotionalAm,
    required this.studyMaterialEn,
    required this.studyMaterialAm,
  });
  final String id;
  final String title;
  final TopicContent<String> devotional;
  final TopicContent<String> studyMaterial;
  final TopicContent<List<String>> graphics;
  final String titleEn;
  final String titleAm;
  final TopicContent<String> devotionalEn;
  final TopicContent<String> devotionalAm;
  final TopicContent<String> studyMaterialEn;
  final TopicContent<String> studyMaterialAm;

  String localizedTitle(String langCode) => langCode == 'am' ? titleAm : titleEn;
  TopicContent<String> localizedDevotional(String langCode) => langCode == 'am' ? devotionalAm : devotionalEn;
  TopicContent<String> localizedStudyMaterial(String langCode) => langCode == 'am' ? studyMaterialAm : studyMaterialEn;

  @override
  List<Object?> get props => [
        id,
        title,
        devotional,
        studyMaterial,
        graphics,
        titleEn,
        titleAm,
        devotionalEn,
        devotionalAm,
        studyMaterialEn,
        studyMaterialAm,
      ];
}
