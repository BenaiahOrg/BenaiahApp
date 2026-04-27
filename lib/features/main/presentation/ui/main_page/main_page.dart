import 'package:benaiah_app/core/router/nav_direction_provider.dart';
import 'package:benaiah_app/core/router/route_names.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'screen/main_screen.dart';
part 'sections/main_top_section.dart';
part 'sections/main_body_section.dart';
part 'sections/main_bottom_section.dart';

class MainPage extends ConsumerWidget {
  const MainPage({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MainScreen(child: child);
  }
}
