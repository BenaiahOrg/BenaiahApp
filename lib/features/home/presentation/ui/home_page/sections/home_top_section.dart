part of '../home_page.dart';

class _HomeTopSection extends StatelessWidget {
  const _HomeTopSection();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      centerTitle: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 70,
      title: Text(
        'BENAIAH',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
      ),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            return IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ContentSearchDelegate(ref),
                );
              },
              icon: const Icon(Icons.search),
            );
          },
        ),
      ],
    );
  }
}
