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
  final transitionDuration = 2000;
  TabItem _currentTab = TabItem.items;
  bool cloak = false;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.items: GlobalKey<NavigatorState>(),
    TabItem.tracking: GlobalKey<NavigatorState>(),
    TabItem.sleep: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
    TabItem.bin: GlobalKey<NavigatorState>(),
  };
  final Map<TabItem, double?> opacities = {
    TabItem.items: 1,
    TabItem.tracking: 0,
    TabItem.sleep: 0,
    TabItem.account: 0,
    TabItem.bin: 0,
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.items: (_) => AnimatedOpacity(child:  ChecklistItemsPage(), duration: Duration(milliseconds: transitionDuration), opacity: opacities[TabItem.items ]!,),
      TabItem.tracking: (_) => TrackingPage(),
      TabItem.sleep: (_) => AnimatedOpacity(child:  SleepPage(), duration: Duration(milliseconds: transitionDuration), opacity: opacities[TabItem.sleep]!,),
      TabItem.account: (_) => AccountPage(),
      TabItem.products: (_){ print('building products ${opacities[TabItem.products]!}' ); final visible= TabItem.products==_currentTab; print('$visible'); return ProductsPage(visible: !cloak && _currentTab==TabItem.products );},
      TabItem.bin: (_) => ChecklistItemsPageTrash(),
    };
  }

  void _select(TabItem tabItem) {


    if (tabItem == _currentTab) {
      // pop to first route
      navigatorKeys[tabItem]!.currentState?.popUntil((route) => route.isFirst);
    } else {

        opacities[_currentTab]=0;
        opacities[tabItem]=0;
        cloak=true;
      setState(() {

      });
      cloak=false;
      setState(() => _currentTab = tabItem);


    }

  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    return;
    setState(() {
      print('setState ${_currentTab.name}');
      opacities[_currentTab]=1;
    });

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
