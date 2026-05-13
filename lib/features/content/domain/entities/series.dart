import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:equatable/equatable.dart';

class Series extends Equatable {
  const Series({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.topics,
    required this.titleEn,
    required this.titleAm,
    required this.descriptionEn,
    required this.descriptionAm,
  });
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<Topic> topics;
  final String titleEn;
  final String titleAm;
  final String descriptionEn;
  final String descriptionAm;

  String localizedTitle(String langCode) => langCode == 'am' ? titleAm : titleEn;
  String localizedDescription(String langCode) => langCode == 'am' ? descriptionAm : descriptionEn;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        topics,
        titleEn,
        titleAm,
        descriptionEn,
        descriptionAm,
      ];
}
