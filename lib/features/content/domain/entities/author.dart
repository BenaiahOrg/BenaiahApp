import 'package:equatable/equatable.dart';

class Author extends Equatable {
  const Author({
    required this.id,
    required this.name,
    this.profileImageUrl,
  });
  final String id;
  final String name;
  final String? profileImageUrl;

  @override
  List<Object?> get props => [id, name, profileImageUrl];
}
