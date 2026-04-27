import 'dart:async';

import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/core/theme/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'screen/settings_screen.dart';
part 'sections/settings_top_section.dart';
part 'sections/settings_body_section.dart';
part 'sections/settings_bottom_section.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _SettingsScreen();
  }
}
