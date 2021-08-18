import 'package:equatable/equatable.dart';

class Rating extends Equatable {
  static String dateToString(DateTime date) => date.toString().substring(0, 10);

  const Rating({
    required this.checklistItemId,
    required this.date,
    required this.value,
  });

  final String checklistItemId;
  final DateTime date;
  final double value;

  @override
  List<Object> get props => [checklistItemId, date, value];

  @override
  bool get stringify => true;

  static Map<DateTime, Rating>? ratingsMapFromMapIndexedByDate(
    Map<String, dynamic>? data,
    String checklistItemId,
  ) {
    if (data == null) return null;
    final Map<DateTime, Rating> map = {};
    data.forEach((key, dynamic value) {
      final DateTime date = DateTime.parse(key);
      map[date] = Rating(
        checklistItemId: checklistItemId,
        date: date,
        value: value as double,
      );
    });
    return map;
  }

  static Map<String, Rating> ratingsMapFromMapIndexedByChecklistItemId(
      Map<String, dynamic>? data,
      {required DateTime suppliedMonth}) {
    final Map<String, Rating> map = {};
    final localData = data;
    data?.forEach((itemId, dynamic rating) {
      dynamic r = rating;
      map[itemId] = Rating(
        checklistItemId: itemId,
        date: suppliedMonth,
        value: rating as double,
      );
    });

    return map;
  }

  Map<String, dynamic> insertMapByDate(Map<String, dynamic> map) {
    map[date.toString().substring(0, 10)] = value;
    return map;
  }

  Map<String, dynamic> insertMapByChecklistItemId(Map<String, dynamic> map) {
    map[checklistItemId] = value;
    return map;
  }
}
