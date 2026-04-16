# Examples

This directory contains the maintained examples and the reserved sample-app
slots for `firebase_dart_admin_auth_sdk`.

## Maintained Examples

- `poc_workload_identity.dart`
  Backend/admin example for
  `FirebaseApp.initializeAppWithWorkloadIdentity(...)`.
- `firebase-dart-admin-auth-sdk-flutter-desktop-app`
  Desktop admin tool sample that demonstrates
  `FirebaseApp.initializeAppWithServiceAccount(...)` and UID-based lookup.
- `firebase-dart-admin-auth-sdk-flutter-web-app`
  Flutter Web sample that demonstrates
  `FirebaseApp.initializeAppWithEnvironmentVariables(...)` for
  client-style auth flows.

## Reserved Sample-App Directories

The remaining Flutter-only directories are reserved names for future work. They
are not runnable sample apps in this revision of the repository.

- `firebase-dart-admin-auth-sdk-flutter-games-app`
- `firebase-dart-admin-auth-sdk-flutter-mobile-app`

Because this package is primarily a backend/admin SDK, privileged Firebase
operations should stay on a backend service. Frontend frameworks should call
that backend instead of embedding admin credentials directly in the UI.
