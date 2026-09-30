abstract class DateTimeUtils {
  /// Formats [date] as, e.g., "Jan 12, 2026".
  static String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats a duration in [seconds] as whole minutes, e.g. 180 -> "3m".
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    return '${minutes}m';
  }
}
