import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class SleepRating extends Equatable {
  const SleepRating({
    required this.date,
    required this.value,
  });

  final DateTime date;
  final double value;

  @override
  List<Object> get props => [date, value];

  @override
  bool get stringify => true;

  static Map<DateTime, SleepRating>? ratingsMapFromMapIndexedByDateOnMonth(
      {Map<String, dynamic>? data, required DateTime month}) {
    final Map<DateTime, SleepRating> map = {};
    if (data == null) return map;
    data.forEach((dateString, dynamic rating) {
      final DateTime date = DateTime.parse(dateString);
      map[date] = SleepRating(
        date: date,
        value: rating as double,
      );
    });
    return map;
  }

  SleepRating copy({DateTime? newDate, double? newValue}) {
    newDate ??= date;
    newValue ??= value;

    return SleepRating(date: newDate, value: newValue);
  }

  static String dateToString(DateTime date) => date.toString().substring(0, 10);
  static String dateToYearMonth(DateTime date) =>
      date.toString().substring(0, 7);
  static String dateToYearMonthDayPlusDayOfWeek(DateTime date) =>
      '${date.toString().substring(0, 10)} ${DateFormat('EE').format(date)}';
  static String labelAsDayOfWeek(DateTime date) {
    final difference = date.difference(DateTime.now()).abs();
    final oneDay = Duration(days: 2);
    final twoDays = Duration(days: 3);

    if (difference < oneDay) {
      return 'Last night';
    }
    if (difference < twoDays) {
      return 'Night before';
    }
    return dateToYearMonthDayPlusDayOfWeek(date);
  }

  static int daysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }
}
