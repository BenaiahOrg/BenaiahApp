import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:equatable/equatable.dart';

class TopicContent<T> extends Equatable {
  const TopicContent({
    required this.data,
    required this.authors,
    this.youtubeUrl,
    this.title,
    this.header,
    this.date,
  });
  final T data;
  final List<Author> authors;
  final String? youtubeUrl;

  /// Article frontmatter. Only set for devotional and study bodies; the date
  /// is kept verbatim because Amharic articles use the Ethiopian calendar.
  final String? title;
  final String? header;
  final String? date;

  @override
  List<Object?> get props => [data, authors, youtubeUrl, title, header, date];
}
