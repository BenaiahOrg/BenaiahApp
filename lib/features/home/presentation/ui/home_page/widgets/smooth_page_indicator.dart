import 'package:flutter/material.dart';

class SmoothPageIndicator extends StatelessWidget {
  const SmoothPageIndicator({
    required this.count,
    required this.scrollPosition,
    required this.activeColor,
    super.key,
  });

  final int count;
  final double scrollPosition;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) {
          // 1 on the current page, falling to 0 one page away, so the dot
          // grows from 8 px to a 24 px pill and takes the active color.
          final distance = (index - scrollPosition).abs();
          final factor = (1 - distance).clamp(0.0, 1.0);
          final width = 8 + (16 * factor);
          final color = Color.lerp(
            Colors.grey.withAlpha(80),
            activeColor,
            factor,
          )!;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: width,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }
}
