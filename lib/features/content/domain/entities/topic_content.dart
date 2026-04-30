import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:equatable/equatable.dart';

class TopicContent<T> extends Equatable {
  const TopicContent({
    required this.data,
    required this.authors,
  });
  final T data;
  final List<Author> authors;

  @override
  List<Object?> get props => [data, authors];
}
