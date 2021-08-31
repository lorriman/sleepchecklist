import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/services/shared_preferences_service.dart';
import 'package:insomnia_checklist/services/repository.dart';
//import 'dart:io' show Platform;

import 'new_day_notifier.dart';

final itemsDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final sleepDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final newDayProvider = StreamProvider.autoDispose<DateTime>(
    (ref) => newDayStream(Duration(seconds: 1)));

final darkModeProvider = StateProvider<bool>((ref) {
  final prefService = ref.read(sharedPreferencesServiceProvider);
  return prefService.sharedPreferences.getBool('darkMode') ?? false;
});

final editItemsProvider = StateProvider<bool>((ref) {
  return false;
});

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<User?>(
    (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

//todo: rename
final databaseProvider = Provider<Repository>((ref) {
  final auth = ref.watch(authStateChangesProvider);

  if (auth.data?.value?.uid != null) {
    return Repository(uid: auth.data!.value!.uid);
  }
  throw UnimplementedError();
});
