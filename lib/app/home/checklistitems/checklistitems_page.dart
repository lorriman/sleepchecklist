import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:equatable/equatable.dart';
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
import 'checklistitems_view_model.dart';

class CheckListItemsPageProviderParameters extends Equatable {
  const CheckListItemsPageProviderParameters(this.day, this.isTrashView);

  final DateTime day;
  final bool isTrashView;

  @override
  List<Object?> get props => [
        day,
        isTrashView,
      ]; // , checked, description];

}

final ChecklistItemListTileModelStreamProvider = StreamProvider.autoDispose
    .family<List<ChecklistItemListTileModel>,
        CheckListItemsPageProviderParameters>(
  (ref, params) {
    try {
      final database = ref.watch(databaseProvider);
      final vm = ChecklistItemsViewModel(database: database);
      return vm.tileModelStream(params.day).map((items) {
        items =
            items.where((item) => item.trash == params.isTrashView).toList();

        ///see [ChecklistItem.ordinal] for why it can be null
        if (items.any((item) => !item.trash && item.ordinal == null)) {
          vm.rewriteSortOrdinals(items);
        }
        items.sort((b, a) =>
            (b.ordinal ?? Int32minValue).compareTo(a.ordinal ?? Int32minValue));
        return items;
      });
    } catch (e) {
      print(e);
    }
    return Stream<List<ChecklistItemListTileModel>>.empty();
  },
);

final isTrashViewProvider = ScopedProvider<bool>((_) => false);

typedef Future<void> RatingEvent(BuildContext context,
    ChecklistItemListTileModel checklistItemListTileModel, double rating);

class ChecklistItemsPagev2 extends StatefulWidget {
  final bool trashView;

  ChecklistItemsPagev2({this.trashView = false}) {
    print('ChecklistItemsPage2 constructor');
  }

  @override
  _ChecklistItemsPagev2State createState() => _ChecklistItemsPagev2State();
}

class _ChecklistItemsPagev2State extends State<ChecklistItemsPagev2> {
  Future<void> _onRating(BuildContext context, ChecklistItemListTileModel model,
      double rating) async {
    try {
      final day = context.read(itemsDateProvider).state;
      await model.setRating(rating, day);
    } catch (e) {
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
      await checklistItemListTileModel.setTrash(trash: !widget.trashView);
    } catch (e) {
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

  @override
  void initState() {
    super.initState();
    //kludge: fetching this data also rewrites any null 'ordinal' items.
    //See [ChecklistItem.ordinal] for why.
    //We could do this more elegantly but it would increase
    //boiler plate significantly for one minor purpose.
    final params = CheckListItemsPageProviderParameters(DateTime.now(), false);
    context.read(ChecklistItemListTileModelStreamProvider(params));
  }

  void debugPopulate() {
    //create some data for dev purposes
    if (FirebaseAuth.instance.currentUser != null) {
      final database = context.read(databaseProvider);
      for (int i = 1; i < 15; i++) {
        database.setChecklistItem(ChecklistItem(
          id: DateTime.now().toString(),
          name: 'Item$i',
          description: 'description$i',
          startDate: DateTime.now(),
          ordinal: i - 1,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Hashcode: ${this.hashCode}');
    return ProviderScope(
      overrides: [
        isTrashViewProvider.overrideWithValue(widget.trashView),
      ],
      child: Consumer(
        key: Key('root_myapp_consumer'),
        builder: (context, watch, _) {
          final DateTime date = watch(itemsDateProvider).state;
          final editItems = watch(editItemsProvider).state;
          watch(newDayProvider).data;

          return Scaffold(
            drawer: Drawer(child: Settings()),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            //FloatingAction is custom due to not working well with CupertinoTabScaffold
            floatingActionButton:
                editItems && !widget.trashView ? FloatingAction() : null,
            appBar: AppBar(
              title: widget.trashView
                  ? Text('Trash - swipe left to restore')
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              context.read(itemsDateProvider).state =
                                  date.dayBefore();
                              _updateSleepDate(context, date.dayBefore());
                            },
                          ),
                        ),
                        ElevatedButton(
                          child: Text(ChecklistItemsViewModel.labelDate(date)),
                          autofocus: true,
                          onLongPress: () {
                            context.read(itemsDateProvider).state =
                                DateTime.now();
                          },
                          onPressed: () {
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
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 15.0,
                            primary: date.isToday() ? null : Colors.redAccent,
                          ),
                        ),
                        Container(
                          width: 40,
                          child: IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                            onPressed: date.isToday()
                                ? null
                                : () {
                                    context.read(itemsDateProvider).state =
                                        date.dayAfter();
                                    _updateSleepDate(context, date.dayAfter());
                                  },
                          ),
                        ),
                      ],
                    ), //Strings.checklistItems),
              actions: <Widget>[
                if (!kReleaseMode && !widget.trashView)
                  IconButton(
                      icon: Icon(Icons.list_alt), onPressed: debugPopulate),
                if (!widget.trashView)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                        key: Key(Keys.testEditToggleButton),
                        child: !editItems
                            ? Icon(Icons.edit)
                            : Icon(Icons.edit_off),
                        onTap: () {
                          context.read(editItemsProvider).state = !editItems;
                        }),
                  ),
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
      ),
    );
  }

  Widget _trashHeader() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(children: [
        Icon(Icons.delete_forever_rounded, size: 40.0),
        Expanded(child: Container()),
        Text('Swipe left to restore items'),
      ]),
    );
  }

  Widget _buildContents(
      BuildContext context, ScopedReader watch, DateTime date) {
    final checklistItemsAsyncValue = watch(
        ChecklistItemListTileModelStreamProvider(
            CheckListItemsPageProviderParameters(date, widget.trashView)));
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
    }, error: (e, _) {
      print(e);
      return Text(e.toString());
    });
    final editItems = watch(editItemsProvider).state;
    return ListItemsBuilderV2<ChecklistItemListTileModel>(
      data: checklistItemsAsyncValue,
      filter: (item) => item.trash == widget.trashView,
      onReorder: (oldIndex, newIndex) {
        checklistItemsAsyncValue.whenData((models) {
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
      },
      itemBuilder: (context, checklistItemListTileModel) => Dismissible(
        key: Key(global_testing_active == TestingEnum.none
            ? 'checklistItem-${checklistItemListTileModel.id}'
            : () {
                final s =
                    'dismissable_checklistItem-${checklistItemListTileModel.ordinal}';
                print('checklist key: $s');
                return s;
              }()),
        background: Container(
            color: widget.trashView ? Colors.green[200] : Colors.red[200],
            alignment: Alignment.centerLeft,
            child: widget.trashView
                ? Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.centerRight,
                    child: Text('restore'))
                : Icon(Icons.delete_forever_rounded)),
        direction: widget.trashView
            ? DismissDirection.endToStart
            : DismissDirection.startToEnd,
        onDismissed: (direction) {
          setState(() {
            models.remove(checklistItemListTileModel);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              content: Text(!widget.trashView
                  ? 'Item in bin, and can be restored'
                  : 'item restored')));

          _onTrash(context, checklistItemListTileModel);
        },
        child: ChecklistItemExpandedTile(
          rating: checklistItemListTileModel.rating ?? 0.0,
          onRating: _onRating,
          checklistItemListTileModel: checklistItemListTileModel,
          onEdit:
              editItems ? () => checklistItemListTileModel.edit(context) : null,
        ),
      ),
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
