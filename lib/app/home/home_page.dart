import 'package:flutter/material.dart';
import 'package:insomnia_checklist/app/home/account/account_page.dart';
import 'package:insomnia_checklist/app/home/cupertino_home_scaffold.dart';
import 'package:insomnia_checklist/app/home/products/products_page.dart';
import 'package:insomnia_checklist/app/home/sleep/sleep_page.dart';
import 'package:insomnia_checklist/app/home/tracking/tracking_page.dart';
import 'package:insomnia_checklist/app/home/checklistitems/checklistitems_page.dart';
import 'package:insomnia_checklist/app/home/tab_item.dart';

import 'checklistitems/checklistitems_page_trash.dart';

/// Copyright Andrea Bozito, with modifications.
/// Notable additions and classes by Greg Lorriman as noted.

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.items;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.items: GlobalKey<NavigatorState>(),
    TabItem.tracking: GlobalKey<NavigatorState>(),
    TabItem.sleep: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
    TabItem.bin: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.items: (_) => ChecklistItemsPage(),
      TabItem.tracking: (_) => TrackingPage(),
      TabItem.sleep: (_) => SleepPage(),
      TabItem.account: (_) => AccountPage(),
      TabItem.products: (_) => ProductsPage(),
      TabItem.bin: (_) => ChecklistItemsPageTrash(),
    };
  }

  void _select(TabItem tabItem) {

    if (tabItem == _currentTab) {
      // pop to first route
      navigatorKeys[tabItem]!.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !(await navigatorKeys[_currentTab]!.currentState?.maybePop() ??
              false),
      child: CupertinoHomeScaffold(
        currentTab: _currentTab,
        onSelectTab: _select,
        widgetBuilders: widgetBuilders,
        navigatorKeys: navigatorKeys,
      ),
    );
  }
}
