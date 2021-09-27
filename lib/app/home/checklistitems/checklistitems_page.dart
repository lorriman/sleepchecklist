import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:pedantic/pedantic.dart';

import '../settings.dart';
import 'checklistitems_providers.dart';
import 'checklistitems_view_model.dart';

typedef RatingEvent = Future<void> Function(BuildContext context,
    ChecklistItemListTileModel checklistItemListTileModel, double rating);

class ChecklistItemsPage extends StatefulWidget {
  @override
  _ChecklistItemsPageState createState() => _ChecklistItemsPageState();
}

class _ChecklistItemsPageState extends State<ChecklistItemsPage> {
  @override
  void initState() {
    super.initState();
    //kludge: fetching this data with checklistItemListTileModelStreamProvider
    // also rewrites any null 'ordinal' items.
    //See [ChecklistItem.ordinal] for why.
    //We could do this more elegantly but it would increase
    //boiler plate significantly for one minor purpose.
    final params =
        CheckListItemsPageProviderParameters(DateTime.now(), trashView: false);
    context.read(checklistItemListTileModelStreamProvider(params));
  }

  /// development data
  void debugPopulate() {
    if (!kReleaseMode) {
      //create some data for dev purposes
      if (FirebaseAuth.instance.currentUser != null) {
        final database = context.read(databaseProvider);
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
        final DateTime date = watch(itemsDateProvider).state;
        final editItems = watch(editItemsProvider).state;
        watch(newDayProvider).data;

        return Scaffold(
          drawer: Drawer(child: Settings()),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          //FloatingAction is custom due to not working well with CupertinoTabScaffold
          floatingActionButton: editItems ? FloatingAction() : null,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _dateBackButton(context, date),
                _dayButton(context, date),
                _dateForwardButton(context, date),
              ],
            ), //Strings.checklistItems),
            actions: <Widget>[
              if (!kReleaseMode)
                IconButton(
                    icon: Icon(Icons.list_alt), onPressed: debugPopulate),
              _editButton(context, editItems),
            ],
          ),
          body: LayoutBuilder(builder: (_, constraints) {
            return SizedBox(
                //kludge, ReorderableListView doesn't work with the navigation bar
                height: constraints.maxHeight - 50,
                child: _buildContents(context, watch, date));
          }),
        );
      },
    );
  }

  Widget _buildContents(
      BuildContext context, ScopedReader watch, DateTime date) {
    final editItems = watch(editItemsProvider).state;
    final checklistItemsAsyncValue = watch(
        checklistItemListTileModelStreamProvider(
            CheckListItemsPageProviderParameters(date, trashView: false)));
    late List<ChecklistItemListTileModel> models;

    checklistItemsAsyncValue.when(data: (m) {
      models = m;
    }, loading: () {
      return Center(
        child: Container(
          height: 100,
          width: 100,
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }, error: (e, st) {
      logger.e('checklistItemsAsyncValue.when', e, st);
      return Text(e.toString());
    });

    return ListItemsBuilderV2<ChecklistItemListTileModel>(
        data: checklistItemsAsyncValue,
        //filter: (item) => item.trash == false,
        reorderable: editItems,
        onReorder: (oldI, newI) =>
            _onReorder(oldI, newI, checklistItemsAsyncValue),
        itemBuilder: (context, checklistItemListTileModel) {
          final tile = ChecklistItemExpandedTile(
            key: _generateListItemKey(checklistItemListTileModel),
            rating: checklistItemListTileModel.rating ?? 0.0,
            onRating: _onRating,
            checklistItemListTileModel: checklistItemListTileModel,
            onEdit: editItems
                ? () => checklistItemListTileModel.edit(context)
                : null,
          );
          if (!editItems) {
            return tile;
          } else {
            return Dismissible(
              key: _generateListItemKey(checklistItemListTileModel,
                  pre: 'dismissable_'),
              background: Container(
                  color: Colors.red[200],
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.delete_forever_rounded)),
              direction: DismissDirection.startToEnd,
              onDismissed: (_) =>
                  _onDismissWithSnackbar(models, checklistItemListTileModel),
              child: tile,
            );
          }
        });
  }

  Key _generateListItemKey(ChecklistItemListTileModel model,
      {String pre = ''}) {
    if (global_testing_active == TestingEnum.none) {
      return Key('${pre}checklistItem-${model.id}');
    } else {
      return Key('${pre}checklistItem-trash${model.ordinal}');
    }
  }

  void _onDismissWithSnackbar(List<ChecklistItemListTileModel> models,
      ChecklistItemListTileModel model) {
    {
      setState(() {
        models.remove(model);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Item in bin, and can be restored'),
      ));

      _onTrash(context, model);
    }
    ;
  }

  void _onReorder(int oldIndex, int newIndex,
      AsyncValue<List<ChecklistItemListTileModel>> asyncValue) {
    asyncValue.whenData((models) {
      setState(() {
        // removing the item at oldIndex will shorten the list by 1.
        if (oldIndex < newIndex) newIndex -= 1;
        final element = models.removeAt(oldIndex);
        models.insert(newIndex, element);
      });
      final database = context.read(databaseProvider);
      final vm = ChecklistItemsViewModel(database: database);
      vm.rewriteSortOrdinals(models);
    });
  }

  void _datePick(BuildContext context, DateTime date) {
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
        context.read(itemsDateProvider).state = date;
        _updateSleepDate(context, date);
      }
    });
  }

  Future<void> _onRating(BuildContext context, ChecklistItemListTileModel model,
      double rating) async {
    try {
      final day = context.read(itemsDateProvider).state;
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

  Future<void> _onTrash(BuildContext context,
      ChecklistItemListTileModel checklistItemListTileModel) async {
    try {
      await checklistItemListTileModel.setTrash(trash: true);
    } catch (e) {
      logger.e('_ChecklistItemsPageState._onTrash', e);
      unawaited(showExceptionAlertDialog(
        context: context,
        title: 'Operation failed',
        exception: e,
      ));
    }
  }

  Future<void> _updateSleepDate(BuildContext context, DateTime date) async {
    context.read(sleepDateProvider).state = date;
  }

  Widget _dateBackButton(BuildContext context, DateTime date) {
    return Container(
      width: 36,
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          context.read(itemsDateProvider).state = date.dayBefore();
          _updateSleepDate(context, date.dayBefore());
        },
      ),
    );
  }

  Widget _dayButton(BuildContext context, DateTime date) {
    return ElevatedButton(
      child: Text(ChecklistItemsViewModel.labelDate(date)),
      autofocus: true,
      onLongPress: () {
        context.read(itemsDateProvider).state = DateTime.now();
      },
      onPressed: () => _datePick(context, date),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 15.0,
        primary: date.isToday() ? null : Colors.redAccent,
      ),
    );
  }

  Widget _dateForwardButton(BuildContext context, DateTime date) {
    return Container(
      width: 40,
      child: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: date.isToday()
            ? null
            : () {
                context.read(itemsDateProvider).state = date.dayAfter();
                _updateSleepDate(context, date.dayAfter());
              },
      ),
    );
  }

  Widget _editButton(BuildContext context, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
          key: Key(Keys.testEditToggleButton),
          child: !isEditing ? Icon(Icons.edit) : Icon(Icons.edit_off),
          onTap: () {
            context.read(editItemsProvider).state = !isEditing;
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
