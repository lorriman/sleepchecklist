import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/services/shared_preferences_service.dart';

import '../top_level_providers.dart';

class Settings extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeState=ref.read(darkModeProvider.state);
    final isEditingItemsState = ref.read(editItemsProvider.state);

    return ListView(children: [
      DrawerHeader(
        child: Text('Settings', style: Theme.of(context).textTheme.headline4),
      ),
       SwitchListTile(
          title:
              Text('Dark mode', style: Theme.of(context).textTheme.headline5),
          value: darkModeState.state,
          onChanged: (value) {
            darkModeState.state = value;
            final sharedPreferencesService =
                ref.read(sharedPreferencesServiceProvider);
            sharedPreferencesService.sharedPreferences
                .setBool('darkMode', value);
          },
        ),
      SwitchListTile(

        title: Text('Add/Edit items', style: Theme.of(context).textTheme.headline5),
        value: isEditingItemsState.state,
        onChanged: (value) {
          //ignore: dead_null_aware_expression
          isEditingItemsState.state = value;
        },
      )

    ]);
  }
}
