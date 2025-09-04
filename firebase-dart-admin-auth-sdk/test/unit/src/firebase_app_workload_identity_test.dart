import 'dart:convert';
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:firebase_dart_admin_auth_sdk/src/firebase_app.dart';
// import 'package:ds_standard_features/ds_standard_features.dart' as http;
import '../../mocks/mock_http.dart' as http;

// If your http package exposes overrides like this, use them.
// Otherwise, swap to your own mock_http.dart helpers.
void main() {
  setUp(() {
    FirebaseApp.resetForTests();
    FirebaseApp.httpClient = http.MockHttpClient(); // 🔥 inject mock
  });
  tearDown(FirebaseApp.resetForTests);

  group('Workload Identity (GKE/Cloud Run)', () {
    test('initializes via metadata server on GCP', () async {
      http.overrideResponses({
        'http://metadata.google.internal': http.MockResponse(200, 'OK'),
        'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token':
            http.MockResponse(
                200,
                jsonEncode(
                    {"access_token": "mock_adc_token", "expires_in": 3600})),
        'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/test-sa@myproj.iam.gserviceaccount.com:generateAccessToken':
            http.MockResponse(
                200, jsonEncode({"accessToken": "impersonated_token"})),
      });

      final app = await FirebaseApp.initializeAppWithWorkloadIdentity(
        targetServiceAccount: 'test-sa@myproj.iam.gserviceaccount.com',
      );

      expect(app.accessToken, 'impersonated_token');
      expect(app.tokenExpiryTime, isNotNull);
    });

    test('throws if not running on GCP', () async {
      http.overrideResponses({
        'http://metadata.google.internal': http.MockResponse(404, 'Not Found'),
      });

      expect(
        () => FirebaseApp.initializeAppWithWorkloadIdentity(
          targetServiceAccount: 'test-sa@myproj.iam.gserviceaccount.com',
        ),
        throwsA(predicate(
            (e) => e.toString().contains('Workload Identity unavailable'))),
      );
    });
  });
}
