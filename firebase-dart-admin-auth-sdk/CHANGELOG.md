## **0.0.10**

### **Added**

- **Workload Identity Documentation**:
  - Added comprehensive README section for Workload Identity support
  - Documented initialization via `initializeAppWithWorkloadIdentity()` for GKE, Cloud Run, and GCE
  - Provided step-by-step IAM setup instructions for Kubernetes Service Account (KSA) to Google Service Account (GSA) mapping
  - Added Workforce Identity Federation (WIF) documentation for external IdPs (GitHub, AWS, Azure AD, Okta)
  - Included comparison table between Workload Identity and WIF approaches
  - Added benefits summary and best practices for credential-less authentication

- **Code Examples**:
  - GKE Workload Identity initialization example with metadata server integration
  - Workforce Identity Federation example for external IdP token exchange
  - Complete IAM setup scripts for service account binding

- **MFA (Admin) Support**:
  - Added `FirebaseAuth` helpers: `getMfaEnrollments`, `isMfaEnrolled`, `verifyIdTokenMfa`, `enforceMfa`
  - Added MFA models `MultiFactorEnrollment` and `MfaVerificationResult` (and exported)
  - User parsing now captures `mfaInfo` as `enrolledFactors` and derives `mfaEnabled` when factors exist

- **Workload Identity Example**:
  - Added `example/poc_workload_identity.dart` showcasing admin API usage with Workload Identity

### **Fixed**

- **Admin API Routing for Server Flows**:
  - `performRequest` now uses project-scoped endpoints (`/v1/projects/{projectId}/accounts`) when using bearer tokens and no API key
  - Access token refresh now runs for Workload Identity (no service account) when `firebaseApp` is set

### **Documentation**

- Added "MFA (Admin)" section with enrollment lookup and enforcement examples
- Updated README with three new sections under Authentication Methods:
  - "Workload Identity" - for GCP-native environments
  - "Workforce Identity Federation (External IdPs)" - for external identity providers
  - Prerequisites and setup instructions for both approaches
- Clarified authentication hierarchy: Environment Variables (Web) → Service Account (Mobile) → Workload Identity (GCP) → WIF (External)

## **0.0.9**

### **Changed**

- **Dart SDK Requirement Bump**
  - Updated all relevant `pubspec.yaml` files to require:
    **`sdk: ^3.10.7`**
    This ensures alignment with the latest stable Dart toolchain and improves compatibility with modern packages.
  - Applies to:
    - Main package `pubspec.yaml`
    - Example Flutter web app `pubspec.yaml`

- **Dependency Updates**
  - Upgraded internal standard libraries:
    - `ds_standard_features`: **^0.1.4 → ^0.1.5**
    - `ds_tools_testing`: **^0.1.3 → ^0.1.4**

  - These updates bring improved platform utilities and more consistent testing helpers.

- **Example App Cleanup**
  - Updated example app dependency declaration to simplify version consistency.
  - Ensured example no longer pins outdated SDK constraints.

## 0.0.8

### Changed

- **Refactored `CreateUserWithEmailAndPasswordService` internal flow:**
  - Simplified parameter handling; now accepts `email` and `password` directly, with `FirebaseAuth` injected once via constructor.
  - Removed redundant `authInstance` argument across internal calls.
  - Aligned response parsing with `performRequest` standard payload format.

### Improved

- Added structured logging around token creation and assignment.
- Enhanced validation: prevents attempts with missing or malformed credentials.
- Clearer exception messages for Firebase API errors.

### Added

- Integration test coverage for successful user creation and invalid credentials.
- Inline documentation for request/response schema.
- Support for future extension to custom providers (GitHub, Google, etc.) via a unified request handler.

### Removed

- Leftover debug prints from previous release (`// debug: print(...)`).
- Obsolete helper methods superseded by `performRequest` abstraction.

## 0.0.7

### Changed

- **Refactored `CreateUserWithEmailAndPasswordService`**:
  - Constructor simplified: `final FirebaseAuth auth` defined directly, instead of passing multiple redundant fields.
  - Method signature updated: `create(String email, String password, FirebaseAuth authInstance)` (was `auth`).
  - Replaced manual HTTP request logic with `authInstance.performRequest('signUp', {...})`.

### Improved

- Added structured `try` block for better error handling and logging.
- Debug logging (commented out) for easier troubleshooting:
  - Email being processed.
  - Presence of API key.
  - Response status and presence of tokens.

### Added

- Proper construction of `User` object using `User.fromJson(userData, apiKey: authInstance.apiKey)`.
- Automatic assignment of `idToken` and `refreshToken` if present in response.
- More detailed debug output for created `User` object (UID, tokens, API key).

### Removed

- Manual token refresh flow (`firebaseApp.getValidAccessToken()`).
- Custom HTTP request building with `Uri.https` and manual headers.
- Inline JSON serialization and error decoding — now centralized in `performRequest`.

## 0.0.6

### Changed

- **Dart SDK**:
  - Raised minimum version requirement from `3.8.1` → `3.9.0` across examples and documentation.
  - Updated README instructions to reflect `Dart 3.9.0` requirement.

- **Dependencies / Examples**:
  - Updated example `pubspec.yaml` to require `sdk: ^3.10.7`.
  - Simplified dependency reference in the example Flutter web app:
    - Replaced local path dependency (`firebase_dart_admin_auth_sdk: { path: ... }`) with a versioned dependency string.

- **Documentation**:
  - Updated README installation snippet to reference `firebase_dart_admin_auth_sdk: ^0.0.6` (was `^0.0.1-pre+15`).

## 0.0.5

### Changed

- **Dependencies**:
  - Updated `ds_standard_features` to `^0.1.0`.
  - Updated `ds_tools_testing` dev dependency to `^0.0.9`

## 0.0.4

### Changed

- **Dependencies**:
  - Updated `ds_standard_features` to `^0.0.8`.
  - Updated `ds_tools_testing` dev dependency to `^0.0.5` and added `lints: ^6.0.0`.

## 0.0.3

### Changed

- Bump `ds_standard_features` dependency from `^0.0.4` to `^0.0.7` to pull in the latest HTTP utilities.

### Removed

- Split the Flutter mobile sample app into web and mobile (`example/firebase-dart-admin-auth-sdk-flutter-mobile-app`).
- Purged generated build artifacts (e.g. `build/`, intermediate CMake files) from the example directories to keep the package lean.

## 0.0.2

- Bump Dart Version to 3.9.0
- Formatting Changes To Satify Dart Formatter
- Update BSD-3 License

## 0.0.1

- fix and refactor unused code and comments in link_with_credientials.dart.
- refactor signInWithGoogle() logic into a new sign_in_with_credential_view_model.dart for better separation of concerns.
- add sign_in_with_credential_view_model.dart: Introduced a new view model with a comprehensive and platform-adaptive signInWithGoogle() method for both web and mobile.
- add new sign_in_with_popup_screen.dart: New UI screen component likely supporting OAuth sign-in flow via popup.
- Core SDK logic updates with significant changes made to lib/src/firebase_auth.dart:
- refactor to improved credential linking and multi-platform sign-in flows.
- minor updates to multi_factor_resolver.dart.
- dependency Updates Updated one dependency in pubspec.yaml.

## 0.0.3-pre

- Eliminated redundant import statements
- Removed duplicate lines for BotToast, firebase_dart_admin_auth_sdk, flutter/material.dart, and flutter_facebook_auth.
- Added a web-specific branch that uses the Google Identity Services (via gis, id, and oauth2) for handling Google OAuth.
- Configured logging for the web SDK (id.setLogLevel('debug')) and updated the token request workflow.
- Enhanced error handling by logging detailed information for cancellation, token errors, and linking failures.
- Added additional try/catch blocks and BotToast notifications for user feedback on errors.
- Ensured that separate code paths for web and mobile are clearly distinguished, with appropriate flows for each platform.
- Consolidated the sign-in logic to reduce code duplication (e.g., signing in with Google and linking credentials).
- Incorporated navigation to the HomeScreen after a successful link with credentials.
- Added BotToast feedback to confirm when an account has been successfully linked.

## 0.0.2-pre

**🐛 Bug Fixes**

- firebase‑sdk: resolve dart analyze errors
- firebase‑sdk: resolve dart analyze errorsand dart dry run
- fixed access token issue
- fixed build error, removed project level android home

**✨ New Features**

- auth: add Microsoft sign‑in and update auth_redirect_link docs
- auth: add verify id token method
- auth: implement Apple authentication with webview support
- auth: implement service account without impersonation key
- auth: support service account without impersonation key for Dart and Flutter server‑side
- auth: updated verify token method
- implemented remaining tickets
- implemented service account impersonation with gcp
- implemented service account impersonation, added proper documentations

**🧹 Chore**

- add build runner and test cases
- add code cov and pipeline triggers
- add conditional imports and update pipeline for merged results
- add dart doc commnets
- add logo

## 0.0.1-pre+22

- yaml update

## 0.0.1-pre+21

- update SDK to 3.9.0

## 0.0.1-pre+20

- update SDK to 3.7.0

## 0.0.1-pre+19

- additional update to firebase.verifyidtoken method

## 0.0.1-pre+18

- add firebase.verifyidtoken method

## 0.0.1-pre+17

HotFix:

- Impersonate Service Account Without keys update.
- Reverting to the previous method name FirebaseApp.`initializeAppWithServiceAccountImpersonationGCP`

## 0.0.1-pre+16

- Create a service account without using the key impersonation method
- Authenticate using the service account email and project ID
- Obtain ADC (Application Default Credentials) from Google Cloud for authentication
- Remove all incorrect code and previous methods related to this function

## 0.0.1-pre+15

- support service account without impersonation key
- remove node modules

## 0.0.1-pre+14

- Update Yaml file for core dependencies
- add service account impersonation via gap
- update the api call of the following:
  - apple sign in auth
  - send verification code
  - sign in with redirect
  - refresh token
  - check action code
  - confirm password
  - create account with email and password
  - fetch sign in methods
  - send password reset email
  - send verification code

## 0.0.1-pre+13

- Update SDK version to 3.6.0

## 0.0.1-pre+12

- Update SDK version formatting

## 0.0.3

- add sign in with redirect & link with credentials & verify password reset code
- add Micorsoft Integration
- update documentation: Added `auth_redirect_link'.
- add feat (auth): Completed the "Sign in with Microsoft" feature and integrated it into a sample app.
- added webView to open apple sign-page page(uses 'client_id=YOUR_SERVICES_ID&')
- fix(code): Removed unused files:
- auth_link_with_phone_number_stub.dart
- auth_redirect_link_stub.dart

## 0.0.1-pre+10

- Add debug initialization in sample app for better testing
- Add Sign In With Facebook To Sample App.
- Add Remaining Signin Methods to the Sample App
- Introduce unit and integration testing
- Update remaining doc dart issues for code clarity

## 0.0.1-pre+9

- Update changelog format of previous release
- Update service account format

## 0.0.1-pre+8

- Add Linter rules for public_members and better code transperancy
- Add initalization with Service Account Impersonation and proper documentation
- Update Gradle Build files and dependencies
- Implement FirebaseAuth.signInWithCustomToken in Sample App
- Implement FirebaseAuth.generateCustomToken in Sample App
- Implement FirebaseAuth.verifyPasswordResetCode in Sample App
- Improve Dart Doc Comments

## 0.0.1-pre+7

- Added README.md for example folder naming conventions.

## 0.0.1-pre+6

- Updated pub.dev README and feature check list for -pre+6 release
- FirebaseUser.linkWithPopup implemented in Sample App
- FirebaseUser.linkWithCredential implemented in Sample App
- FirebaseAuth.signInWithPhoneNumber implemented in Sample App
- FirebaseAuth.getRedirectResult implemented in Sample App
- FirebaseAuth.signInWithRedirect implemented in Sample App
- FirebaseApp.getAuth implemented in Sample App
- FirebaseApp.initializeAuth implemented in Sample App
- Moved example folder for the sample app to proper location for dart conventions.

## 0.0.1-pre+5

- FirebaseStorage.getStorage added to Sample App
- FirebaseAuth.setPersistence added to Sample App
- FirebaseAuth.initializeRecaptchaConfig Method implemented in Sample App
- FirebaseAuth.confirmPasswordReset Method implemented in Sample App
- FirebaseAuth.isSignInWithEmailLink Method implemented in Sample App
- FirebaseAuth.checkActionCode added to Sample App

## 0.0.1-pre+4

- Sample App Package Name Fix
- Service Account Firebase initialization method on Sample App fixed
- FirebaseAuth.createUserWithEmailAndPassword feature implemented in Sample App
- FirebaseAuth.signInWithEmailAndPassword feature implemeneted in Sample App
- Initialize Firebase with Environment Variables GCP Auth Method # 2 implemented in Sample App
- FirebaseAuth.connectAuthEmulator feature implemented in Sample App
- FirebaseAuth.signInWithCredential (Google) implemented in Sample App
- FirebaseAuth.setLanguageCode() implemented in Sample App
- FirebaseUser.updatePassword() implemented in Sample App
- FirebaseUser.reload() implemented in Sample App
- FirebaseUser.unlink(Google, Apple) - auth provider Google & Apple implemented in Sample App
- FirebaseUser.sendEmailVerification() implemented in Sample App
- FirebaseAuth.revokeAccessToken() implemented in Sample App
- FirebaseAuth.applyActionCode implemented in Sample App
- Update the User model
- Added a copy with function to the user model
- Used the copy with function in the updateUser method.
- Added web and grpc libraries to the pubspec.yaml
- FirebaseAuth.signOut feature implemented in the Sample App
- FirebaseAuth.updateCurrentUser feature implemented in Sample App
- FirebaseLink.parseActionCodeURL feature implemented in Sample App
- FirebaseUser.deleteUser feature implemented in Sample App
- FirebaseUser.getIdToken feature implemented in Sample App
- FirebaseUser.getIdTokenResult feature implemented in Sample App
- FirebaseAuth.getMultiFactorResolver Method implemented in Sample App
- FirebaseAuth.fetchSignInMethodsForEmail implemented in Sample App
- FirebaseAuth.connectAuthEmulator implemented in Sample App
- FirebaseAuth.sendPasswordResetEmail Method implemented in Sample App
- FirebaseAuth.revokeAccessToken Method implemented in Sample App
- FirebaseAuth.onIdTokenChanged Method implemented in Sample App
- FirebaseAuth.onAuthStateChanged Method implemented in Sample App

## 0.0.1-pre+3

- Update sendPasswordResetEmail
- Update revokeAccessToken
- Update onIdTokenChanged
- Update onAuthStateChanged
- Update isSignInWithEmailLink
- Update dispose method

## 0.0.1-pre+2

- Add sendPasswordResetEmail
- Add revokeAccessToken
- Add onIdTokenChanged
- Add onAuthStateChanged
- Add isSignInWithEmailLink
- Add dispose method

## 0.0.1-pre+1

- Add new authentication methods to FirebaseAuth class
- Implement signInWithCustomToken, signInWithCredential, sendSignInLinkToEmail, and signInWithEmailLink
- Update test suite with new tests for added functions
- Resolve ActionCodeSettings import and usage issues in tests
- Update README with documentation for new authentication methods
- Improve error handling and response parsing for all auth methods
- Ensure compatibility with latest Firebase Auth API changes
- Update Documentation and support subscriptions.

## 0.0.1-pre

- Initial pre-release version of the Firebase Dart Admin Auth SDK.
