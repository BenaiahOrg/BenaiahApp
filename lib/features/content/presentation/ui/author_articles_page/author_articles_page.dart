import 'dart:async';

import 'package:benaiah_app/core/router/route_names.dart';
import 'package:benaiah_app/core/widgets/benaiah_network_image.dart';
import 'package:benaiah_app/core/widgets/benaiah_state_view.dart';
import 'package:benaiah_app/features/content/domain/entities/author.dart';
import 'package:benaiah_app/features/content/domain/entities/author_credit.dart';
import 'package:benaiah_app/features/content/presentation/providers/author_profile_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'screen/author_articles_screen.dart';
part 'sections/author_articles_body_section.dart';

class AuthorArticlesPage extends ConsumerWidget {
  const AuthorArticlesPage({required this.authorId, super.key});

  final String authorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AuthorArticlesScreen(authorId: authorId);
  }
}
