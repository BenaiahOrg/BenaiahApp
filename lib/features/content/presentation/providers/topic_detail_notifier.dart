import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/domain/repositories/content_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'topic_detail_notifier.g.dart';

@Riverpod(keepAlive: true)
class TopicDetailNotifier extends _$TopicDetailNotifier {
  ContentRepository get _repository => container<ContentRepository>();

  @override
  FutureOr<Topic> build(String topicId) async {
    return _fetchTopic(topicId);
  }

  Future<Topic> _fetchTopic(String id) async {
    final result = await _repository.getTopicById(id);
    return switch (result) {
      Success(data: final topic) => topic,
      Failure(:final error) => throw error,
    };
  }
}
