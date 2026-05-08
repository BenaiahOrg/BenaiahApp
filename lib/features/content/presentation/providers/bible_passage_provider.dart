import 'package:benaiah_app/core/di/injection.dart';
import 'package:benaiah_app/core/network/bible_service.dart';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:youversion_sdk/youversion_sdk.dart';

part 'bible_passage_provider.g.dart';

class BiblePassageParam extends Equatable {
  const BiblePassageParam({
    required this.passageId,
    required this.bibleId,
  });

  final String passageId;
  final String bibleId;

  @override
  List<Object?> get props => [passageId, bibleId];
}

@Riverpod(keepAlive: true)
FutureOr<Passage> biblePassage(Ref ref, BiblePassageParam param) {
  final bibleService = container<BibleService>();

  return bibleService.getPassage(
    param.passageId,
    bibleId: param.bibleId,
  );
}
