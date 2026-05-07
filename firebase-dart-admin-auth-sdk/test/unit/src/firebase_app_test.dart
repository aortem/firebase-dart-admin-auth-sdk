import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

void main() {
  setUp(FirebaseApp.resetForTests);
  tearDown(FirebaseApp.resetForTests);

  test('FirebaseApp initializes with environment variables', () async {
    final app = await FirebaseApp.initializeAppWithEnvironmentVariables(
      apiKey: 'fake_api_key',
      authdomain: 'fake.firebaseapp.com',
      projectId: 'fake_project',
      messagingSenderId: '123456',
      bucketName: 'fake.appspot.com',
      appId: 'app-123',
    );

    expect(app, same(FirebaseApp.instance));
    expect(app.getAuth(), isNotNull);
  });

  test('FirebaseApp resetForTests clears singleton state', () async {
    await FirebaseApp.initializeAppWithEnvironmentVariables(
      apiKey: 'fake_api_key',
      authdomain: 'fake.firebaseapp.com',
      projectId: 'fake_project',
      messagingSenderId: '123456',
      bucketName: 'fake.appspot.com',
      appId: 'app-123',
    );

    FirebaseApp.resetForTests();

    expect(() => FirebaseApp.instance, throwsA(isA<StateError>()));
  });
}
