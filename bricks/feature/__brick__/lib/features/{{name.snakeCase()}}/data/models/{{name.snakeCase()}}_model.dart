import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/{{name.snakeCase()}}_entity.dart';

part '{{name.snakeCase()}}_model.g.dart';

@JsonSerializable()
class {{name.pascalCase()}}Model extends {{name.pascalCase()}}Entity {
  const {{name.pascalCase()}}Model() : super();

  factory {{name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) =>
      _${{name.pascalCase()}}ModelFromJson(json);

  Map<String, dynamic> toJson() => _${{name.pascalCase()}}ModelToJson(this);
}
