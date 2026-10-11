import 'package:intl/intl.dart';

class DateFormatters {
  DateFormatters._();

  static String short(DateTime d) => DateFormat('MMM d').format(d);

  static String full(DateTime d) => DateFormat('MMM d, y').format(d);

  static String form(DateTime d) => DateFormat('MM/dd/yyyy').format(d);

  static String header(DateTime d) => DateFormat('EEEE, MMM d').format(d);

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}