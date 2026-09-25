import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:test/test.dart';
import '../../helpers/signed_id_token.dart';

String _buildTestToken({required String projectId, required bool mfaVerified}) {
  final payload = <String, dynamic>{
    ...tokenClaims(projectId: projectId),
    'firebase': {
      if (mfaVerified) 'sign_in_second_factor': 'phone',
      'sign_in_provider': 'password',
    },
  };
  return signedToken(claims: payload);
}

void main() {
  group('MFA admin helpers', () {
    late CertificateClient client;
    late FirebaseAuth auth;
    setUp(() {
      client = CertificateClient();
      auth = FirebaseAuth(projectId: 'demo-project', httpClient: client);
    });
    tearDown(() => client.close());
    test('verifyIdTokenMfa reports verified MFA', () async {
      final token = _buildTestToken(
        projectId: 'demo-project',
        mfaVerified: true,
      );

      final result = await auth.verifyIdTokenMfa(token);
      expect(result.isMfaVerified, isTrue);
      expect(result.secondFactor, equals('phone'));
    });

    test('verifyIdTokenMfa reports unverified MFA', () async {
      final token = _buildTestToken(
        projectId: 'demo-project',
        mfaVerified: false,
      );

      final result = await auth.verifyIdTokenMfa(token);
      expect(result.isMfaVerified, isFalse);
      expect(result.secondFactor, isNull);
    });

    test('enforceMfa throws when MFA not verified', () async {
      final token = _buildTestToken(
        projectId: 'demo-project',
        mfaVerified: false,
      );

      await expectLater(
        () => auth.enforceMfa(token),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('User MFA enrollment parsing', () {
    test('User.fromJson sets enrolledFactors and mfaEnabled', () {
      final user = User.fromJson({
        'localId': 'user-123',
        'mfaInfo': [
          {
            'mfaEnrollmentId': 'enroll-123',
            'displayName': 'My phone',
            'phoneInfo': '+1234567890',
            'enrolledAt': '2024-01-01T00:00:00Z',
          },
        ],
      });

      expect(user.enrolledFactors, isNotNull);
      expect(user.enrolledFactors!.length, equals(1));
      expect(user.enrolledFactors!.first.enrollmentId, equals('enroll-123'));
      expect(user.enrolledFactors!.first.factorId, equals('phone'));
      expect(user.mfaEnabled, isTrue);
    });
  });
}
