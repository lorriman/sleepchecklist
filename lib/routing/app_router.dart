import 'package:email_password_sign_in_ui/email_password_sign_in_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insomnia_checklist/app/home/checklistitems/edit_checklistitem_page.dart';
import 'package:insomnia_checklist/app/home/models/check_list_item.dart';

/// Copyright Andrea Bozito, with modifications.
/// Notable additions and classes by Greg Lorriman as noted.

class AppRoutes {
  static const emailPasswordSignInPage = '/email-password-sign-in-page';
  static const editChecklistItemPage = '/edit-checklistitem-page';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(
      RouteSettings settings, FirebaseAuth firebaseAuth) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.emailPasswordSignInPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EmailPasswordSignInPage.withFirebaseAuth(firebaseAuth,
              onSignedIn: args as void Function()),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.editChecklistItemPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) =>
              EditChecklistItemPage(checklistItem: args as ChecklistItem?),
          settings: settings,
          fullscreenDialog: true,
        );
      /*
      case AppRoutes.entryPage:
        final mapArgs = args as Map<String, dynamic>;
        final checklistItem = mapArgs['checklistitem'] as ChecklistItem;
        final entry = mapArgs['entry'] as Entry?;
        return MaterialPageRoute<dynamic>(
          builder: (_) => EntryPage(checklistItem: checklistItem, entry: entry),
          settings: settings,
          fullscreenDialog: true,
        );

       */
      default:
        // TODO: Throw
        return null;
    }
  }
}
