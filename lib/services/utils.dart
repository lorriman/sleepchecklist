const uInt32maxValue = 0xFFFFFFFF;
const uInt32minValue = 0;
const int32maxValue = 0x7FFFFFFF;
const int32minValue = -0x80000000;

//web app javascript can't do these
/*
const Uint64maxValue = 0xFFFFFFFFFFFFFFFF;
const Uint64minValue = 0;
const Int64maxValue = 0x7FFFFFFFFFFFFFFF;
const Int64minValue = -0x8000000000000000;
*/
extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  bool isDayBeforeYesterday() {
    final yesterday = DateTime.now().subtract(Duration(days: 2));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  bool isSameDay(final DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(final DateTime other) {
    return year == other.year && month == other.month;
  }

  DateTime dayBefore() {
    return subtract(Duration(days: 1));
  }

  DateTime dayAfter() {
    return add(Duration(days: 1));
  }
}
