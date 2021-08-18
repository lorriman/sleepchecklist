import 'package:insomnia_checklist/app/home/models/check_list_item.dart';
import 'package:insomnia_checklist/app/home/models/rating.dart';

class RatingChecklistItem {
  RatingChecklistItem(this.rating, this.checklistItem);

  final Rating? rating;
  final ChecklistItem checklistItem;
}
