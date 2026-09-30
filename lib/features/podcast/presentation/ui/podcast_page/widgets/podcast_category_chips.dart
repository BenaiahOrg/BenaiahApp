part of '../podcast_page.dart';

class _PodcastCategoryChips extends StatelessWidget {
  const _PodcastCategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.insets,
  });

  /// Categories present on the loaded episodes, so every chip has results.
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final EdgeInsets insets;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SliverPadding(
      padding: const EdgeInsets.only(top: 8),
      sliver: SliverToBoxAdapter(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: insets,
          child: Row(
            spacing: 8,
            children: ['All', ...categories].map((category) {
              final isSelected = selectedCategory == category;
              return ChoiceChip(
                label: Text(category.tr()),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onCategorySelected(category);
                  }
                },
                labelStyle: TextStyle(
                  color: isSelected ? scheme.onPrimary : scheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                selectedColor: scheme.primary,
                backgroundColor: scheme.surfaceContainerLow,
                shape: const StadiumBorder(),
                side: BorderSide.none,
                showCheckmark: false,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
