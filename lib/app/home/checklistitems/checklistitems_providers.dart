import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/services/globals.dart';
import 'package:insomnia_checklist/services/utils.dart';

import '../../top_level_providers.dart';
import 'checklistitem_list_tile.dart';
import 'checklistitems_view_model.dart';

final isTrashViewProvider = ScopedProvider<bool>((_) => false);

class CheckListItemsPageProviderParameters extends Equatable {
  const CheckListItemsPageProviderParameters(this.day,
      {required this.trashView});

  final DateTime day;
  final bool trashView;

  @override
  List<Object?> get props => [
        day,
        trashView,
      ]; // , checked, description];

}

final checklistItemListTileModelStreamProvider = StreamProvider.autoDispose
    .family<List<ChecklistItemListTileModel>,
        CheckListItemsPageProviderParameters>(
  (ref, params) {
    try {
      final database = ref.watch(databaseProvider);
      final vm = ChecklistItemsViewModel(database: database);
      return vm.tileModelStream(params.day).map((items) {
        items = items.where((item) => item.trash == params.trashView).toList();

        ///see [ChecklistItem.ordinal] for why it can be null
        if (items.any((item) => !item.trash && item.ordinal == null)) {
          vm.rewriteSortOrdinals(items);
        }
        items.sort((b, a) =>
            (b.ordinal ?? int32minValue).compareTo(a.ordinal ?? int32minValue));
        return items;
      });
    } catch (e) {
      logger.e('ChecklistItemListTileModelStreamProvider', e);
    }
    return Stream<List<ChecklistItemListTileModel>>.empty();
  },
);
