import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:equatable/equatable.dart';

class Series extends Equatable {
  const Series({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.topics,
  });
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<Topic> topics;

  @override
  List<Object?> get props => [id, title, description, imageUrl, topics];
}
