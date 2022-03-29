// gnore : prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/app/home/models/sleep.dart';
import 'package:insomnia_checklist/app/top_level_providers.dart';

import 'package:insomnia_checklist/services/utils.dart';

typedef OnSleepRating = Future<void> Function(
    BuildContext context, WidgetRef ref, SleepRating sleepRating);

class SleepRatingExpandedTile extends ConsumerWidget {
  const SleepRatingExpandedTile({
    Key? key,
    required this.sleepRating,
    this.onRating,
  }) : super(key: key);
  final SleepRating sleepRating;

  final OnSleepRating? onRating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sleepDateProvider.state).state;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Material(
        //Material needed here for the IconButton splash to manifest correctly
        child: ListTile(
          //key: checklistItem.id,
          title: Row(
            children: [
              Container(
                  child: Text(SleepRating.labelAsDayOfWeek(sleepRating.date),
                      textScaleFactor: 0.9,
                      style: (sleepRating.date.isYesterday() ||
                              sleepRating.date.isDayBeforeYesterday())
                          ? Theme.of(context).textTheme.headline5
                          : Theme.of(context)
                              .textTheme
                              .headline6!
                              .apply(color: Colors.grey[600])),
                  width: 140),
              RatingBar.builder(
                initialRating: sleepRating.value,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amberAccent,
                ),
                itemCount: 5,
                itemSize: 35.0,
                direction: Axis.horizontal,
                onRatingUpdate: (rating) {
                  if (onRating != null) {
                    final SleepRating newSleepRating =
                        sleepRating.copy(newValue: rating);
                    onRating!(context, ref, newSleepRating);
                    ref.read(itemsDateProvider.state).state = sleepRating.date;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
