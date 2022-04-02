import 'package:insomnia_checklist/app/home/models/rating.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:insomnia_checklist/app/home/checklistitems/rating_checklistitem.dart';
import 'package:insomnia_checklist/app/home/models/check_list_item.dart';
import 'package:insomnia_checklist/services/repository.dart';
import 'package:insomnia_checklist/services/utils.dart';
import 'checklistitems_tile_model.dart';

class ChecklistItemsViewModel {
  ChecklistItemsViewModel({required this.database});

  final Repository database;

  static String labelDate(DateTime date) {
    if (date.isToday()) return 'Today';
    if (date.isYesterday()) return 'Yesterday';
    return DateFormat.yMMMEd().format(date);
  }

  Future<void> rewriteSortOrdinals(List<ChecklistItemTileModel> items) async {
    final Map<String, int> newSortOrdinalsMap = {};
    int i = 0;
    //put null ordinals to the top of the list (ie, which were un-trashed or new)
    items.where((item) => !item.trash && item.ordinal == null).forEach((item) {
      newSortOrdinalsMap[item.id] = i++;
    });
    //then do the rest
    items.where((item) => !item.trash && item.ordinal != null).forEach((item) {
      newSortOrdinalsMap[item.id] = i++;
    });
    await database.setChecklistItemsSortOrdinals(newSortOrdinalsMap);
  }

  Stream<List<RatingChecklistItem>> _checklistitemsRatingitemsStream(
      DateTime day) {
    return CombineLatestStream.combine2(
      database.ratingsIndexedByChecklistItemIdStream(day: day),
      database.checklistItemsStream(), // as Stream<List<ChecklistItem>>,
      _ratingsChecklistItemsCombiner,
    );
  }

  Stream<List<RatingChecklistItem>> _checklistitemsTrashItemsStream() {
    //reusing some of the infrastructure of the main Checklist tab, so we need
    //an empty stream since we're not reading any ratings for the trash tab.

    return CombineLatestStream.combine2(
      Stream<Map<String, Rating>>.value({}),
      database.checklistItemsTrashStream(),
      _ratingsChecklistItemsCombiner,
    );
  }

  static List<RatingChecklistItem> _ratingsChecklistItemsCombiner(
      Map<String, Rating>? ratings, List<ChecklistItem> checklistItems) {
    final List<RatingChecklistItem> combo = [];
    for (final checklistItem in checklistItems) {
      final Rating? rating = ratings?[checklistItem.id];
      combo.add(RatingChecklistItem(rating, checklistItem));
    }
    return combo;
  }

  /// Output stream
  Stream<List<ChecklistItemTileModel>> tileModelStream(DateTime day) =>
      _checklistitemsRatingitemsStream(day).map(_createModels);

  /// Output stream
  Stream<List<ChecklistItemTileModel>> trashTileModelStream() =>
      _checklistitemsTrashItemsStream().map(_createModels);

  List<ChecklistItemTileModel> _createModels(
      List<RatingChecklistItem> allEntries) {
    if (allEntries.isEmpty) {
      return [];
    }

    return <ChecklistItemTileModel>[
      for (RatingChecklistItem item in allEntries) ...[
        ChecklistItemTileModel(
          database: database,
          id: item.checklistItem.id,
          checklistItem: item.checklistItem,
          titleText: item.checklistItem.name,
          bodyText: item.checklistItem.description,
          rating: item.rating?.value ?? 0.0,
          isHeader: false,
          trash: item.checklistItem.trash,
          ordinal: item.checklistItem.ordinal,
        )
      ]
    ];
  }
}
