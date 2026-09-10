import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/core/error/result.dart';
import 'package:benaiah_app/features/content/domain/entities/author_credit.dart';
import 'package:benaiah_app/features/content/domain/repositories/content_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'author_profile_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthorProfileNotifier extends _$AuthorProfileNotifier {
  ContentRepository get _repository => container<ContentRepository>();

  @override
  FutureOr<AuthorProfile> build(String authorId) async {
    return _fetchProfile(authorId);
  }

  Future<AuthorProfile> _fetchProfile(String id) async {
    final result = await _repository.getCreditsForAuthor(id);
    return switch (result) {
      Success(data: final profile) => profile,
      Failure(:final error) => throw error,
    };
  }
}
