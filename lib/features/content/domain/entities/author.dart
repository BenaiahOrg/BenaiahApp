import 'package:equatable/equatable.dart';

class Author extends Equatable {
  const Author({
    required this.id,
    required this.name,
    this.nameAm,
    this.profileImageUrl,
  });
  final String id;
  final String name;
  final String? nameAm;
  final String? profileImageUrl;

  String localizedName(String langCode) {
    if (langCode == 'am' && nameAm != null && nameAm!.isNotEmpty) {
      return nameAm!;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, nameAm, profileImageUrl];
}
