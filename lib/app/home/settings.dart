import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/services/shared_preferences_service.dart';

import '../top_level_providers.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      DrawerHeader(
        decoration: BoxDecoration(
            //color: Colors.blue,
            ),
        child: Text('Settings', style: Theme.of(context).textTheme.headline4),
      ),
      Consumer(builder: (context, watch, _) {
        watch(darkModeProvider);

        return SwitchListTile(
          title:
              Text('Dark mode', style: Theme.of(context).textTheme.headline5),
          value: context.read(darkModeProvider).state,
          onChanged: (value) {
            context.read(darkModeProvider).state = value;
            final sharedPreferencesService =
                context.read(sharedPreferencesServiceProvider);
            sharedPreferencesService.sharedPreferences
                .setBool('darkMode', value);
          },
        );
      }),
    ]);
  }
}
