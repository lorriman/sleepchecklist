import 'dart:async';

import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/app/home/checklistitems/checklistitem_list_tile.dart';
import 'package:insomnia_checklist/app/home/checklistitems/list_items_builder.dart';
import 'package:insomnia_checklist/services/globals.dart';
import 'package:insomnia_checklist/services/utils.dart';
//import 'package:pedantic/pedantic.dart';

import '../settings.dart';
import 'checklistitems_providers.dart';
import 'checklistitems_tile_model.dart';
import 'empty_content.dart';

class ChecklistItemsPageTrash extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      key: Key('root_myapp_consumer'),
      builder: (context, watch, _) {
        return Scaffold(
          drawer: Drawer(child: Settings()),
          appBar: AppBar(
            title: Text('Trash - swipe left to restore'),
          ),
          body: _contents(context, watch),
        );
      },
    );
  }

  Widget _contents(BuildContext context, WidgetRef ref) {
    final checklistItemsAsyncValue =
        ref.watch(checklistTrashItemListTileModelStreamProvider);
    late List<ChecklistItemTileModel> models;
    checklistItemsAsyncValue.when(
      data: (m) => models = m,
      loading: () => basicLoadingIndicator,
      error: (e, st) {
        logger.e('checklistItemsAsyncValue.when', e, st);
        return Text(e.toString());
      },
    );
    return ListItemsBuilder<ChecklistItemTileModel>(
      data: checklistItemsAsyncValue,
      filter: (item) => item.trash,
      emptyContent: EmptyContent(message: ''),
      itemBuilder: (context, ref, checklistItemListTileModel) => Dismissible(
        key: _generateListItemKey(checklistItemListTileModel),
        background: Container(
            color: Colors.green[200],
            alignment: Alignment.centerLeft,
            child: Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.centerRight,
                child: Text('restore'))),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) =>
            _onDismissWithSnackbar(context, models, checklistItemListTileModel),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            tileColor: Colors.blueGrey[400],
            dense: true,
            contentPadding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
            title: Text(
              checklistItemListTileModel.titleText,
              textScaleFactor: 1.2,
            ),
            trailing: FingerSwipeIcon(),
          ),
        ),
      ),
    );
  }

  Future<void> _unTrashItem(BuildContext context,
      ChecklistItemTileModel checklistItemListTileModel) async {
    try {
      await checklistItemListTileModel.setTrash(trash: false);
    } catch (e) {
      logger.e('_ChecklistItemsPagev2State._onTrash', e);
      unawaited(showExceptionAlertDialog(
        context: context,
        title: 'Operation failed',
        exception: e,
      ));
    }
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

  Key _generateListItemKey(ChecklistItemTileModel model) {
    if (global_testing_active == TestingEnum.none) {
      return Key('trash_checklistItem-${model.id}');
    } else {
      return Key('trash_dismissable_checklistItem-trash${model.ordinal}');
    }
  }

  void _onDismissWithSnackbar(BuildContext context,
      List<ChecklistItemTileModel> models, ChecklistItemTileModel model) {
    //setState(() {
    // models.remove(model);
    _unTrashItem(context, model);
    // });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1), content: Text('item restored')));
  }
}
