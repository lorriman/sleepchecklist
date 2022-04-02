import 'package:insomnia_checklist/app/auth_widget.dart';
import 'package:insomnia_checklist/app/home/home_page.dart';
import 'package:insomnia_checklist/app/onboarding/onboarding_page.dart';
import 'package:insomnia_checklist/app/onboarding/onboarding_view_model.dart';
import 'package:insomnia_checklist/app/top_level_providers.dart';
import 'package:insomnia_checklist/app/sign_in/sign_in_page.dart';
import 'package:insomnia_checklist/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

class MyApp extends ConsumerStatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.read(firebaseAuthProvider);

    return Consumer(
      builder: (context, ref, _) {
        final darkMode = ref.watch(darkModeProvider.state);
        return MaterialApp(
          themeMode: darkMode.state ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: const [
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            MonthYearPickerLocalizations.delegate,
          ],
          theme: ThemeData(
            visualDensity: VisualDensity.standard,
            primarySwatch: Colors.lightGreen,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.lightGreen,
            brightness: Brightness.dark,
          ),
          home: AuthWidget(
            nonSignedInBuilder: (_) => Consumer(
              builder: (context, ref, _) {
                final didCompleteOnboarding =
                    ref.watch(onboardingViewModelProvider); //todo: is this .state from riverpod upgrade?
                return didCompleteOnboarding ? SignInPage() : OnboardingPage();
              },
            ),
            signedInBuilder: (_) => HomePage(),
          ),
          onGenerateRoute: (settings) =>
              AppRouter.onGenerateRoute(settings, firebaseAuth),
        );
      },
    );
  }
}
