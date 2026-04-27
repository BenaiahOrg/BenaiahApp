import 'package:benaiah_app/features/settings/domain/entities/settings_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings_model.g.dart';

@JsonSerializable()
class SettingsModel extends SettingsEntity {
  const SettingsModel() : super();

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsModelToJson(this);
}
