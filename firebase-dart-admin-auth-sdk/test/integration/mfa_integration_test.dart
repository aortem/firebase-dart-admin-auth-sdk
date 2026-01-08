import 'dart:convert';
import 'dart:io';

import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:test/test.dart';

String? _skipReason(List<String> missing) {
  if (missing.isEmpty) {
    return null;
  }
  return 'Set env vars: ${missing.join(', ')}';
}

String? _projectIdFromToken(String token) {
  final parts = token.split('.');
  if (parts.length < 2) {
    return null;
  }
  final payload = base64Url.normalize(parts[1]);
  final decoded = utf8.decode(base64Url.decode(payload));
  final data = json.decode(decoded);
  if (data is Map<String, dynamic>) {
    return data['aud']?.toString();
  }
  return null;
}

Future<String?> _fetchEmulatorIdToken({
  required String apiKey,
  required String emulatorHost,
  required String email,
  required String password,
}) async {
  final headers = {'Content-Type': 'application/json'};
  final signUpUri = Uri.parse(
    'http://$emulatorHost/identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
  );
  final signInUri = Uri.parse(
    'http://$emulatorHost/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
  );
  final body = json.encode({
    'email': email,
    'password': password,
    'returnSecureToken': true,
  });

  final signUpResponse = await http.post(
    signUpUri,
    headers: headers,
    body: body,
  );
  if (signUpResponse.statusCode != 200) {
    final errorBody = json.decode(signUpResponse.body);
    final errorMessage = errorBody['error']?['message']?.toString();
    if (errorMessage != 'EMAIL_EXISTS') {
      throw StateError('Emulator signUp failed: $errorMessage');
    }
  }

  final signInResponse = await http.post(
    signInUri,
    headers: headers,
    body: body,
  );
  if (signInResponse.statusCode != 200) {
    final errorBody = json.decode(signInResponse.body);
    final errorMessage = errorBody['error']?['message']?.toString();
    throw StateError('Emulator signIn failed: $errorMessage');
  }

  final data = json.decode(signInResponse.body);
  return data['idToken']?.toString();
}

Future<String?> _resolveIdToken({
  required String? apiKey,
  required String? idToken,
  required String? emulatorHost,
  required String? testEmail,
  required String? testPassword,
}) async {
  final canUseEmulator =
      apiKey != null &&
      emulatorHost != null &&
      testEmail != null &&
      testPassword != null;

  if (canUseEmulator) {
    return _fetchEmulatorIdToken(
      apiKey: apiKey,
      emulatorHost: emulatorHost,
      email: testEmail,
      password: testPassword,
    );
  }

  if (idToken != null && idToken.isNotEmpty) {
    return idToken;
  }

  return null;
}

void main() {
  final apiKey = Platform.environment['FIREBASE_API_KEY'];
  final projectId = Platform.environment['FIREBASE_PROJECT_ID'];
  final idToken = Platform.environment['FIREBASE_ID_TOKEN'];
  final emulatorHost = Platform.environment['FIREBASE_AUTH_EMULATOR_HOST'];
  final testEmail = Platform.environment['FIREBASE_TEST_EMAIL'];
  final testPassword = Platform.environment['FIREBASE_TEST_PASSWORD'];
  final allowEmulatorLookup =
      Platform.environment['FIREBASE_ALLOW_EMULATOR_LOOKUP'] == 'true';

  final canUseEmulatorLogin =
      emulatorHost != null && testEmail != null && testPassword != null;
  final missing = <String>[
    if (apiKey == null) 'FIREBASE_API_KEY',
    if (idToken == null && !canUseEmulatorLogin)
      'FIREBASE_ID_TOKEN or FIREBASE_TEST_EMAIL/FIREBASE_TEST_PASSWORD',
  ];

  final skip = _skipReason(missing);

  test(
    'getMfaEnrollments works against Firebase (live or emulator)',
    () async {
      if (emulatorHost != null &&
          emulatorHost.isNotEmpty &&
          !allowEmulatorLookup) {
        return;
      }
      final resolvedToken = await _resolveIdToken(
        apiKey: apiKey,
        idToken: idToken,
        emulatorHost: emulatorHost,
        testEmail: testEmail,
        testPassword: testPassword,
      );
      expect(resolvedToken, isNotNull);
      final effectiveProjectId =
          projectId ?? _projectIdFromToken(resolvedToken!);
      expect(effectiveProjectId, isNotNull);

      final auth = FirebaseAuth(apiKey: apiKey, projectId: effectiveProjectId);
      if (emulatorHost != null && emulatorHost.isNotEmpty) {
        auth.setEmulatorUrl('http://$emulatorHost');
      }

      final enrollments = await auth.getMfaEnrollments(idToken: resolvedToken);
      expect(enrollments, isNotNull);
    },
    skip:
        skip ??
        ((emulatorHost != null &&
                emulatorHost.isNotEmpty &&
                !allowEmulatorLookup)
            ? 'Set FIREBASE_ALLOW_EMULATOR_LOOKUP=true to run emulator lookup.'
            : null),
  );

  test('verifyIdTokenMfa parses MFA claims from a real token', () async {
    final resolvedToken = await _resolveIdToken(
      apiKey: apiKey,
      idToken: idToken,
      emulatorHost: emulatorHost,
      testEmail: testEmail,
      testPassword: testPassword,
    );
    expect(resolvedToken, isNotNull);
    final effectiveProjectId = projectId ?? _projectIdFromToken(resolvedToken!);
    expect(effectiveProjectId, isNotNull);

    final auth = FirebaseAuth(projectId: effectiveProjectId);
    final result = await auth.verifyIdTokenMfa(resolvedToken!);
    expect(result.isMfaVerified, isNotNull);
  }, skip: skip);
}
