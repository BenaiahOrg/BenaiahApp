import 'dart:async';

import 'package:benaiah_app/core/error/app_error.dart';
import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/features/content/domain/entities/series.dart';
import 'package:benaiah_app/features/content/domain/entities/topic.dart';
import 'package:benaiah_app/features/content/presentation/providers/series_list_notifier.dart';
import 'package:benaiah_app/features/content/presentation/ui/search/content_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'screen/home_screen.dart';
part 'sections/home_body_section.dart';
part 'sections/home_top_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _HomeScreen();
  }
}
