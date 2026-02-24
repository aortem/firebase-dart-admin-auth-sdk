// import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
// import 'package:firebase_dart_admin_auth_sdk/src/http_response.dart';
// //import 'package:test/test.dart';

// class _FakeAuth extends FirebaseAuth {
//   final Map<String, dynamic> responseBody;

//   _FakeAuth(this.responseBody) : super(projectId: 'demo-project');

//   @override
//   Future<HttpResponse> performRequest(
//     String endpoint,
//     Map<String, dynamic> body,
//   ) async {
//     return HttpResponse(statusCode: 200, body: responseBody);
//   }
// }

// void main() {
//   group('getMfaEnrollments', () {
//     test('returns enrollments from lookup response', () async {
//       final auth = _FakeAuth({
//         'users': [
//           {
//             'mfaInfo': [
//               {
//                 'factorId': 'phone',
//                 'displayName': 'My phone',
//                 'phoneInfo': '+1234567890',
//                 'enrolledAt': '2024-01-01T00:00:00Z',
//               },
//             ],
//           },
//         ],
//       });

//       final enrollments = await auth.getMfaEnrollments(uid: 'user-123');
//       expect(enrollments.length, equals(1));
//       expect(enrollments.first.factorId, equals('phone'));
//       expect(enrollments.first.displayName, equals('My phone'));
//     });

//     test('returns empty list when mfaInfo is missing', () async {
//       final auth = _FakeAuth({
//         'users': [{}],
//       });
//       final enrollments = await auth.getMfaEnrollments(uid: 'user-123');
//       expect(enrollments, isEmpty);
//     });

//     test('validates uid/idToken arguments', () async {
//       final auth = _FakeAuth({'users': []});

//       expect(
//         () => auth.getMfaEnrollments(),
//         throwsA(isA<FirebaseAuthException>()),
//       );
//       expect(
//         () => auth.getMfaEnrollments(uid: 'u', idToken: 't'),
//         throwsA(isA<FirebaseAuthException>()),
//       );
//     });

//     test('isMfaEnrolled reflects enrollment state', () async {
//       final auth = _FakeAuth({
//         'users': [
//           {
//             'mfaInfo': [
//               {'factorId': 'phone'},
//             ],
//           },
//         ],
//       });

//       final enrolled = await auth.isMfaEnrolled(uid: 'user-123');
//       expect(enrolled, isTrue);
//     });
//   });
// }
