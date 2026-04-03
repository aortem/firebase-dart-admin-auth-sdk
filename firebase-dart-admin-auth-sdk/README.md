# Firebase Dart Admin Auth SDK

Backend/admin Firebase authentication SDK for Dart.

This package is intended for server-side use: verifying Firebase ID tokens, performing privileged user lookups and mutations, and running admin-authenticated Firebase flows from Dart services.

It is not the recommended place to carry privileged credentials inside browser or mobile apps.

## Installation

```yaml
dependencies:
  firebase_dart_admin_auth_sdk: ^0.1.0
```

## Recommended Initialization Model

Use one of these paths:

1. `initializeAppWithServerCredentials(...)`
   Preferred for most backend apps.
2. `initializeAppWithWorkloadIdentity(...)`
   Use when you explicitly want "must be running on GCP metadata".
3. `initializeAppWithServiceAccount(...)`
   Legacy key-based path. Supported, but not the preferred production pattern.
4. `initializeAppWithEnvironmentVariables(...)`
   API-key/client-style initialization. Keep this for non-admin/client-style flows, not privileged backend auth.

## Preferred Backend Initialization

### Direct Runtime Identity

Use this when the workload already runs as the intended Google service account.

```dart
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

Future<void> main() async {
  await FirebaseApp.initializeAppWithServerCredentials(
    firebaseProjectId: 'my-firebase-project',
  );

  final auth = FirebaseApp.instance.getAuth();
  final decoded = await auth.verifyIdToken('<firebase-id-token>');
  print(decoded['uid']);
}
```

### Target Service Account Impersonation

Use this when the runtime identity should impersonate a different target service account.

```dart
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

Future<void> main() async {
  await FirebaseApp.initializeAppWithServerCredentials(
    firebaseProjectId: 'my-firebase-project',
    targetServiceAccount: 'firebase-admin@my-project.iam.gserviceaccount.com',
  );

  final auth = FirebaseApp.instance.getAuth();
  final user = await auth.getUserByUid('firebase-uid');
  print(user.email);
}
```

## Strict GCP Workload Identity

If you want initialization to fail unless the runtime can reach the GCP metadata server, use:

```dart
await FirebaseApp.initializeAppWithWorkloadIdentity(
  firebaseProjectId: 'my-firebase-project',
  targetServiceAccount: 'firebase-admin@my-project.iam.gserviceaccount.com',
);
```

This path is intentionally GCP-specific. It does not silently turn into generic ADC.

## Common Backend Operations

### Verify an ID Token

```dart
final auth = FirebaseApp.instance.getAuth();
final decoded = await auth.verifyIdToken('<firebase-id-token>');
print(decoded['uid']);
```

### Lookup a User by Firebase UID

```dart
final auth = FirebaseApp.instance.getAuth();
final user = await auth.getUserByUid('firebase-uid');
print(user.email);
```

### Revoke Tokens

```dart
final auth = FirebaseApp.instance.getAuth();
await auth.revokeToken('firebase-uid');
```

## Migration Guidance

If you previously used GCP-specific or impersonation-specific initialization names as the default backend path, prefer moving to:

```dart
await FirebaseApp.initializeAppWithServerCredentials(
  firebaseProjectId: 'my-firebase-project',
  targetServiceAccount: 'firebase-admin@my-project.iam.gserviceaccount.com',
);
```

Reason:
- same mental model across apps
- keyless by default
- direct runtime identity and impersonation share one contract
- less environment-specific branching in app code

## Security Guidance

- Prefer keyless runtime credentials in production.
- Prefer impersonation when the runtime principal and effective Firebase admin principal should differ.
- Do not embed service-account JSON in browser/mobile apps as a standard integration pattern.
- Keep privileged admin operations on the backend.

## Storage Note

`FirebaseApp.getStorage()` currently requires an API-key-backed initialization. It does not yet provide a supported server-credentials storage path. The package now throws a clear error for that case instead of failing with a null-assert crash.
