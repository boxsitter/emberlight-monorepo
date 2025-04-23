import 'package:intl/intl.dart';

class CoreFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    final onlyDate = DateFormat('dd/MM/yyyy').format(date);
    final onlyTime = DateFormat('hh:mm').format(date);
    return '$onlyDate at $onlyTime';
  }

  static String weekdayToString(int weekday, bool lowercase) {
    final weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return lowercase ? weekdays[weekday - 1] : weekdays[weekday - 1].toUpperCase();
  }
}
