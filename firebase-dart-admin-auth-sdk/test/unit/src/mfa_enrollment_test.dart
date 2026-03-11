import 'dart:convert';

import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:firebase_dart_admin_auth_sdk/src/http_response.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http.dart';

class _FakeAuth extends FirebaseAuth {
  final Map<String, dynamic> responseBody;

  _FakeAuth(this.responseBody) : super(projectId: 'demo-project');

  @override
  Future<HttpResponse> performRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return HttpResponse(statusCode: 200, body: responseBody);
  }
}

void main() {
  setUp(() => overrideResponses({}));

  group('getMfaEnrollments', () {
    test('returns enrollments from lookup response', () async {
      final auth = _FakeAuth({
        'users': [
          {
            'mfaInfo': [
              {
                'mfaEnrollmentId': 'enroll-123',
                'displayName': 'My phone',
                'phoneInfo': '+1234567890',
                'enrolledAt': '2024-01-01T00:00:00Z',
              },
            ],
          },
        ],
      });

      final enrollments = await auth.getMfaEnrollments(uid: 'user-123');
      expect(enrollments.length, equals(1));
      expect(enrollments.first.enrollmentId, equals('enroll-123'));
      expect(enrollments.first.factorId, equals('phone'));
      expect(enrollments.first.displayName, equals('My phone'));
    });

    test('returns empty list when mfaInfo is missing', () async {
      final auth = _FakeAuth({
        'users': [{}],
      });
      final enrollments = await auth.getMfaEnrollments(uid: 'user-123');
      expect(enrollments, isEmpty);
    });

    test('validates uid/idToken arguments', () async {
      final auth = _FakeAuth({'users': []});

      expect(
        () => auth.getMfaEnrollments(),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(
        () => auth.getMfaEnrollments(uid: 'u', idToken: 't'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('MFA enrollment REST wrappers', () {
    test('starts phone enrollment through Identity Toolkit v2', () async {
      overrideResponses({
        'https://identitytoolkit.googleapis.com/v2/accounts/mfaEnrollment:start?key=test-api-key':
            MockResponse(
              200,
              jsonEncode({
                'phoneSessionInfo': {'sessionInfo': 'phone-session-123'},
              }),
            ),
      });

      final auth = FirebaseAuth(
        apiKey: 'test-api-key',
        httpClient: MockHttpClient(),
      );

      final response = await auth.startMfaEnrollment(
        idToken: 'id-token',
        phoneEnrollmentInfo: StartPhoneMfaEnrollmentInfo(
          phoneNumber: '+15551234567',
        ),
      );

      expect(response.sessionInfo, equals('phone-session-123'));
    });

    test('finalizes totp enrollment through Identity Toolkit v2', () async {
      overrideResponses({
        'https://identitytoolkit.googleapis.com/v2/accounts/mfaEnrollment:finalize?key=test-api-key':
            MockResponse(
              200,
              jsonEncode({
                'localId': 'user-123',
                'email': 'user@example.com',
                'idToken': 'new-id-token',
                'refreshToken': 'new-refresh-token',
                'mfaInfo': [
                  {
                    'mfaEnrollmentId': 'totp-enroll-1',
                    'displayName': 'Authenticator',
                    'totpInfo': {},
                  },
                ],
              }),
            ),
      });

      final auth = FirebaseAuth(
        apiKey: 'test-api-key',
        httpClient: MockHttpClient(),
      );

      final response = await auth.finalizeMfaEnrollment(
        idToken: 'id-token',
        displayName: 'Authenticator',
        totpVerificationInfo: const FinalizeTotpMfaEnrollmentInfo(
          sessionInfo: 'totp-session-123',
          verificationCode: '123456',
        ),
      );

      expect(response.user.uid, equals('user-123'));
      expect(response.user.enrolledFactors, isNotNull);
      expect(
        response.user.enrolledFactors!.first.enrollmentId,
        equals('totp-enroll-1'),
      );
      expect(response.user.enrolledFactors!.first.factorId, equals('totp'));
    });
  });
}
