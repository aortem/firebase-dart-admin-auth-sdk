import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

void main() async {
  // Replace these with actual values from your environment to test
  final firebaseProjectId = 'your-project-id';
  final targetServiceAccount =
      'flux-gsa-dartcloudfunctions@aortem-prod.iam.gserviceaccount.com';

  try {
    print('Initializing Firebase app with Workload Identity...');
    final firebaseApp = await FirebaseApp.initializeAppWithWorkloadIdentity(
      targetServiceAccount: targetServiceAccount,
      firebaseProjectId: firebaseProjectId,
    );

    final auth = FirebaseAuth(
      firebaseApp: firebaseApp,
      projectId: firebaseProjectId,
    );

    final testEmail =
        'test_user_${DateTime.now().millisecondsSinceEpoch}@example.com';
    print('Attempting to create user: $testEmail');

    // Make the user creation request.
    // Thanks to the fix, this will route to the Admin API: /v1/projects/<projectId>/accounts
    final response = await auth.emailPassword.signUp(
      testEmail,
      'SuperSecret123!',
    );

    print('✅ Firebase user created successfully!');
    print('User UID: ${response?.user.uid}');
    print('User Email: ${response?.user.email}');
  } catch (e) {
    print('❌ Failed to create user: $e');
  }
}
