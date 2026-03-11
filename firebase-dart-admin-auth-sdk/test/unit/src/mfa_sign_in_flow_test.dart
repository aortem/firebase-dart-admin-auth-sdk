import 'dart:convert';

import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http.dart';

void main() {
  setUp(() => overrideResponses({}));

  group('MFA sign-in flow', () {
    test('email/password sign-in throws a structured MFA challenge error', () async {
      overrideResponses({
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=test-api-key':
            MockResponse(
              200,
              jsonEncode({
                'mfaPendingCredential': 'pending-credential-123',
                'mfaInfo': [
                  {
                    'mfaEnrollmentId': 'phone-enroll-1',
                    'displayName': 'Personal phone',
                    'phoneInfo': '+1555******67',
                  },
                ],
              }),
            ),
      });

      final auth = FirebaseAuth(
        apiKey: 'test-api-key',
        httpClient: MockHttpClient(),
      );

      await expectLater(
        auth.signInWithEmailAndPassword('user@example.com', 'super-secret'),
        throwsA(
          isA<MultiFactorError>()
              .having(
                (error) => error.session.pendingCredential,
                'pendingCredential',
                equals('pending-credential-123'),
              )
              .having(
                (error) => error.hints.first.enrollmentId,
                'enrollmentId',
                equals('phone-enroll-1'),
              ),
        ),
      );
    });

    test('resolver starts phone challenge and finalizes TOTP sign-in', () async {
      overrideResponses({
        'https://identitytoolkit.googleapis.com/v2/accounts/mfaSignIn:start?key=test-api-key':
            MockResponse(
              200,
              jsonEncode({
                'phoneResponseInfo': {'sessionInfo': 'sms-session-123'},
              }),
            ),
        'https://identitytoolkit.googleapis.com/v2/accounts/mfaSignIn:finalize?key=test-api-key':
            MockResponse(
              200,
              jsonEncode({
                'localId': 'user-123',
                'email': 'user@example.com',
                'idToken': 'signed-in-id-token',
                'refreshToken': 'refresh-token',
              }),
            ),
      });

      final auth = FirebaseAuth(
        apiKey: 'test-api-key',
        httpClient: MockHttpClient(),
      );
      final error = MultiFactorError.fromResponse({
        'mfaPendingCredential': 'pending-credential-123',
        'mfaInfo': [
          {
            'mfaEnrollmentId': 'phone-enroll-1',
            'displayName': 'Personal phone',
            'phoneInfo': '+1555******67',
          },
        ],
      });

      final resolver = await auth.getMultiFactorResolver(error);

      final startResponse = await resolver.startSignInChallenge(
        enrollmentId: 'phone-enroll-1',
        phoneSignInInfo: StartPhoneMfaSignInInfo(recaptchaToken: 'captcha'),
      );
      expect(startResponse.sessionInfo, equals('sms-session-123'));

      final signInResult = await resolver.resolveSignIn(
        MultiFactorAssertion.totp(verificationCode: '123456'),
      );

      expect(signInResult.user.uid, equals('user-123'));
      expect(auth.currentUser?.uid, equals('user-123'));
    });
  });
}
