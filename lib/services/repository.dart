import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insomnia_checklist/app/home/models/check_list_item.dart';
import 'package:insomnia_checklist/app/home/models/sleep.dart';
import 'package:insomnia_checklist/services/firestore_path.dart';
import 'package:insomnia_checklist/app/home/models/rating.dart';
import 'firestoreservice.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class Repository {
  Repository({
    required this.uid,
    FirestoreService? testFirestoreServiceInstance,
  }) {
    if (testFirestoreServiceInstance == null) {
      _service = FirestoreService.instance;
    } else {
      _service = testFirestoreServiceInstance;
    }
  }

  final String uid;

  late ADatabaseService _service;

  Future<void> setChecklistItemsSortOrdinals(
      Map<String, int> sortOrdinalsMap) async {
    final Map<String, dynamic> saveOrdinalsMap = {};
    sortOrdinalsMap.forEach((checklistItemId, ordinal) {
      saveOrdinalsMap[checklistItemId] = {'ordinal': ordinal};
    });
    await _service.setData(
      path: FirestorePath.checklistItem(uid),
      data: saveOrdinalsMap,
      merge: true,
    );
  }

  //month can be any DateTime within the month
  Stream<Map<DateTime, SleepRating>?> sleepRatingsIndexedByDateStream(
      {required DateTime month}) {
    return _service.documentStream(
      path: FirestorePath.sleepRatingsOnDate(uid, month),
      builder: (data, documentId) =>
          SleepRating.ratingsMapFromMapIndexedByDateOnMonth(
              data: data, month: month),
    );
  }

  Future<void> setSleepRating(SleepRating sleepRating) {
    if (sleepRating.value < 1) {
      return _service.setData(
        path: FirestorePath.sleepRatingsOnDate(uid, sleepRating.date),
        data: {SleepRating.dateToString(sleepRating.date): FieldValue.delete()},
        merge: true,
      );
    } else {
      return _service.setData(
        path: FirestorePath.sleepRatingsOnDate(uid, sleepRating.date),
        data: {SleepRating.dateToString(sleepRating.date): sleepRating.value},
        merge: true,
      );
    }
  }

  Stream<Map<String, Rating>?> ratingsIndexedByChecklistItemIdStream(
      {required DateTime day}) {
    return _service.documentStream(
      path: FirestorePath.ratingsOnDate(uid, day),
      builder: (data, documentId) =>
          Rating.ratingsMapFromMapIndexedByChecklistItemId(data,
              suppliedMonth: day),
    );
  }

  Stream<List<ChecklistItem>> checklistItemsStream() {
    return _service.documentStream(
      path: FirestorePath.checklistItems(uid),
      builder: (data, documentId) => ChecklistItem.itemsFromMap(data),
    );
  }

  Future<void> setChecklistItem(ChecklistItem checklistItem) {
    return _service.setData(
      path: FirestorePath.checklistItem(uid),
      data: {checklistItem.id: checklistItem.toMap()},
      merge: true,
    );
  }

  Future<List<void>> setRating(
      double rating, ChecklistItem checklistItem, DateTime date) async {
    if (rating < 1) {
      final a = _service.setData(
        path: FirestorePath.ratingsOnDate(uid, date),
        data: {checklistItem.id: FieldValue.delete()},
        merge: true,
      );
      final b = _service.setData(
        path: FirestorePath.ratingsForChecklistItem(uid, checklistItem.id),
        data: {Rating.dateToString(date): FieldValue.delete()},
        merge: true,
      );
      return Future.wait([a, b]);
    } else {
      final a = _service.setData(
        path: FirestorePath.ratingsOnDate(uid, date),
        data: {checklistItem.id: rating},
        merge: true,
      );
      final b = _service.setData(
        path: FirestorePath.ratingsForChecklistItem(uid, checklistItem.id),
        data: {Rating.dateToString(date): rating},
        merge: true,
      );
      return Future.wait([a, b]);
    }
  }
}
