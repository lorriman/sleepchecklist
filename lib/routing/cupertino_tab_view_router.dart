import 'package:flutter/cupertino.dart';
import 'package:insomnia_checklist/app/home/models/check_list_item.dart';

/// Copyright Andrea Bozito, with modifications.
/// Notable additions and classes by Greg Lorriman as noted.

class CupertinoTabViewRoutes {
  static const checklistItemEntriesPage = '/checklistItem-entries-page';
}

class CupertinoTabViewRouter {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case CupertinoTabViewRoutes.checklistItemEntriesPage:
        final checklistItem = settings.arguments as ChecklistItem;
        return CupertinoPageRoute(
          builder: (_) => Center(
              child: Text(
                  'placeholder, see cupertino_tab_view_router.dart')), //ChecklistItemEntriesPage(checklistItem: checklistItem),
          settings: settings,
          fullscreenDialog: false,
        );
    }
    return null;
  }
}
