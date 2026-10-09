import 'package:intl/intl.dart';

class DateFormatters {
  DateFormatters._();

  /// Oct 5
  static String short(DateTime d) => DateFormat('MMM d').format(d);

  /// Oct 5, 2026
  static String full(DateTime d) => DateFormat('MMM d, y').format(d);

  /// 10/05/2026
  static String form(DateTime d) => DateFormat('MM/dd/yyyy').format(d);

  /// Monday, Oct 5
  static String header(DateTime d) => DateFormat('EEEE, MMM d').format(d);

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}