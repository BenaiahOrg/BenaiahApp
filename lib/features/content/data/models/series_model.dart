import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/series.dart';
import 'topic_model.dart';

part 'series_model.g.dart';

@JsonSerializable()
class SeriesModel extends Series {
  @override
  final List<TopicModel> topics;

  const SeriesModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required this.topics,
  }) : super(topics: topics);

  factory SeriesModel.fromJson(Map<String, dynamic> json) =>
      _$SeriesModelFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesModelToJson(this);

  factory SeriesModel.fromEntity(Series entity) {
    return SeriesModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imageUrl: entity.imageUrl,
      topics: entity.topics.map((e) => TopicModel.fromEntity(e)).toList(),
    );
  }
}
