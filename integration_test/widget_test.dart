import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insomnia_checklist/constants/keys.dart';

import 'package:insomnia_checklist/main.dart' as appmain;
//import 'package:insomnia_checklist/myapp.dart' as

void main() {
  testWidgets('anon signup, add item and register sleep', (tester) async {
    await appmain.main(args: ['integration_testing']);

    await tester.pumpAndSettle();
    // Build our app and trigger a frame.
//    await tester.pumpWidget(MyApp());

    //testing framework is not reliable at resetting app, so....
    final finder = find.byKey(Key(Keys.testOnBoardingOnGetStartedButton));
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(find.byKey(Key(Keys.testOnBoardingOnGetStartedButton)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(Keys.anonymous)));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(Key('checklistItem-0')), findsNothing);
    await tester.tap(find.byKey(Key(Keys.testEditToggleButton)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(Keys.newChecklistItemButton)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key(Keys.testEditItemTextName)), 'Item1');

    await tester.pump();

    await tester.enterText(
      find.byKey(Key(Keys.testEditItemTextDescription)),
      'Description1',
    );
    await tester.tap(find.byKey(Key(Keys.testEditItemSaveButton)));

    await tester.pumpAndSettle(Duration(seconds: 2));
    expect(find.byKey(Key('dismissable_checklistItem-0')), findsOneWidget);
    expect(find.byKey(Key('dismissable_checklistItem-1')), findsNothing);
    await tester.drag(
        find.byKey(Key('dismissable_checklistItem-0')), Offset(2000, 0));

    await tester.pumpAndSettle(Duration(seconds: 2));
    expect(find.byKey(Key('dismissable_checklistItem-0')), findsNothing);
    await tester.tap(find.byKey(Key('testTabItem.binTabButton')));

    await tester.pumpAndSettle(Duration(seconds: 2));
    expect(find.byKey(Key('dismissable_checklistItem-null')), findsOneWidget);
    await tester.drag(
        find.byKey(Key('dismissable_checklistItem-null')), Offset(-2000, 0));

    await tester.pumpAndSettle(Duration(seconds: 2));
    expect(find.byKey(Key('dismissable_checklistItem-null')), findsNothing);

    await tester.tap(find.byKey(Key('testTabItem.itemsTabButton')));
    await tester.pumpAndSettle(Duration(seconds: 2));
    expect(find.byKey(Key('dismissable_checklistItem-0')), findsOneWidget);

    // Verify that our counter starts at 0.
//    expect(find.byKey(Key(Keys.emailPassword)), findsOneWidget);
    //  expect(find.text('1'), findsNothing);
/*
    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  */
  });
}
