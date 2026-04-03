import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:firebase_dart_admin_auth_sdk/src/http_response.dart';
import 'package:test/test.dart';

class _RecordingAuth extends FirebaseAuth {
  String? lastEndpoint;
  Map<String, dynamic>? lastBody;
  Map<String, dynamic> responseBody = const <String, dynamic>{};

  _RecordingAuth() : super(projectId: 'demo-project');

  @override
  Future<HttpResponse> performRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    lastEndpoint = endpoint;
    lastBody = body;
    return HttpResponse(statusCode: 200, body: responseBody);
  }
}

void main() {
  group('Admin user mutation helpers', () {
    test('deleteUserByUid sends delete request with localId', () async {
      final auth = _RecordingAuth();

      await auth.deleteUserByUid('user-123');

      expect(auth.lastEndpoint, equals('delete'));
      expect(auth.lastBody, equals({'localId': 'user-123'}));
    });

    test('updateUserPasswordByUid sends update request with localId', () async {
      final auth = _RecordingAuth();

      await auth.updateUserPasswordByUid('user-123', 'new-password');

      expect(auth.lastEndpoint, equals('update'));
      expect(auth.lastBody, equals({
        'localId': 'user-123',
        'password': 'new-password',
      }));
    });

    test('deleteUserByUid validates uid', () async {
      final auth = _RecordingAuth();

      await expectLater(
        () => auth.deleteUserByUid('   '),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('updateUserPasswordByUid validates uid and password', () async {
      final auth = _RecordingAuth();

      await expectLater(
        () => auth.updateUserPasswordByUid('', 'new-password'),
        throwsA(isA<FirebaseAuthException>()),
      );
      await expectLater(
        () => auth.updateUserPasswordByUid('user-123', ''),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('getUserByUid sends lookup request with localId list', () async {
      final auth = _RecordingAuth()
        ..responseBody = {
          'users': [
            {
              'localId': 'user-123',
              'email': 'user@example.com',
              'displayName': 'Example User',
            },
          ],
        };

      final user = await auth.getUserByUid('user-123');

      expect(auth.lastEndpoint, equals('lookup'));
      expect(auth.lastBody, equals({
        'localId': ['user-123'],
      }));
      expect(user, isNotNull);
      expect(user!.uid, equals('user-123'));
      expect(user.email, equals('user@example.com'));
      expect(user.displayName, equals('Example User'));
    });

    test('getUserByUid returns null when Firebase returns no users', () async {
      final auth = _RecordingAuth()
        ..responseBody = {
          'users': [],
        };

      final user = await auth.getUserByUid('missing-user');

      expect(user, isNull);
    });

    test('getUserByUid validates uid', () async {
      final auth = _RecordingAuth();

      await expectLater(
        () => auth.getUserByUid('   '),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
}
