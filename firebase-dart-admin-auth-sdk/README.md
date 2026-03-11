# Firebase Dart Admin Auth SDK

## Overview

The Firebase Dart Admin Auth SDK offers a robust and flexible set of tools to perform authentication procedures within Dart or Flutter projects. This is a Dart implementation of Firebase admin authentication.

## Features:

- **User Management:** Manage user accounts seamlessly with a suite of comprehensive user management functionalities.
- **Custom Token Minting:** Integrate Firebase authentication with your backend services by generating custom tokens.
- **Generating Email Action Links:** Perform authentication by creating and sending email action links to users emails for email verification, password reset, etc.
- **ID Token verification:** Verify ID tokens securely to ensure that application users are authenticated and authorised to use app.
- **Managing SAML/OIDC Provider Configuration**: Manage and configure SAML and ODIC providers to support authentication and simple sign-on solutions.

## Getting Started

If you want to use the Firebase Dart Admin Auth SDK for implementing a Firebase authentication in your Flutter projects follow the instructions on how to set up the auth SDK.

- Ensure you have a Flutter or Dart (3.9.0) SDK installed in your system.
- Set up a Firebase project and service account.
- Set up a Flutter project.

## Installation

For Flutter use:

```javascript
flutter pub add firebase_dart_admin_auth_sdk
```

You can manually edit your `pubspec.yaml `file this:

```yaml
dependencies:
  firebase_dart_admin_auth_sdk: ^0.0.11
```

You can run a `flutter pub get` for Flutter respectively to complete installation.

**NB:** SDK version might vary.

## Usage

**Example:**

```
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase/screens/splash_screen/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // Initialize for web
      debugPrint('Initializing Firebase for Web...');
      FirebaseApp.initializeAppWithEnvironmentVariables(
        apiKey: 'YOUR-API-KEY',
        projectId: 'YOUR-PROJECT-ID',
        bucketName: 'Your Bucket Name',
      );
      debugPrint('Firebase initialized for Web.');
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        debugPrint('Initializing Firebase for Mobile...');

        // Load the service account JSON
        String serviceAccountContent = await rootBundle.loadString(
          'assets/service_account.json',
        );
        debugPrint('Service account loaded.');

        // Initialize Firebase with the service account content
        await FirebaseApp.initializeAppWithServiceAccount(
          serviceAccountContent: serviceAccountContent,
        );
        debugPrint('Firebase initialized for Mobile.');
      }
    }

    // Access Firebase Auth instance
    final auth = FirebaseApp.instance.getAuth();
    debugPrint('Firebase Auth instance obtained.');

    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('Error initializing Firebase: $e');
    debugPrint('StackTrace: $stackTrace');
  }
}

```

- Import the package into your Dart or Flutter project:

  ```
  import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
  ```

  For Flutter web initialize Firebase app as follows:

  ```
  FirebaseApp.initializeAppWithEnvironmentVariables(
    apiKey: 'YOUR-API-KEY',
    projectId: 'YOUR-PROJECT-ID',
    bucketName: 'Your Bucket Name',
  );
  ```

- For Flutter mobile:
  - Load the service account JSON

  ```
     String serviceAccountContent = await rootBundle.loadString(
       'assets/service_account.json',
     );
  ```

  - Initialize Flutter mobile with service account content

  ```
    await FirebaseApp.initializeAppWithServiceAccount(
      serviceAccountContent: serviceAccountContent,
    );
  ```

- Access Firebase Auth instance.
  ```
     final auth = FirebaseApp.instance.getAuth();
  ```

## Workload Identity

Workload Identity allows your application to authenticate using Google Cloud credentials without managing long-lived service account keys. This is the recommended approach for applications running on GKE (Kubernetes Engine), Cloud Run, or GCE (Compute Engine).

### Using Workload Identity on GKE / Cloud Run

For applications running on Google Cloud Platform infrastructure (GKE, Cloud Run, GCE), use Application Default Credentials (ADC) via the metadata server:

```dart
import 'dart:io';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

Future<void> main() async {
  try {
    // Initialize with Workload Identity (GKE/Cloud Run)
    // This automatically fetches tokens from the metadata server
    // No service account keys required!
    await FirebaseApp.initializeAppWithWorkloadIdentity(
      targetServiceAccount: 'my-sa@my-project.iam.gserviceaccount.com',
      firebaseProjectId: 'my-project',
    );

    final auth = FirebaseApp.instance.getAuth();
    debugPrint('Firebase initialized with Workload Identity');

    // Use Firebase Auth normally
    // Tokens are automatically refreshed
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }
}
```

#### Prerequisites for GKE Workload Identity:

1. **Create a Google Service Account (GSA)**:

   ```bash
   gcloud iam service-accounts create my-sa \
     --display-name="My Firebase Service Account"
   ```

2. **Grant IAM roles** to the service account:

   ```bash
   gcloud projects add-iam-policy-binding my-project \
     --member=serviceAccount:my-sa@my-project.iam.gserviceaccount.com \
     --role=roles/firebase.admin
   ```

3. **Create a Kubernetes Service Account (KSA)** and bind it to the GSA:

   ```bash
   kubectl create serviceaccount my-app-ksa -n default

   gcloud iam service-accounts add-iam-policy-binding \
     my-sa@my-project.iam.gserviceaccount.com \
     --role roles/iam.workloadIdentityUser \
     --member "serviceAccount:my-project.svc.id.goog[default/my-app-ksa]"

   kubectl annotate serviceaccount my-app-ksa \
     iam.gke.io/gcp-service-account=my-sa@my-project.iam.gserviceaccount.com
   ```

4. **Deploy your application** using the KSA:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: my-app
   spec:
     serviceAccountName: my-app-ksa
     containers:
       - name: app
         image: my-app:latest
   ```

### Workforce Identity Federation (External IdPs)

For applications running outside GCP (AWS, GitHub, Azure, etc.), use Workforce Identity Federation to exchange external tokens for Google service account credentials:

```dart
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

Future<void> main() async {
  try {
    // Initialize with Workforce Identity Federation
    // Supports external IdPs: GitHub, AWS, Azure AD, Okta, etc.
    await FirebaseApp.initializeAppWithWorkloadIdentityFederation(
      targetServiceAccount: 'my-sa@my-project.iam.gserviceaccount.com',
      externalToken: 'your-github-token-or-aws-credential', // From external IdP
      projectNumber: '1234567890', // Your GCP project number
      workforcePoolId: 'my-pool', // WIF pool ID
      providerId: 'github', // github, aws, azure-ad, etc.
      firebaseProjectId: 'my-project',
    );

    final auth = FirebaseApp.instance.getAuth();
    debugPrint('Firebase initialized with Workforce Identity Federation');

    // Use Firebase Auth normally
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }
}
```

#### Prerequisites for Workforce Identity Federation:

1. **Create a Workforce Pool** in Google Cloud Console or via gcloud
2. **Configure external IdP** (GitHub, AWS, Azure AD, etc.) in the pool
3. **Create a workload identity provider** pointing to your external IdP
4. **Grant IAM roles** to the service account for external identities:
   ```bash
   gcloud iam service-accounts add-iam-policy-binding \
     my-sa@my-project.iam.gserviceaccount.com \
     --role roles/iam.workloadIdentityUser \
     --member "principalSet://goog/subject/{subject-claim}"
   ```
5. **Obtain external token** from your IdP and pass it to `initializeAppWithWorkloadIdentityFederation()`

#### Comparison: Workload Identity vs WIF

| Feature              | Workload Identity (GCP) | WIF (External)                |
| -------------------- | ----------------------- | ----------------------------- |
| **Environment**      | GKE, Cloud Run, GCE     | Any (AWS, GitHub, etc.)       |
| **Token Source**     | GCP Metadata Server     | External IdP                  |
| **Setup Complexity** | Low (KSA + GSA mapping) | Medium (IdP + pool config)    |
| **Token Refresh**    | Automatic               | Requires exchange via STS     |
| **Best For**         | GCP-native deployments  | Multi-cloud / CI/CD pipelines |

### Benefits of Workload Identity

✅ **No Long-Lived Keys**: Eliminates the need to manage service account JSON files  
✅ **Short-Lived Tokens**: Automatic token rotation with minimal lifetime  
✅ **Audit Trail**: Full IAM audit logging of all credential usage  
✅ **Fine-Grained Control**: Precise IAM role assignment per service account  
✅ **Simplified Secrets Management**: No need to rotate or store sensitive keys

## MFA (Admin)

Use these helpers to inspect MFA enrollments and enforce MFA for backend flows.

```dart
final auth = FirebaseApp.instance.getAuth();

// Enrollments by uid or idToken (provide exactly one).
final enrollments = await auth.getMfaEnrollments(uid: 'user-uid');
final hasMfa = await auth.isMfaEnrolled(uid: 'user-uid');

// Verify MFA status based on ID token claims.
final mfaStatus = await auth.verifyIdTokenMfa(idToken);
if (!mfaStatus.isMfaVerified) {
  // reject sensitive operation
}

// Enforce MFA (throws FirebaseAuthException if not verified).
await auth.enforceMfa(idToken, requireEnrollment: true);
```

## MFA / 2FA Sign-In and Enrollment

The SDK now supports the client-side Firebase Identity Toolkit MFA flow directly.

### Handle MFA-required sign-in

```dart
final auth = FirebaseApp.instance.getAuth();

try {
  await auth.signInWithEmailAndPassword('user@example.com', 'super-secret');
} on MultiFactorError catch (error) {
  final resolver = await auth.getMultiFactorResolver(error);

  // For SMS factors, start the challenge first.
  final smsChallenge = await resolver.startSignInChallenge(
    enrollmentId: error.hints.first.enrollmentId!,
    phoneSignInInfo: StartPhoneMfaSignInInfo(
      recaptchaToken: 'browser-recaptcha-token',
    ),
  );

  final signInResult = await resolver.resolveSignIn(
    MultiFactorAssertion.phone(
      sessionInfo: smsChallenge.sessionInfo!,
      verificationCode: '123456',
    ),
  );

  print(signInResult.user.uid);
}
```

### Enroll SMS MFA

```dart
final auth = FirebaseApp.instance.getAuth();
final currentIdToken = await auth.currentUser!.getIdToken();

final start = await auth.startMfaEnrollment(
  idToken: currentIdToken,
  phoneEnrollmentInfo: StartPhoneMfaEnrollmentInfo(
    phoneNumber: '+15551234567',
    recaptchaToken: 'browser-recaptcha-token',
  ),
);

await auth.finalizeMfaEnrollment(
  idToken: currentIdToken,
  displayName: 'Personal phone',
  phoneVerificationInfo: FinalizePhoneMfaEnrollmentInfo(
    sessionInfo: start.sessionInfo!,
    code: '123456',
  ),
);
```

### Enroll TOTP MFA

```dart
final auth = FirebaseApp.instance.getAuth();
final currentIdToken = await auth.currentUser!.getIdToken();

final start = await auth.startMfaEnrollment(
  idToken: currentIdToken,
  totp: true,
);

await auth.finalizeMfaEnrollment(
  idToken: currentIdToken,
  displayName: 'Authenticator app',
  totpVerificationInfo: FinalizeTotpMfaEnrollmentInfo(
    sessionInfo: start.totpSessionInfo!,
    verificationCode: '123456',
  ),
);
```

## Documentation

For more refer to Gitbook for prelease [documentation here](https://aortem.gitbook.io/firebase-dart-auth-admin-sdk/).
