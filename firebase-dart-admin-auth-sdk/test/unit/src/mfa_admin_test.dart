// import 'dart:convert';

// import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
// import 'package:test/test.dart';

// String _base64UrlEncodeJson(Map<String, dynamic> data) {
//   final jsonBytes = utf8.encode(json.encode(data));
//   return base64Url.encode(jsonBytes).replaceAll('=', '');
// }

// String _buildTestToken({required String projectId, required bool mfaVerified}) {
//   final header = _base64UrlEncodeJson({'alg': 'none', 'typ': 'JWT'});
//   final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//   final payload = <String, dynamic>{
//     'iss': 'https://securetoken.google.com/$projectId',
//     'aud': projectId,
//     'exp': now + 3600,
//     'sub': 'user-123',
//     'user_id': 'user-123',
//     'auth_time': now,
//     'firebase': {
//       if (mfaVerified) 'sign_in_second_factor': 'phone',
//       'sign_in_provider': 'password',
//     },
//   };
//   final payloadEncoded = _base64UrlEncodeJson(payload);
//   return '$header.$payloadEncoded.'; // Signature is not validated by VerifyIdTokenService.
// }

// void main() {
//   group('MFA admin helpers', () {
//     test('verifyIdTokenMfa reports verified MFA', () async {
//       final auth = FirebaseAuth(projectId: 'demo-project');
//       final token = _buildTestToken(
//         projectId: 'demo-project',
//         mfaVerified: true,
//       );

//       final result = await auth.verifyIdTokenMfa(token);
//       expect(result.isMfaVerified, isTrue);
//       expect(result.secondFactor, equals('phone'));
//     });

//     test('verifyIdTokenMfa reports unverified MFA', () async {
//       final auth = FirebaseAuth(projectId: 'demo-project');
//       final token = _buildTestToken(
//         projectId: 'demo-project',
//         mfaVerified: false,
//       );

//       final result = await auth.verifyIdTokenMfa(token);
//       expect(result.isMfaVerified, isFalse);
//       expect(result.secondFactor, isNull);
//     });

//     test('enforceMfa throws when MFA not verified', () async {
//       final auth = FirebaseAuth(projectId: 'demo-project');
//       final token = _buildTestToken(
//         projectId: 'demo-project',
//         mfaVerified: false,
//       );

//       expect(
//         () => auth.enforceMfa(token),
//         throwsA(isA<FirebaseAuthException>()),
//       );
//     });
//   });

//   group('User MFA enrollment parsing', () {
//     test('User.fromJson sets enrolledFactors and mfaEnabled', () {
//       final user = User.fromJson({
//         'localId': 'user-123',
//         'mfaInfo': [
//           {
//             'factorId': 'phone',
//             'displayName': 'My phone',
//             'phoneInfo': '+1234567890',
//             'enrolledAt': '2024-01-01T00:00:00Z',
//           },
//         ],
//       });

//       expect(user.enrolledFactors, isNotNull);
//       expect(user.enrolledFactors!.length, equals(1));
//       expect(user.mfaEnabled, isTrue);
//     });
//   });
// }
