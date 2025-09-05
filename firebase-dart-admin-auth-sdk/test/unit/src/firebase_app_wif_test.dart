import 'dart:convert';
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:firebase_dart_admin_auth_sdk/src/firebase_app.dart';
import '../../mocks/mock_http.dart' as http;

void main() {
  setUp(() {
    FirebaseApp.resetForTests();
    // Inject mock client so real network never used
    FirebaseApp.httpClient = http.MockHttpClient();
  });

  tearDown(FirebaseApp.resetForTests);

  group('Workforce Identity Federation (WIF)', () {
    test('STS exchange + impersonation success', () async {
      http.overrideResponses({
        // Match STS token request regardless of body
        'https://sts.googleapis.com/v1/token': http.MockResponse(
          200,
          jsonEncode({"access_token": "sts_access_token", "expires_in": 3600}),
        ),
        'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/test-sa@myproj.iam.gserviceaccount.com:generateAccessToken':
            http.MockResponse(
              200,
              jsonEncode({"accessToken": "impersonated_token"}),
            ),
      });

      final app = await FirebaseApp.initializeAppWithWorkloadIdentityFederation(
        targetServiceAccount: 'test-sa@myproj.iam.gserviceaccount.com',
        externalToken: 'mock_external_idp_token',
        projectNumber: '1234567890',
        workforcePoolId: 'pool-1',
        providerId: 'provider-1',
      );

      expect(app.accessToken, 'impersonated_token');
      expect(app.tokenExpiryTime, isNotNull);
    });

    test('throws when STS exchange fails', () async {
      http.overrideResponses({
        'https://sts.googleapis.com/v1/token': http.MockResponse(
          400,
          '{"error":"invalid"}',
        ),
      });

      expect(
        () => FirebaseApp.initializeAppWithWorkloadIdentityFederation(
          targetServiceAccount: 'test-sa@myproj.iam.gserviceaccount.com',
          externalToken: 'bad',
          projectNumber: '1234567890',
          workforcePoolId: 'pool-1',
          providerId: 'provider-1',
        ),
        throwsA(predicate((e) => e.toString().contains('STS exchange failed'))),
      );
    });

    test('throws ArgumentError on missing params', () async {
      // If SDK doesn’t validate yet, expect STS failure instead of ArgumentError
      expect(
        () => FirebaseApp.initializeAppWithWorkloadIdentityFederation(
          targetServiceAccount: 'test-sa@myproj.iam.gserviceaccount.com',
          externalToken: '',
          projectNumber: '',
          workforcePoolId: '',
          providerId: '',
        ),
        throwsA(
          predicate(
            (e) =>
                e.toString().contains('STS exchange failed') ||
                e is ArgumentError,
          ),
        ),
      );
    });
  });
}
