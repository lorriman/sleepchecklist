insomnia_checklist
=================

Checklist for better sleep - a demo

Introduction
-----------

This simple Flutter app has been over-engineered to demonstrate 
important commercial development capabilities of Greg Lorriman to prospective employers.

### It includes :

- MvvM design pattern

- Abstracted/pluggable backend (eg to allow easier replacement of Firestore)

- Abstracted repository/databasing, to allow easy backend data refactoring and data versioning

- basic Unit and integration tests (see /test and /integration_test)


### The plumbing includes:

* Use of the new Provider library, 'Riverpod'. https://pub.dev/packages/riverpod,  with some rxDart.

* Firestore live streaming/reactive UI.

* Immutable data models.

### It doesn't include (among other things) :

- extensive use of factories and dependency injection
- accessibility/Semantic widgets
- internationalisation
- comprehensive documentation
- comprehensive unit and integration tests
- flavours
- CI/CD
- firestore transactions (as they fail for offline/PWA-style usage)
- Full app functionality (eg, the statistics/tracking tab is a placeholder)
- the polish expected of a fully released app
- testing on anything except android and Firebase emulator
- adherence to Material design guidelines
- adherence to Apple guidelines (the final app will have this, but not this demo)


These latter are excluded since they are not as high priority for a simple demo from a single developer. And also because I intend to fully develope and release the app but as closed-source.

It has not been UXed.

## Notes:

Underlying structure and Cupertino tabs adapted from Andrea Bozzito code at github: https://github.com/bizz84, copyrights duly noted in the source, and some annotations for changes I've made.

## Structure guide

The code includes the following:

Widgets<=>ViewModel stream (fed with data model streams)<=>Database/Repository<=>Backend Service
 
The Backend Service is what calls the Firestore libraries.

Eg, app/.../checklistitems_page.dart :  

ChecklistItemsPage=>ChecklistItemsViewModel=>Repository=>FirestoreService(wrapper around Firestore libs)


## Todos (notes to self) : 
    
    Refactoring/renaming
    sort out ListItemsBuilderV2 and ListItemsBuilderV1
    ReorderableListView issues
    Initial items
    Stats tab - currently unimplemented
    Splash screen
    Localization
    Semantic widgets
    Expand on Unit and integration tests
    Firebase assets instead of local assets
    Prettyfication and animated tab transitions
    Export/backup xls (maybe also import)
    Implement Apple design specs (avoid Apple Store rejection)
    signingConfig to release keys in app:build.gradle
    
    
## Deploy notes

### configuring web deploy google-sign-in (ClientId!=null) 
required this: https://github.com/flutter/plugins/blob/master/packages/google_sign_in/google_sign_in_web/README.md#web-integration
and must be launched for debug from an exactly matching url (port-wise) as configuered on the auth page above eg https://console.cloud.google.com/apis/credentials?project=sleepchecklist-c2478&folder=&organizationId=
eg, as the docs say,   and in Android Studio specify in Run->debug-configurations additional paramters --web-port=7357

### difficulty web debugging 
  chrome->developer-tools->settings turn off source maps and css

### web deploy
 In the AndroidStudio terminal run "flutter build web"
 Then run the CLI executable firebase-tools-instant-win from 'downloads'
 In the CLI cd to the project root folder
 then run "firebase deploy"

 



