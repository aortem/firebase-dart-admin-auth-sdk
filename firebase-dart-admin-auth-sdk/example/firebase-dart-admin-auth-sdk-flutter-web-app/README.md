# Firebase Dart Admin Auth SDK Flutter Web Example

This is the only maintained UI sample app currently shipped under `example/`.

It demonstrates how the package is wired into a Flutter Web application using
`FirebaseApp.initializeAppWithEnvironmentVariables(...)` for client-style auth
flows.

This sample is useful for local exploration of the package surface, but it is
not the recommended place to carry privileged Firebase admin credentials. For
production admin flows, keep the SDK on a backend service and call that backend
from the UI.

For backend-first initialization examples, see:

- `../poc_workload_identity.dart`
- `../../README.md`

## Local Setup

1. Open `lib/main.dart`.
2. Replace the placeholder Firebase values such as `YOUR_API_KEY` and
   `YOUR_PROJECT_ID`.
3. Run `flutter pub get`.
4. Run the app with `flutter run -d chrome`.

## Initialization Path Used in This Sample

```dart
await FirebaseApp.initializeAppWithEnvironmentVariables(
  apiKey: 'YOUR_API_KEY',
  authdomain: 'YOUR_AUTH_DOMAIN',
  projectId: 'YOUR_PROJECT_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  bucketName: 'YOUR_BUCKET_NAME',
  appId: 'YOUR_APP_ID',
);
```

After initialization, the sample obtains the auth client with:

```dart
final auth = FirebaseApp.instance.getAuth();
```

## Scope

- Maintained: Flutter Web sample app
- Not maintained here: mobile, desktop, games, React, Vue, Svelte, and Compose
  sample apps
