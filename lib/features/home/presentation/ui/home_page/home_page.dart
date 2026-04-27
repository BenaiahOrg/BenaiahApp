import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'screen/home_screen.dart';
part 'sections/home_top_section.dart';
part 'sections/home_body_section.dart';
part 'sections/home_bottom_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _HomeScreen();
  }
}
