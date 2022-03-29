
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:insomnia_checklist/services/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/services/shared_preferences_service.dart';
import 'myapp.dart';

Future<void> main({List<String>? args}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  args ??= [];
  if (args.contains('integration_testing'))
    global_testing_active = TestingEnum.integration;
  if (args.contains('unit_testing')) global_testing_active = TestingEnum.unit;

  final sharedPreferences = await SharedPreferences.getInstance();

  if (!kIsWeb &
      (!kReleaseMode || global_testing_active == TestingEnum.integration)) {
    //this requires installing and running the firebase emulator
/*
    final firestoreHost = Platform.isAndroid ? '10.0.2.2' : 'localhost';

    FirebaseFirestore.instance.settings = Settings(
        host: '$firestoreHost:8080',
        sslEnabled: false,
        persistenceEnabled: false);
    await FirebaseAuth.instance.useEmulator('http://$firestoreHost:9099');
*/
    if (global_testing_active == TestingEnum.integration) {
      await FirebaseAuth.instance.signOut();
      await sharedPreferences.setBool(
          SharedPreferencesService.onboardingCompleteKey, false);
    }
  }

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesServiceProvider.overrideWithValue(
        SharedPreferencesService(sharedPreferences),
      ),
    ],
    child: MyApp(),
  ));
}
