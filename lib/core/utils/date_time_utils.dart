abstract class DateTimeUtils {
  /// Formats a DateTime object into a reader-friendly format, e.g., "Jan 12, 2026".
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
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats a duration in seconds into a truncated minute string, e.g., 180 seconds -> "3m".
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    return '${minutes}m';
  }
}
