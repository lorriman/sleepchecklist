import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/services/shared_preferences_service.dart';

import '../top_level_providers.dart';

class Settings extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(children: [
      DrawerHeader(
        decoration: BoxDecoration(
            //color: Colors.blue,
            ),
        child: Text('Settings', style: Theme.of(context).textTheme.headline4),
      ),
      Consumer(builder: (context, ref, _) {
        ref.watch(darkModeProvider.state);

        return SwitchListTile(
          title:
              Text('Dark mode', style: Theme.of(context).textTheme.headline5),
          value: ref.read(darkModeProvider.state).state,
          onChanged: (value) {
            ref.read(darkModeProvider.state).state = value;
            final sharedPreferencesService =
                ref.read(sharedPreferencesServiceProvider);
            sharedPreferencesService.sharedPreferences
                .setBool('darkMode', value);
          },
        );
      }),
    ]);
  }
}
