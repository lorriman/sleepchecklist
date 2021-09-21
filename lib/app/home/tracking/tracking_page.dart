import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:insomnia_checklist/app/home/entries/entries_view_model.dart';
//import 'package:insomnia_checklist/app/home/entries/entries_list_tile.dart';
//import 'package:insomnia_checklist/app/home/checklistitems/list_items_builder.dart';
//import 'package:insomnia_checklist/app/top_level_providers.dart';
import 'package:insomnia_checklist/constants/strings.dart';

import '../settings.dart';

/*
final entriesTileModelStreamProvider = StreamProvider.autoDispose<List<EntriesListTileModel>>(
      (ref) {
    final database = ref.watch(databaseProvider);
    final vm = EntriesViewModel(database: database);
    return vm.entriesTileModelStream;
  },
);
*/
class TrackingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      drawer: Drawer(child: Settings()),
      appBar: AppBar(
        title: const Text(Strings.tracking),
        elevation: 2.0,
      ),
      body: _buildContents(context, watch),
    );
  }

  Widget _buildContents(BuildContext context, ScopedReader watch) {
    /*
    final entriesTileModelStream = watch(entriesTileModelStreamProvider);
    return ListItemsBuilder<EntriesListTileModel>(
      trashView: false,
      data: entriesTileModelStream,
      itemBuilder: (context, model) => EntriesListTile(model: model),
    );
    */
    return Center(
        child: Text('empty placeholder, see tracking/tracking_page.dart'));
  }
}
