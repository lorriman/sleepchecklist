import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:equatable/equatable.dart';

// ignore_for_file: unused_local_variable

class CheckListTrackerItem extends Equatable {
  const CheckListTrackerItem({
    required this.name,
    required this.selected,
  });

  final String name;
  final bool selected;

  @override
  List<Object?> get props => [
        name,
        selected,
      ];

  @override
  bool get stringify => true;
}

class CheckListTracker extends Equatable {
  const CheckListTracker({
    //required this.id,
    //required this.checkListId,
    required this.items,
  }); //, required this.description, req

  //final String id;
  //final String checkListId;
  final Map<DateTime, List<CheckListTrackerItem>> items;

  //v1 is a data version, later versions may be more compact
  // the ignore below is because it's a database field name and we want to signify that.
  // ignore: constant_identifier_names
  static const _tracker_label = 'tracker_v1';

  @override
  List<Object?> get props => [
        //id,
        //checkListId,
        items,
      ]; // , ch

  @override
  bool get stringify => true;

  factory CheckListTracker.fromMap(
      Map<String, dynamic>? data, String? documentId) {
    if (data == null) {
      throw StateError('missing data for ChecklistItemId : $documentId');
    }

    final Map<DateTime, List<CheckListTrackerItem>> items = {};
    if (data[_tracker_label] != null) {
      if (data[_tracker_label].length != 0) {
        //this isn't working and raises an exception
        //checkedDays = (data['checked_days'] as List<int>).cast<int>();
        //so, instead...
        data[_tracker_label]
            .forEach((Timestamp k, List<CheckListTrackerItem> v) {
          final date = k.toDate(); //convert to DateTime
          items[date] = v;
        });
      }
    }

    DateTime date = DateTime.now();
    if (data['date'] != null) {
      date = (data['start_day'] as Timestamp).toDate();
    }

    final trash = (data['trash'] as bool?) ?? false;
    final deleted = (data['deleted'] as bool?) ?? false;

    return CheckListTracker(
      items: items,
    );
  }

  Map<Timestamp, List<String>> toMap() {
    final Map<Timestamp, List<String>> map = {};
    items.forEach((k, v) {
      map[Timestamp.fromDate(k)] = [
        'replace me',
        'replace me'
      ]; //todo this is wrong, temporary stop gap
    });
    return map;
  }
}
