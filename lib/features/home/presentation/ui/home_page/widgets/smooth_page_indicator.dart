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
          // Absolute distance from current scroll position
          final distance = (index - scrollPosition).abs();

          // Interpolate factor: 1.0 at active center, 0.0 when further
          final factor = (1 - distance).clamp(0.0, 1.0);

          // Width: 8 (inactive dot) to 24 (active pill)
          final width = 8 + (16 * factor);

          // Color fades smoothly between grey and active theme color
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
