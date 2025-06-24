import 'package:intl/intl.dart';

class DateTimeHelpers {
  static String formatDate(DateTime? date, bool includeTime) {
    date ??= DateTime.now();
    final onlyDate = DateFormat('dd/MM/yyyy').format(date);
    final onlyTime = DateFormat('hh:mm').format(date);
    if (includeTime) {
      return '$onlyDate at $onlyTime';
    } else {
      return onlyDate;
    }
  }

  // 1 - monday
  static String weekdayToString(int weekday, [bool? titlecase]) {
    final weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final day = weekdays[weekday - 1];
    // If lowercase is false, capitalize the first letter and add the rest of the string.
    return titlecase == null ? day : titlecase ? '${day[0].toUpperCase()}${day.substring(1)}' : day;
  }

  // Dart's DateTime.weekday returns 1 for Monday and 7 for Sunday.
  static int getDayOfWeek(DateTime dateTime) {
    return dateTime.weekday;
  }

  static String dateTimeToWeekdayString(DateTime dateTime, [bool? titlecase]) {
    return weekdayToString(getDayOfWeek(dateTime), titlecase);
  }
}