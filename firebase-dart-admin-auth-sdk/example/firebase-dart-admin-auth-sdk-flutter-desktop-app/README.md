# Firebase Dart Admin Auth SDK Desktop Sample

This sample is a local desktop admin tool for
`firebase_dart_admin_auth_sdk`.

It demonstrates a fitting usage pattern for this package:

- read a local service-account JSON file
- initialize the SDK with `FirebaseApp.initializeAppWithServiceAccount(...)`
- perform an admin user lookup by UID

This is a development/admin-tool sample, not a recommendation to distribute
privileged Firebase credentials to end users.

## Run

```bash
flutter pub get
flutter run -d windows
```

## What To Enter

1. A local path to a Firebase service-account JSON file.
2. An optional Firebase UID to look up after initialization.
