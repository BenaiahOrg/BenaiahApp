import 'package:flutter/material.dart';

/// Base for the app's search screens. Themes the search bar from the color
/// scheme (the framework default paints grey icons on white), and gives the
/// back and clear buttons the platform back icon and spoken labels.
abstract class AppSearchDelegate extends SearchDelegate<String?> {
  AppSearchDelegate({required String super.searchFieldLabel});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        // Visibly lighter than typed text: 54% of the text color, which
        // still clears 4.5:1 on the page background in both themes.
        hintStyle: theme.textTheme.titleMedium?.copyWith(
          color: scheme.onSurface.withAlpha(138),
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const BackButtonIcon(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => close(context, null),
    );
  }
}
