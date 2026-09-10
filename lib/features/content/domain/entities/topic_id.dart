import 'package:equatable/equatable.dart';

/// Addresses one subtopic across the whole catalog.
///
/// A subtopic slug is only unique inside its theme — "love" exists under more
/// than one — so a topic is identified by the pair. The pair collapses to a
/// single [value] string because routes carry one `:topicId` path parameter.
class TopicId extends Equatable {
  const TopicId({required this.themeSlug, required this.subtopicSlug});

  /// Parses a [value] produced by this class. Falls back to treating the whole
  /// string as a subtopic slug so older links do not hard-crash the router.
  factory TopicId.parse(String value) {
    final index = value.indexOf(separator);
    if (index < 0) {
      return TopicId(themeSlug: '', subtopicSlug: value);
    }
    return TopicId(
      themeSlug: value.substring(0, index),
      subtopicSlug: value.substring(index + 1),
    );
  }

  /// `~` is URL-unreserved and never appears in a generated slug, so it round
  /// trips through a route without escaping.
  static const separator = '~';

  final String themeSlug;
  final String subtopicSlug;

  String get value => '$themeSlug$separator$subtopicSlug';

  bool get isValid => themeSlug.isNotEmpty && subtopicSlug.isNotEmpty;

  @override
  List<Object?> get props => [themeSlug, subtopicSlug];

  @override
  String toString() => value;
}
