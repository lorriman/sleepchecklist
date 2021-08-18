// ignore : prefer_const_constructors

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/app/home/models/check_list_item.dart';
import 'package:insomnia_checklist/app/home/checklistitems/checklistitems_page.dart';
import 'package:insomnia_checklist/services/repository.dart';

import '../../top_level_providers.dart';
import 'edit_checklistitem_page.dart';

class ChecklistItemListTileModel extends Equatable {
  //we use equatable for unit tests
  const ChecklistItemListTileModel({
    ChecklistItem? checklistItem, //if being used readonly, we don't need this
    Repository? database, //equally here.
    required this.id,
    required this.leadingText,
    this.trailingText,
    required this.bodyText,
    this.middleText,
    this.isHeader = false,
    required this.rating,
    required this.trash,
    this.ordinal,
  })  : _checklistItem = checklistItem,
        _database = database;

  final String leadingText;
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
        leadingText,
        trailingText,
        middleText,
        bodyText,
        rating,
        trash,
      ]; // , checked, descri

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
      await _database!.setChecklistItem(newItem);
    } else {
      throw Exception(
          "can't setTrash: required database or checklistItem not set");
    }
  }

  void edit(BuildContext context) {
    //if(_checklistItem!=null) {
    EditChecklistItemPage.show(context, checklistItem: _checklistItem);
    //}
  }
}

class ChecklistItemExpandedTile extends ConsumerWidget {
  const ChecklistItemExpandedTile({
    Key? key,
    required this.checklistItemListTileModel,
    required this.rating,
    this.onEdit,
    this.onRating,
  }) : super(key: key);

  final ChecklistItemListTileModel checklistItemListTileModel;
  final double rating;
  final VoidCallback? onEdit;
  final RatingEvent? onRating;

  Widget _thumb() {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 0), child: Thumb());
  }

  Widget _mealIconButton(MealTime mealTime,
      {required VoidCallback? onPressed}) {
    return Container(
      padding: EdgeInsets.all(0),
      width: 30,
      child: IconButton(
          //splashColor: Colors.blueGrey,
          icon: Icon(mealTimeIcons[mealTime], color: Colors.blueGrey),
          onPressed: onPressed),
    );
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final trashView = watch(isTrashViewProvider);
    final darkMode = watch(darkModeProvider).state;
    final editItems = watch(editItemsProvider).state;
    const borderRadius = 40.0;
    return Container(
      margin: EdgeInsets.all(10.0),
      //padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        //color:  Colors.white,
        borderRadius: BorderRadius.circular(borderRadius / (trashView ? 8 : 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            offset: Offset(4, 4), // Shadow position
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
            Radius.circular(borderRadius / (trashView ? 8 : 1))),
        //Material needed to support Inkwell effects
        child: Material(
          child: ExpansionTile(
            //collapsedBackgroundColor: !trashView ? null : Colors.grey,
            //tilePadding: EdgeInsets.all(0),
            childrenPadding: EdgeInsets.all(10),
//leading :ReorderableDragStartListener(
//         index: index,
//         child: const Icon(Icons.drag_handle),
//       ),
            leading: trashView | !editItems ? null : _thumb(),
            trailing: trashView
                ? Container(child: _thumb(), width: 40)
                : Container(width: 0),
            //key: checklistItem.id,
            title: Row(
              children: [
                if (!editItems) Container(width: 10),
                if (!trashView && onEdit == null)
                  RatingBar.builder(
                    initialRating: rating,
                    //glow: darkMode,
                    //glowColor: Colors.amberAccent,
                    glowRadius: 20,
                    itemBuilder: darkMode
                        //RatingsBar doesn't directly support different icons for
                        // selected/unselected, hence the following code
                        ? (context, index) {
                            if (rating > index) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .accentColor
                                          .withAlpha(30),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .accentColor
                                          .withAlpha(30),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.star,
                                  color: Colors.black,
                                ),
                              );
                            } else {
                              return Icon(
                                Icons.star_border,
                                color: Colors.black,
                              );
                            }
                          }
                        : (context, index) => Icon(
                              //not dark mode
                              Icons.star,
                              color: Colors.black,
                            ),
                    itemCount: 5,
                    itemSize: 30.0,
                    direction: Axis.horizontal,
                    onRatingUpdate: (rating) {
                      if (onRating != null) {
                        onRating!(context, checklistItemListTileModel, rating);
                      }
                    },
                  ),
                Container(width: 5),
                Expanded(child: Text(checklistItemListTileModel.leadingText)),
                if (onEdit != null && !trashView)
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: InkWell(
                        child: Icon(Icons.edit_outlined), onTap: onEdit),
                  ),
              ],
            ),

            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Expanded(
                    child: Text(checklistItemListTileModel.bodyText),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Thumb extends StatelessWidget {
  @override
  Widget build(context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 2, 8),
            child: Container(
              width: 4,
              padding: EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).indicatorColor)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 8, 2, 8),
            child: Container(
              width: 4,
              padding: EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).indicatorColor)),
            ),
          )
        ]);
  }
}
