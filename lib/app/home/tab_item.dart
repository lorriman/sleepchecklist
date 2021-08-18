import 'package:flutter/material.dart';
import 'package:insomnia_checklist/constants/keys.dart';
import 'package:insomnia_checklist/constants/strings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//import 'package:flutter_icons/flutter_icons.dart';
/*
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'package:fluttericon/brandico_icons.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/fontelico_icons.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/maki_icons.dart';
import 'package:fluttericon/meteocons_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:fluttericon/zocial_icons.dart';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
//import 'package:ionicons/ionicons.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';
*/
enum TabItem { items, tracking, sleep, bin, products, account }

class TabItemData {
  const TabItemData(
      {required this.key, required this.title, required this.icon});

  final String key;
  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.items: TabItemData(
      key: Keys.itemsTab,
      title: Strings.items,
      icon: Icons.today,
    ),
    TabItem.tracking: TabItemData(
      key: Keys.trackingTab,
      title: Strings.tracking,
      icon: Icons.multiline_chart,
    ),
    TabItem.sleep: TabItemData(
      key: Keys.sleepTab,
      title: Strings.sleep,
      icon: FontAwesomeIcons.bed,
    ),
    TabItem.bin: TabItemData(
      key: Keys.binTab,
      title: Strings.bin,
      icon: Icons.delete_rounded,
    ),
    TabItem.products: TabItemData(
      key: Keys.productsTab,
      title: Strings.products,
      icon: Icons.local_mall_outlined,
    ),
    TabItem.account: TabItemData(
      key: Keys.accountTab,
      title: Strings.account,
      icon: Icons.person,
    ),
  };
}
