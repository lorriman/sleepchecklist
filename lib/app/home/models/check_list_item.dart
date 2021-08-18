// ignore: file_names

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

//import 'package:insomnia_checklist/app/home/models/check_list_item.dart';
import 'package:insomnia_checklist/app/home/checklistitems/checklistitems_page.dart';

import 'package:insomnia_checklist/app/home/models/check_list_tracker.dart';

enum MealTime { breakfast, lunch, supper, nightcap }

const Map<MealTime, IconData> mealTimeIcons = {
  MealTime.breakfast: Icons.free_breakfast_rounded,
  MealTime.lunch: Icons.lunch_dining,
  MealTime.supper: Icons.local_dining_rounded,
  MealTime.nightcap: Icons.nights_stay_outlined,
};

//extensions to support compact data representation in the database, currently unused
extension MealTimeExt on MealTime {
  static const mealTimeIntMap = <MealTime, int>{
    MealTime.breakfast: 1,
    MealTime.lunch: 2,
    MealTime.supper: 4,
    MealTime.nightcap: 8,
  };

  int toInt() {
    final int? r = mealTimeIntMap[this];
    if (r == null) {
      throw Exception('Unexpected value in MealTimeExt.toInt $this ');
    }

    return r;
  }

  bool hasMealTime(int mealTimes) {
    return (mealTimes & toInt()) > 0;
  }
}

@immutable
class ChecklistItem extends Equatable {
  ChecklistItem({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    //this.tracker = const CheckListTracker(items: {}),
    this.trash = false,
    this.deleted = false,
    this.ordinal,
  }) {
    //we do this because FakeFirestore interprets dots as map qualifiers,
    //making unit tests impossible
    this.id = idStringSanitiser(id);
  } //, required this.description, required this.checked});

  late String id;
  final String name;
  final String description;
  final DateTime startDate;
  //final CheckListTracker tracker;
  final bool trash;
  final bool deleted;
  //we need to deal with any items that don't have a sort ordinal
  //This may (rarely) happen when the editorial team add a new item
  //or if we make a social dimension to the app for sharing items.
  //see [ChecklistItemListTileModelStreamProvider] for the point at
  //which this is detected and dealt with.
  final int? ordinal;

  static String idStringSanitiser(String s) => s.replaceAll('.', ' ');

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        startDate,
        trash,
        deleted,
        ordinal,
      ]; // , checked, description];

  @override
  bool get stringify => true;

  factory ChecklistItem.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for ChecklistItemId : $documentId');
    }
    final name = data['name'] as String?;
    if (name == null) {
      throw StateError('missing name for ChecklistItemId: $documentId');
    }
    //final tracker = CheckListTracker.fromMap(data, documentId);

    final description = data['description'] as String? ?? '';
/*    final checked = data['checked'] as bool? ?? false;

    List<int> checkedDays = [];
    if (data['checked_days'] != null) {
      if (false) {
        if (data['checked_days'].length != 0) {
          //this isn't working and raises an exception
          checkedDays = (data['checked_days'] as List<int>).cast<int>();
        }
      }
    }
*/
    DateTime startDate = DateTime.now();
    if (data['start_day'] != null) {
      //the copy method will have a DateTime, whereas the firestore data will return a Timestamp
      if (data['start_day'] is Timestamp) {
        startDate = (data['start_day'] as Timestamp).toDate();
      } else {
        startDate = data['start_day'] as DateTime;
      }
    }

    final trash = (data['trash'] as bool?) ?? false;
    final deleted = (data['deleted'] as bool?) ?? false;
    final ordinal = (data['ordinal'] as int?) ?? null;

    return ChecklistItem(
      id: documentId,
      name: name,
      description: description,
      startDate: startDate,
      trash: trash,
      deleted: deleted,
      ordinal: ordinal,
    );
  }

  static List<ChecklistItem> itemsFromMap(Map<String, dynamic>? data) {
    final List<ChecklistItem> items = [];
    if (data != null) {
      data.forEach((id, dynamic map) {
        items.add(ChecklistItem.fromMap(map, id));
      });
    }
    return items;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'start_day': startDate,
      'trash': trash,
      'deleted': deleted,
      'ordinal': ordinal,
      //'all_days_tracker': tracker.toMap(),
    };
  }

  ChecklistItem copy(Map<String, dynamic> changes, {List<String>? nulls}) {
    final map = toMap();

    changes.forEach((item, dynamic d) {
      if (map[item] != null) {
        map[item] = d;
      } else {
        throw Exception('$item is not found in ChecklistItem');
      }
    });
    nulls ??= [];
    nulls.forEach((item) {
      map[item] = null;
    });
    return ChecklistItem.fromMap(map, id);
  }
}
