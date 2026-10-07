import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTaskDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference < -1) {
      return 'Overdue (${difference.abs()}d)';
    } else if (difference < 7) {
      return DateFormat('EEEE').format(date); // e.g. Friday
    } else {
      return DateFormat('MMM d').format(date); // e.g. Oct 15
    }
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  static String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    return timeStr;
  }
}
