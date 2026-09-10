import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:equatable/equatable.dart';

/// Which section of a topic an author is credited on.
enum ArticleRole { devotional, studyMaterial, graphics }

/// One topic an author contributed to, and in what capacity.
class AuthorCredit extends Equatable {
  const AuthorCredit({required this.topic, required this.roles});

  final Topic topic;
  final Set<ArticleRole> roles;

  @override
  List<Object?> get props => [topic, roles];
}

/// An author/artist and every topic they're credited on across the catalog.
class AuthorProfile extends Equatable {
  const AuthorProfile({required this.author, required this.credits});

  final Author author;
  final List<AuthorCredit> credits;

  @override
  List<Object?> get props => [author, credits];
}
