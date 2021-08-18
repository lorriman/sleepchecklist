import 'package:insomnia_checklist/app/auth_widget.dart';
import 'package:insomnia_checklist/app/home/home_page.dart';
import 'package:insomnia_checklist/app/onboarding/onboarding_page.dart';
import 'package:insomnia_checklist/app/onboarding/onboarding_view_model.dart';
import 'package:insomnia_checklist/app/top_level_providers.dart';
import 'package:insomnia_checklist/app/sign_in/sign_in_page.dart';
import 'package:insomnia_checklist/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final firebaseAuth = context.read(firebaseAuthProvider);

    return Consumer(
      builder: (context, watch, _) {
        final darkMode = watch(darkModeProvider);
        return MaterialApp(
          themeMode: darkMode.state ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            visualDensity: VisualDensity.standard,
            primarySwatch: Colors.lightGreen,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.lightGreen,
            brightness: Brightness.dark,
          ),
//      debugShowCheckedModeBanner: false,
          home: AuthWidget(
            nonSignedInBuilder: (_) => Consumer(
              builder: (context, watch, _) {
                final didCompleteOnboarding =
                    watch(onboardingViewModelProvider.state);
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
