import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    FirebaseApp.resetForTests();
  });

  test('FirebaseApp initializes with env variables', () async {
    final app = await FirebaseApp.initializeAppWithEnvironmentVariables(
      apiKey: 'fake_api_key',
      authdomain: 'fake.firebaseapp.com',
      projectId: 'fake_project',
      messagingSenderId: '123456',
      bucketName: 'fake.appspot.com',
      appId: 'app-123',
    );

    expect(app, isNotNull);
    expect(app.getAuth(), isNotNull);
  });
}
