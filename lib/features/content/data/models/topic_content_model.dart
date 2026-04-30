import 'package:benaiah_app/features/content/data/models/author_model.dart';
import 'package:benaiah_app/features/content/domain/entities/topic_content.dart';
import 'package:json_annotation/json_annotation.dart';

part 'topic_content_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class TopicContentModel<T> extends TopicContent<T> {
  const TopicContentModel({
    required super.data,
    required this.authors,
  }) : super(authors: authors);

  factory TopicContentModel.fromEntity(TopicContent<T> entity) {
    return TopicContentModel<T>(
      data: entity.data,
      authors: entity.authors.map(AuthorModel.fromEntity).toList(),
    );
  }

  factory TopicContentModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$TopicContentModelFromJson(json, fromJsonT);

  @override
  final List<AuthorModel> authors;

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$TopicContentModelToJson(this, toJsonT);
}
