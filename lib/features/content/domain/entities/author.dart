import 'package:equatable/equatable.dart';

class Author extends Equatable {
  const Author({
    required this.id,
    required this.name,
    this.nameAm,
    this.profileImageUrl,
    this.role,
    this.roleAm,
  });
  final String id;
  final String name;
  final String? nameAm;
  final String? profileImageUrl;
  final String? role;
  final String? roleAm;

  String localizedName(String langCode) {
    if (langCode == 'am' && nameAm != null && nameAm!.isNotEmpty) {
      return nameAm!;
    }
    return name;
  }

  String? localizedRole(String langCode) {
    if (langCode == 'am' && roleAm != null && roleAm!.isNotEmpty) {
      return roleAm;
    }
    return role;
  }

  @override
  List<Object?> get props => [id, name, nameAm, profileImageUrl, role, roleAm];
}
