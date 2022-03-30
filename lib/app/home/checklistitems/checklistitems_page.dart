import 'dart:async';

import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/app/home/checklistitems/checklistitem_list_tile.dart';
import 'package:insomnia_checklist/app/home/checklistitems/edit_checklistitem_page.dart';
import 'package:insomnia_checklist/app/home/checklistitems/list_items_builder.dart';
import 'package:insomnia_checklist/app/home/models/check_list_item.dart';
import 'package:insomnia_checklist/app/top_level_providers.dart';
import 'package:insomnia_checklist/constants/keys.dart';
import 'package:insomnia_checklist/services/utils.dart';
import 'package:insomnia_checklist/services/globals.dart';
//import 'package:pedantic/pedantic.dart';

import '../settings.dart';
import 'checklistitems_providers.dart';
import 'checklistitems_tile_model.dart';
import 'checklistitems_view_model.dart';

typedef RatingEvent = Future<void> Function(BuildContext context, WidgetRef ref,
    ChecklistItemTileModel checklistItemListTileModel, double rating);

//this is Stateful because of a kludge we are doing in the init method.
//todo: get rid of the kludge. priority: low
class ChecklistItemsPage extends ConsumerStatefulWidget {
  @override
  _ChecklistItemsPageState createState() => _ChecklistItemsPageState();
}

class _ChecklistItemsPageState extends ConsumerState<ChecklistItemsPage> {
  @override
  void initState() {
    super.initState();
    //kludge: fetching this data with checklistItemListTileModelStreamProvider
    // also rewrites any null 'ordinal' items if they exist.
    //See [ChecklistItem.ordinal] for why.
    final params = CheckListItemsPageParametersProvider(DateTime.now());
    ref.read(checklistItemTileModelStreamProvider(params));
  }

  /// inject development data
  void debugPopulate() {
    if (!kReleaseMode) {
      //create some data for dev purposes
      if (FirebaseAuth.instance.currentUser != null) {
        final database = ref.read(databaseProvider);
        for (int i = 1; i < 15; i++) {
          database.setChecklistItem(ChecklistItem(
            id: ChecklistItem.newId(),
            name: 'Item$i',
            description: 'description$i',
            startDate: DateTime.now(),
            ordinal: i - 1,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      key: Key('root_myapp_consumer'),
      builder: (context, watch, _) {
        final DateTime date = ref.watch(itemsDateProvider.state).state;
        final isEditingItems = ref.watch(editItemsProvider.state).state;
        ref.watch(newDayProvider).asData;

        return Scaffold(
          drawer: Drawer(child: Settings()),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          //FloatingAction is custom due to not working well with CupertinoTabScaffold
          floatingActionButton: isEditingItems ? FloatingAction() : null,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _dateBackButton(ref, context, date),
                _dayButton(ref, context, date),
                _dateForwardButton(ref, context, date),
              ],
            ), //Strings.checklistItems),
            actions: [
              if (!kReleaseMode)
                IconButton(
                    icon: Icon(Icons.list_alt), onPressed: debugPopulate),
              _editButton( context, ref, isEditingItems),
            ],
          ),
          body: LayoutBuilder(builder: (_, constraints) {
            return SizedBox(
                //kludge, ReorderableListView doesn't work with the navigation bar
                height: constraints.maxHeight - 50,
                child: _contents( context,ref , date));
          }),
        );
      },
    );
  }

  Widget _contents( BuildContext context, WidgetRef ref, DateTime date) {
    //providers
    final isEditingItems = ref.watch(editItemsProvider.state).state;
    final tileModelsAsyncValue = ref.watch(checklistItemTileModelStreamProvider(
        CheckListItemsPageParametersProvider(date)));
    late List<ChecklistItemTileModel> models;

    tileModelsAsyncValue.when(
      data: (m) => models = m,
      loading: () => basicLoadingIndicator,
      error: (e, st) {
        logger.e('checklistItemsAsyncValue.when', e, st);
        return Text(e.toString());
      },
    );

    return ListItemsBuilder<ChecklistItemTileModel>(
        data: tileModelsAsyncValue,
        //filter: (item) => item.trash == false,
        reorderable: isEditingItems,
        onReorder: (oldI, newI) => _onReorder(ref, oldI, newI, tileModelsAsyncValue),
        itemBuilder: (context, ref, model) {
          final tile = ChecklistItemExpandedTile(
            key: _generateListItemKey(model),
            rating: model.rating ?? 0.0,
            onRating: _onRating,
            checklistItemTileModel: model,
            onEdit: () => model.edit(context),
          );
          if (!isEditingItems) {
            return tile;
          } else {
            return _wrapDismissable(tile, models, model);
          }
        });
  }

  Widget _wrapDismissable(Widget tile, List<ChecklistItemTileModel> models,
      ChecklistItemTileModel model) {
    return Dismissible(
      key: _generateListItemKey(model, pre: 'dismissable_'),
      background: Container(
          color: Colors.red[200],
          alignment: Alignment.centerLeft,
          child: Icon(Icons.delete_forever_rounded)),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => _onDismissWithSnackbar(context, models, model),
      child: tile,
    );
  }

  Key _generateListItemKey(ChecklistItemTileModel model, {String pre = ''}) {
    if (global_testing_active == TestingEnum.none) {
      return Key('${pre}checklistItem-${model.id}');
    } else {
      return Key('${pre}checklistItem-trash${model.ordinal}');
    }
  }

  void _onDismissWithSnackbar(BuildContext context,
      List<ChecklistItemTileModel> models, ChecklistItemTileModel model) {
    _trashItem(context, model);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Item in bin, and can be restored'),
    ));
  }

  void _onReorder(WidgetRef ref, int oldIndex, int newIndex,
      AsyncValue<List<ChecklistItemTileModel>> asyncValue) {
    asyncValue.whenData((models) {
      //setState(() {
        // removing the item at oldIndex will shorten the list by 1.
        int index = newIndex;
        if (oldIndex < newIndex) index -= 1;
        index-=1;
        oldIndex-=1;
        final element = models.removeAt(oldIndex);
        models.insert(index, element);
      //});
      final database = ref.read(databaseProvider);
      final vm = ChecklistItemsViewModel(database: database);
      vm.rewriteSortOrdinals(models);
    });
  }

  void _datePick(WidgetRef ref, BuildContext context, DateTime date) {
    showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 3, 1),
      lastDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      initialDate: date,
    ).then((date) {
      if (date != null) {
        ref.read(itemsDateProvider.state).state = date;
        _updateSleepDate(ref, context, date);
      }
    });
  }

  Future<void> _onRating(
       BuildContext context, WidgetRef ref, ChecklistItemTileModel model, double rating) async {
    try {
      final day = ref.read(itemsDateProvider.state).state;
      await model.setRating(rating, day);
    } catch (e) {
      logger.e('_ChecklistItemsPageState._onRating', e);
      unawaited(showExceptionAlertDialog(
        context: context,
        title: 'Operation failed',
        exception: e,
      ));
    }
  }

  Future<void> _trashItem(BuildContext context,
      ChecklistItemTileModel checklistItemListTileModel) async {
    try {
      await checklistItemListTileModel.setTrash(trash: true);
    } catch (e) {
      logger.e('_ChecklistItemsPageState._trashItem', e);
      unawaited(showExceptionAlertDialog(
        context: context,
        title: 'Operation failed',
        exception: e,
      ));
    }
  }

  Future<void> _updateSleepDate(WidgetRef ref, BuildContext context, DateTime date) async {
    ref.read(sleepDateProvider.state).state = date;
  }

  Widget _dateBackButton(WidgetRef ref, BuildContext context, DateTime date) {
    return Container(
      width: 36,
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          ref.read(itemsDateProvider.state).state = date.dayBefore();
          _updateSleepDate(ref, context, date.dayBefore());
        },
      ),
    );
  }

  Widget _dayButton(WidgetRef ref, BuildContext context, DateTime date) {
    return ElevatedButton(
      child: Text(ChecklistItemsViewModel.labelDate(date)),
      autofocus: true,
      onLongPress: () {
        ref.read(itemsDateProvider.state).state = DateTime.now();
      },
      onPressed: () => _datePick(ref, context, date),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 15.0,
        primary: date.isToday() ? null : Colors.redAccent,
      ),
    );
  }

  Widget _dateForwardButton(WidgetRef ref, BuildContext context, DateTime date) {
    return Container(
      width: 40,
      child: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: date.isToday()
            ? null
            : () {
                ref.read(itemsDateProvider.state).state = date.dayAfter();
                _updateSleepDate(ref, context, date.dayAfter());
              },
      ),
    );
  }

  Widget _editButton( BuildContext context, WidgetRef ref, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
          key: Key(Keys.testEditToggleButton),
          child: !isEditing ? Icon(Icons.edit) : Icon(Icons.edit_off),
          onTap: () {
            ref.read(editItemsProvider.state).state = !isEditing;
          }),
    );
  }
}

class FloatingAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      //try setting crossAxis to show the layout via an exception
      //crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 70),
          child: FloatingActionButton(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            // mini: true,
            //backgroundColor: Colors.white,
            child: Icon(Icons.add, key: Key(Keys.newChecklistItemButton)),
            onPressed: () => EditChecklistItemPage.show(context),
          ),
        ),
      ],
    );
  }
}
