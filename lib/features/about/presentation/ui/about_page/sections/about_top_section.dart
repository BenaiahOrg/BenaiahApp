part of '../about_page.dart';

class _AboutTopSection extends StatelessWidget {
  const _AboutTopSection({required this.fadeAnimation});

  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'about'.tr(),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        centerTitle: true,
        background: ColoredBox(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          child: Center(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.1, end: 1).animate(
                  fadeAnimation,
                ),
                child: Image.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? Assets.images.logoWhite.path
                      : Assets.images.logoBlack.path,
                  height: 180,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
