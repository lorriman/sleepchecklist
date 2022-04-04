import 'package:flutter/cupertino.dart';

/// Copyright Andrea Bozito, with modifications.
/// Notable additions and classes by Greg Lorriman as noted.


class CupertinoPageRouteAnimated extends CupertinoPageRoute {
  CupertinoPageRouteAnimated({
    required WidgetBuilder builder,
    String? title,
    RouteSettings? settings,
    bool maintainState=true,
    bool fullscreenDialog=false,
  })
      : super(builder: builder, title: title, settings: settings, maintainState : maintainState, fullscreenDialog: fullscreenDialog);


  // OPTIONAL IF YOU WISH TO HAVE SOME EXTRA ANIMATION WHILE ROUTING
  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(opacity: animation, child: Text('1st placeholder: see cupertino_tab_view_router '));
  }
}

class CupertinoTabViewRoutes {
  static const checklistItemEntriesPage = '/checklistItem-entries-page';
}

class CupertinoTabViewRouter {
  static Route? generateRoute(RouteSettings settings) {
    return CupertinoPageRouteAnimated(
      builder: (_) => Center(
          child: Text(
              '2nd placeholder, see cupertino_tab_view_router.dart')), //ChecklistItemEntriesPage(checklistItem: checklistItem),
      settings: settings,
      fullscreenDialog: false,
    );
    switch (settings.name) {
      case CupertinoTabViewRoutes.checklistItemEntriesPage:
        return CupertinoPageRoute(
          builder: (_) => Center(
              child: Text(
                  '2nd placeholder, see cupertino_tab_view_router.dart')), //ChecklistItemEntriesPage(checklistItem: checklistItem),
          settings: settings,
          fullscreenDialog: false,
        );
    }
    return null;
  }
}
