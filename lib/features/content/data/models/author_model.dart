import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:json_annotation/json_annotation.dart';

part 'author_model.g.dart';

@JsonSerializable()
class AuthorModel extends Author {
  const AuthorModel({
    required super.id,
    required super.name,
    super.profileImageUrl,
  });

  factory AuthorModel.fromEntity(Author entity) {
    return AuthorModel(
      id: entity.id,
      name: entity.name,
      profileImageUrl: entity.profileImageUrl,
    );
  }

  factory AuthorModel.fromJson(Map<String, dynamic> json) =>
      _$AuthorModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorModelToJson(this);
}
