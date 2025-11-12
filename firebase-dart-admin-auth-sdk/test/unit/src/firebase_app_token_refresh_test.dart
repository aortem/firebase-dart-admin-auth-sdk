import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:firebase_dart_admin_auth_sdk/src/firebase_app.dart';
import '../../mocks/mock_token_generators.dart';

const _saJson = '''
{
  "type": "service_account",
  "project_id": "myproj",
  "private_key_id": "abc",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIB...\\n-----END PRIVATE KEY-----\\n",
  "client_email": "test-sa@myproj.iam.gserviceaccount.com",
  "client_id": "123",
  "auth_domain": "myproj.firebaseapp.com",
  "messaging_sender_id": "1234567890",
  "bucket_name": "myproj.appspot.com",
  "app_id": "1:123:web:abc"
}
''';

void main() {
  setUp(FirebaseApp.resetForTests);
  tearDown(FirebaseApp.resetForTests);

  group('Access token refresh', () {
    test('refreshes when token is expired or inside buffer', () async {
      final accessTokenGen = MockAccessTokenGen({
        'access_token': 'fresh_token',
        'expires_in': 3600,
      });
      final customTokenGen = MockCustomTokenGen();

      FirebaseApp.overrideInstanceForTesting(accessTokenGen, customTokenGen);

      final app = await FirebaseApp.initializeAppWithServiceAccount(
        serviceAccountContent: _saJson,
      );

      final initialCalls = accessTokenGen.calls;

      // Force expired
      app.tokenExpiryTime = DateTime.now().subtract(const Duration(seconds: 5));

      final token = await app.getValidAccessToken();

      expect(token, 'fresh_token');
      expect(
        accessTokenGen.calls,
        initialCalls + 1,
        reason: 'Should refresh exactly once after init',
      );
    });

    test('does not refresh when token is still valid', () async {
      final accessTokenGen = MockAccessTokenGen({
        'access_token': 'should_not_be_used',
        'expires_in': 3600,
      });
      final customTokenGen = MockCustomTokenGen();

      FirebaseApp.overrideInstanceForTesting(accessTokenGen, customTokenGen);

      final app = await FirebaseApp.initializeAppWithServiceAccount(
        serviceAccountContent: _saJson,
      );

      final initialCalls = accessTokenGen.calls;

      // Token well in the future → valid
      app.tokenExpiryTime = DateTime.now().add(const Duration(hours: 1));

      final token = await app.getValidAccessToken();

      // Still the same token, and no extra refresh call
      expect(token, isNotEmpty);
      expect(
        accessTokenGen.calls,
        initialCalls,
        reason: 'No refresh should happen when token still valid',
      );
    });

    test('concurrent refresh calls only refresh once', () async {
      final accessTokenGen = MockAccessTokenGen({
        'access_token': 'fresh_once',
        'expires_in': 3600,
      });
      final customTokenGen = MockCustomTokenGen();

      FirebaseApp.overrideInstanceForTesting(accessTokenGen, customTokenGen);

      final app = await FirebaseApp.initializeAppWithServiceAccount(
        serviceAccountContent: _saJson,
      );

      final initialCalls = accessTokenGen.calls;

      app.tokenExpiryTime = DateTime.now().subtract(const Duration(seconds: 1));

      final results = await Future.wait([
        app.getValidAccessToken(),
        app.getValidAccessToken(),
      ]);

      expect(results[0], 'fresh_once');
      expect(results[1], 'fresh_once');
      expect(
        accessTokenGen.calls,
        initialCalls + 1,
        reason: 'Only one refresh should occur after init',
      );
    });
  });
}
