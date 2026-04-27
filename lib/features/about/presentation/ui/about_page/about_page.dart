import 'dart:async';

import 'package:benaiah_app/gen/assets.gen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'screen/about_screen.dart';
part 'sections/about_top_section.dart';
part 'sections/about_body_section.dart';
part 'sections/about_bottom_section.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _AboutScreen();
  }
}
