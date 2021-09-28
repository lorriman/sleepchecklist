import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:insomnia_checklist/app/home/models/check_list_item.dart';
import 'package:insomnia_checklist/services/repository.dart';

import 'edit_checklistitem_page.dart';

class ChecklistItemTileModel extends Equatable {
  //we use equatable for unit tests
  const ChecklistItemTileModel({
    ChecklistItem? checklistItem, //if being used readonly, we don't need this
    Repository? database, //equally here.
    required this.id,
    required this.titleText,
    required this.bodyText,
    required this.rating,
    required this.trash,
    this.trailingText,
    this.middleText,
    this.isHeader = false,
    this.ordinal,
  })  : _checklistItem = checklistItem,
        _database = database;

  final String titleText;
  final String id;
  final String? trailingText;
  final String? middleText;
  final String bodyText;
  final bool isHeader;
  final double? rating;
  final bool trash;
  final int? ordinal;
  final ChecklistItem? _checklistItem;
  final Repository? _database;

  @override
  List<Object?> get props => [
        id,
        titleText,
        trailingText,
        middleText,
        bodyText,
        rating,
        trash,
      ];

  Future<void> setRating(double rating, DateTime day) async {
    if (_database != null && _checklistItem != null) {
      await _database!.setRating(rating, _checklistItem!, day);
    } else {
      throw Exception(
          "can't setRating: required database or checklistItem not set");
    }
  }

  Future<void> setTrash({required bool trash}) async {
    if (_database != null && _checklistItem != null) {
      final newItem =
          _checklistItem!.copy({'trash': trash}, nulls: ['ordinal']);
      if (trash) {
        await _database!.setChecklistItemTrash(newItem);
      } else {
        await _database!.setChecklistItemUnTrash(newItem);
      }
    } else {
      throw Exception(
          "can't setTrash: required database or checklistItem not set");
    }
  }

  void edit(BuildContext context) {
    EditChecklistItemPage.show(context, checklistItem: _checklistItem);
  }
}
