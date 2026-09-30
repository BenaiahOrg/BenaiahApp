part of '../podcast_page.dart';

class _PodcastCategoryChips extends StatelessWidget {
  const _PodcastCategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  /// Categories present on the loaded episodes, so every chip has results.
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      sliver: SliverToBoxAdapter(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['All', ...categories].map((category) {
              final isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category.tr()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onCategorySelected(category);
                    }
                  },
                  labelStyle: TextStyle(
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  selectedColor: isDark ? Colors.white : Colors.black,
                  backgroundColor: isDark
                      ? Colors.white10
                      : Colors.black.withAlpha(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide.none,
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
