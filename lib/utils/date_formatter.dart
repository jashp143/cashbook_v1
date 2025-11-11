import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static String getTodayRange() {
    final today = DateTime.now();
    return '${formatDate(today)} to ${formatDate(today)}';
  }

  static String getWeeklyRange() {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    return '${formatDate(weekStart)} to ${formatDate(today)}';
  }

  static String getMonthlyRange() {
    final today = DateTime.now();
    final monthStart = DateTime(today.year, today.month, 1);
    return '${formatDate(monthStart)} to ${formatDate(today)}';
  }

  static String getDateRangeString(DateTime start, DateTime end) {
    return '${formatDate(start)} to ${formatDate(end)}';
  }
}

