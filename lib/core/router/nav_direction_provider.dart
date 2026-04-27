import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);
final previousNavIndexProvider = StateProvider<int>((ref) => 0);

class NavUtils {
  static void updateIndex(WidgetRef ref, int newIndex) {
    final current = ref.read(navIndexProvider);
    if (current != newIndex) {
      ref.read(previousNavIndexProvider.notifier).state = current;
      ref.read(navIndexProvider.notifier).state = newIndex;
    }
  }
}
