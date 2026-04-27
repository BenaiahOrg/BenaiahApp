import 'package:benaiah_app/features/about/domain/entities/about_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'about_model.g.dart';

@JsonSerializable()
class AboutModel extends AboutEntity {
  const AboutModel() : super();

  factory AboutModel.fromJson(Map<String, dynamic> json) =>
      _$AboutModelFromJson(json);

  Map<String, dynamic> toJson() => _$AboutModelToJson(this);
}
