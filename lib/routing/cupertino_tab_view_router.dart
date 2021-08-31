import 'package:flutter/cupertino.dart';

/// Copyright Andrea Bozito, with modifications.
/// Notable additions and classes by Greg Lorriman as noted.

class CupertinoTabViewRoutes {
  static const checklistItemEntriesPage = '/checklistItem-entries-page';
}

class CupertinoTabViewRouter {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case CupertinoTabViewRoutes.checklistItemEntriesPage:
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
