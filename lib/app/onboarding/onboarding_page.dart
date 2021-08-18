import 'package:custom_buttons/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insomnia_checklist/app/onboarding/onboarding_view_model.dart';
import 'package:insomnia_checklist/constants/keys.dart';

/// Copyright Andrea Bozito, with modifications.
/// Notable additions and classes by Greg Lorriman as noted.

class OnboardingPage extends StatelessWidget {
  Future<void> onGetStarted(BuildContext context) async {
    final onboardingViewModel = context.read(onboardingViewModelProvider);
    await onboardingViewModel.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'Track yourself.\nBecause sleep counts.',
                //style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                //FractionallySizedBox(
                //widthFactor: 0.5,
                child: SvgPicture.asset('assets/sleep.svg',
                    semanticsLabel: 'Sleep Logo'),
              ),
            ),
            Expanded(
              flex: 1,
              child: CustomRaisedButton(
                key: Key(Keys.testOnBoardingOnGetStartedButton),
                onPressed: () => onGetStarted(context),
                color: Colors.indigo,
                borderRadius: 30,
                child: Text(
                  'Get Started',
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
