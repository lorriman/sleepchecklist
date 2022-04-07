// ignore : prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/app/home/models/check_list_item.dart';
import 'package:insomnia_checklist/app/home/checklistitems/checklistitems_page.dart';

import '../../top_level_providers.dart';
import 'checklistitems_tile_model.dart';

class ChecklistItemExpandedTile extends ConsumerWidget {
  const ChecklistItemExpandedTile({
    Key? key,
    required this.checklistItemTileModel,
    required this.rating,
    this.onEdit,
    this.onRating,
  }) : super(key: key);

  final ChecklistItemTileModel checklistItemTileModel;
  final double rating;
  final VoidCallback? onEdit;
  final RatingEvent? onRating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider.state).state;
    final isEditingItems = ref.watch(editItemsProvider.state).state;
    const borderRadius = 40.0;

    return Card(
      margin: EdgeInsets.all(5.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      shadowColor: Colors.grey,
      elevation: 10,
      //Material is needed to support Inkwell effects
      child: Material(
        child: ExpansionTile(
          childrenPadding: EdgeInsets.all(10),
          leading: isEditingItems ? _thumb() : null,
          title: Row(
            children: [
              if (!isEditingItems) ...[
                Container(width: 10), //spacer
                RatingBar.builder(
                  initialRating: rating,
                  glowRadius: 20,
                  itemBuilder: isDarkMode
                      //RatingsBar doesn't directly support different icons for
                      // selected/unselected, so we need to customise it
                      ? _darkModeRatingsBar
                      : (context, index) =>
                          Icon(Icons.star, color: Colors.black),
                  itemCount: 5,
                  itemSize: 30.0,
                  direction: Axis.horizontal,
                  onRatingUpdate: (rating) =>
                      onRating!(context, ref, checklistItemTileModel, rating),
                )
              ],
              Container(width: 5),
              Expanded(child: Text(checklistItemTileModel.titleText)),
              if (isEditingItems)
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child:
                      InkWell(child: Icon(Icons.edit_outlined), onTap: onEdit),
                ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Expanded(
                  child: Text(checklistItemTileModel.bodyText),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _darkModeRatingsBar(BuildContext context, int index) {
    if (rating > index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.secondary.withAlpha(30),
              blurRadius: 5,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Theme.of(context).colorScheme.secondary.withAlpha(30),
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

  Widget _thumb() {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 0), child: FingerSwipeIcon());
  }

  //legacy code for a different way of doing ratings.
  // ignore: unused_element
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
}

class FingerSwipeIcon extends StatelessWidget {
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
