import 'package:insomnia_checklist/app/home/models/rating.dart';
import 'package:insomnia_checklist/app/home/models/sleep.dart';

class FirestorePath {
  static String checklistItem(String uid) => 'users/$uid/checklistItems/items';
  static String checklistItemTrash(String uid) =>
      'users/$uid/checklistItems/items_trash';

  static String checklistItems(String uid) => 'users/$uid/checklistItems/items';
  static String checklistItemsTrash(String uid) =>
      'users/$uid/checklistItems/items_trash';

  static String entry(String uid, String entryId) =>
      'users/$uid/entries/$entryId';
  static String entries(String uid) => 'users/$uid/entries';
  static String ratingsOnDate(String uid, DateTime date) =>
      'users/$uid/ratings/${Rating.dateToString(date)}';
  static String ratingsForChecklistItem(String uid, String checklistItemId) =>
      'users/$uid/checklistItems/$checklistItemId/allDates/data';
  static String sleepRatingsOnDate(String uid, DateTime month) =>
      'users/$uid/sleep_ratings/${SleepRating.dateToYearMonth(month)}';
}
