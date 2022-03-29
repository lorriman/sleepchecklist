import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/services/globals.dart';
import 'package:insomnia_checklist/services/utils.dart';

import '../../top_level_providers.dart';
import 'checklistitems_tile_model.dart';
import 'checklistitems_view_model.dart';

//final isTrashViewProvider = ScopedProvider<bool>((_) => false);

class CheckListItemsPageParametersProvider extends Equatable {
  const CheckListItemsPageParametersProvider(this.day);

  final DateTime day;

  @override
  List<Object?> get props => [
        day,
      ]; // , checked, description];

}

final checklistItemTileModelStreamProvider = StreamProvider.autoDispose
    .family<List<ChecklistItemTileModel>, CheckListItemsPageParametersProvider>(
  (ref, params) {
    try {
      final database = ref.watch(databaseProvider);
      final vm = ChecklistItemsViewModel(database: database);
      return vm.tileModelStream(params.day).map((items) {
        //we're not filtering (hence true) so this is a placeholder
        //for future filtering
        items = items.where((item) => true).toList();

        ///see [ChecklistItem.ordinal] for why it can be null
        if (items.any((item) => item.ordinal == null)) {
          vm.rewriteSortOrdinals(items);
        }
        items.sort((b, a) =>
            (b.ordinal ?? int32minValue).compareTo(a.ordinal ?? int32minValue));
        return items;
      });
    } catch (e) {
      logger.e('ChecklistItemListTileModelStreamProvider', e);
    }
    return Stream<List<ChecklistItemTileModel>>.empty();
  },
);

final checklistTrashItemListTileModelStreamProvider =
    StreamProvider.autoDispose<List<ChecklistItemTileModel>>(
  (ref) {
    try {
      final database = ref.watch(databaseProvider);
      final vm = ChecklistItemsViewModel(database: database);
      return vm.trashTileModelStream().map((items) {
        items.sort((b, a) => (b.titleText).compareTo(a.titleText));
        return items;
      });
    } catch (e) {
      logger.e('checklistTrashItemListTileModelStreamProvider', e);
    }
    return Stream<List<ChecklistItemTileModel>>.empty();
  },
);
