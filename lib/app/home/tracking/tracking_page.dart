import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:insomnia_checklist/app/home/entries/entries_view_model.dart';
//import 'package:insomnia_checklist/app/home/entries/entries_list_tile.dart';
//import 'package:insomnia_checklist/app/home/checklistitems/list_items_builder.dart';
//import 'package:insomnia_checklist/app/top_level_providers.dart';
import 'package:insomnia_checklist/constants/strings.dart';

import '../settings.dart';


class TrackingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: Drawer(child: Settings()),
      appBar: AppBar(
        title: const Text(Strings.tracking),
        elevation: 2.0,
      ),
      body: _buildContents(context, ref),
    );
  }

  Widget _buildContents(BuildContext context, WidgetRef ref) {

    return Center(
        child: Text('empty placeholder for github forkers to put their own charts, forkers to please acknowledge Greg Lorriman, see tracking/tracking_page.dart'));
  }
}
