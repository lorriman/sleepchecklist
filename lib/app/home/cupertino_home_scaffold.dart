import 'package:flutter/cupertino.dart';
import 'package:insomnia_checklist/app/home/tab_item.dart';
import 'package:insomnia_checklist/constants/keys.dart';
import 'package:insomnia_checklist/routing/cupertino_tab_view_router.dart';

/// Copyright Andrea Bozito, with modifications.
/// Notable additions and classes by Greg Lorriman as noted.

@immutable
class CupertinoHomeScaffold extends StatelessWidget {
  const CupertinoHomeScaffold({
    Key? key,
    required this.currentTab,
    required this.onSelectTab,
    required this.widgetBuilders,
    required this.navigatorKeys,
  }) : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;
  final Map<TabItem, WidgetBuilder> widgetBuilders;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        key: const Key(Keys.tabBar),
        items: [
          _buildNavigationBarItem(TabItem.items),
          _buildNavigationBarItem(TabItem.tracking),
          _buildNavigationBarItem(TabItem.sleep),
          _buildNavigationBarItem(TabItem.bin),
          _buildNavigationBarItem(TabItem.products),
          _buildNavigationBarItem(TabItem.account),
        ],
        onTap: (index) => onSelectTab(TabItem.values[index]),
      ),
      tabBuilder: (context, index) {
        final item = TabItem.values[index];
        return CupertinoTabView(
          navigatorKey: navigatorKeys[item],
          builder: (context) => widgetBuilders[item]!(context),
          //unless builder is commented out, this never gets called. And when it does settings
          //holds no useful info.
          onGenerateRoute: CupertinoTabViewRouter.generateRoute,
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem(TabItem tabItem) {
    final itemData = TabItemData.allTabs[tabItem]!;
    //final color = currentTab == tabItem ? Colors.indigo : Colors.grey;
    return BottomNavigationBarItem(
      icon: Icon(
        itemData.icon,
        key: Key(() {
          final s = 'test${tabItem.toString()}TabButton';

          return s;
        }()),
        //color: color,
      ),
      label: itemData.title,
    );
  }
}
