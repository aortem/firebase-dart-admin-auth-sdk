import 'dart:convert';

import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:test/test.dart';

String _base64UrlEncodeJson(Map<String, dynamic> data) {
  final jsonBytes = utf8.encode(json.encode(data));
  return base64Url.encode(jsonBytes).replaceAll('=', '');
}

String _buildTestToken(String projectId) {
  final header = _base64UrlEncodeJson({'alg': 'none', 'typ': 'JWT'});
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final payload = <String, dynamic>{
    'iss': 'https://securetoken.google.com/$projectId',
    'aud': projectId,
    'exp': now + 3600,
    'sub': 'user-123',
    'user_id': 'user-123',
    'email': 'user@example.com',
    'firebase': {'sign_in_provider': 'google.com'},
  };
  final payloadEncoded = _base64UrlEncodeJson(payload);
  return '$header.$payloadEncoded.';
}

void main() {
  test(
    'verifyIdToken tolerates BOM and trailing whitespace in projectId',
    () async {
      final auth = FirebaseAuth(projectId: '\uFEFFdemo-project\r\n');
      final token = _buildTestToken('demo-project');

      final decoded = await auth.verifyIdToken(token);

      expect(decoded['uid'], equals('user-123'));
      expect(auth.projectId, equals('demo-project'));
    },
  );
}
