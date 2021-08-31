import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/app/home/checklistitems/list_items_builder.dart';
import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:insomnia_checklist/app/home/models/sleep.dart';
import 'package:insomnia_checklist/app/home/sleep/sleep_rating_list_tile.dart';
import 'package:insomnia_checklist/app/top_level_providers.dart';
import 'package:insomnia_checklist/services/globals.dart';
import 'package:intl/intl.dart';
import 'package:pedantic/pedantic.dart';
import 'package:insomnia_checklist/services/repository.dart';
import 'package:insomnia_checklist/services/utils.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../settings.dart';

class SleepRatingsViewModel {
  //todo: make a proper model
  SleepRatingsViewModel({required this.database});

  final Repository database;

  // Since days are only saved if they have non-zero rating
  // this transforms the list of day items for a month adding extra days
  // missing from the database.
  // In descending order which avoids a sort since Map is
  // ordered by insertion order.
  Stream<Map<DateTime, SleepRating>> allDaysStream({required DateTime month}) {
    return database.sleepRatingsIndexedByDateStream(month: month).map((map) {
      map ??= {};

      final Map<DateTime, SleepRating> newMap = {};
      for (int d = SleepRating.daysInMonth(month); d > 0; d--) {
        final DateTime day = DateTime(month.year, month.month, d);
        if (!day.isAfter(DateTime.now().subtract(Duration(days: 1)))) {
          if (map[day] != null) {
            newMap[day] = map[day] as SleepRating;
          } else {
            newMap[day] = SleepRating(date: day, value: 0.0);
          }
        }
      }

      return newMap;
    });
  }
}

final sleepRatingsForMonthStreamProvider =
    StreamProvider.autoDispose.family<Map<DateTime, SleepRating>?, DateTime>(
  (ref, date) {
    final database = ref.watch(databaseProvider);
    final vm = SleepRatingsViewModel(database: database);

    return vm.allDaysStream(month: date);
  },
);

typedef OnSleepRating = Future<void> Function(
    BuildContext context, DateTime date, double rating);

class SleepPage extends ConsumerWidget {
  //dead variable used in legacy code below

  const SleepPage();

  Future<void> _onRating(BuildContext context, SleepRating sleepRating) async {
    try {
      final database = context.read<Repository>(databaseProvider);

      await database.setSleepRating(sleepRating);
    } catch (e) {
      logger.e('SleepPage._onRating', e);
      unawaited(showExceptionAlertDialog(
        context: context,
        title: 'Operation failed',
        exception: e,
      ));
    }
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final date = watch(sleepDateProvider).state;
    return Scaffold(
      drawer: Drawer(child: Settings()),
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Sleep  '),
            ElevatedButton(
              child: Text(DateFormat.yMMMM().format(date)),
              onLongPress: () {
                context.read(sleepDateProvider).state =
                    DateTime.now().dayBefore();
              },
              onPressed: () {
                showMonthPicker(
                  context: context,
                  firstDate: DateTime(DateTime.now().year - 3, 1),
                  lastDate: DateTime(DateTime.now().year, DateTime.now().month),
                  initialDate: context.read(sleepDateProvider).state,
                ).then((date) {
                  if (date != null) {
                    context.read(sleepDateProvider).state = date;
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 15.0,
                primary: date.isSameMonth(DateTime.now().dayBefore())
                    ? null
                    : Theme.of(context).errorColor,
              ),
            )
          ],
        ),
        //Strings.checklistItems),
      ),
      body: Column(
          children: [Flexible(child: _buildContents(context, watch, date))]),
    );
  }

  Widget _buildContents(
      BuildContext context, ScopedReader watch, DateTime date) {
    final sleepRatingsAsyncValue =
        watch(sleepRatingsForMonthStreamProvider(date));
    if (sleepRatingsAsyncValue.data?.value?.isEmpty ?? false) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No available dates yet in ${DateFormat('MMMM').format(date)} to record your sleep',
          textScaleFactor: 2,
        ),
      );
    }
    return ListItemsBuilderV1<SleepRating>(
        data: sleepRatingsAsyncValue,
        itemBuilder: (context, sleepRating) => Container(
              key: Key('sleepRating-${sleepRating.date.toString}'),
              child: Container(
                alignment: Alignment.centerLeft,
                child: SleepRatingExpandedTile(
                  onRating: _onRating,
                  sleepRating: sleepRating,
                ),
              ),
            ));
  }
}
