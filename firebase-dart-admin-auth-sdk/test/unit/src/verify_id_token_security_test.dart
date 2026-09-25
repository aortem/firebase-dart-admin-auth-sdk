import 'dart:convert';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:test/test.dart';
import 'package:jose/jose.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/verify_id_token.dart';
import '../../helpers/signed_id_token.dart';

void main() {
  late CertificateClient client;
  late FirebaseAuth auth;
  setUp(() {
    client = CertificateClient();
    auth = FirebaseAuth(projectId: 'demo-project', httpClient: client);
  });
  tearDown(() => client.close());

  test('valid Google-key signature retains normalized user fields', () async {
    final decoded = await auth.verifyIdToken(signedToken());
    expect(decoded['uid'], 'user-123');
    expect(decoded['email_verified'], isTrue);
    expect(client.requests, 1);
  });

  test('payload tampering is rejected', () async {
    final parts = signedToken().split('.');
    parts[1] = base64Url
        .encode(
          utf8.encode(
            jsonEncode({
              ...tokenClaims(),
              'sub': 'other-user',
              'user_id': 'other-user',
            }),
          ),
        )
        .replaceAll('=', '');
    await expectLater(
      auth.verifyIdToken(parts.join('.')),
      throwsA(isA<FirebaseAuthException>()),
    );
  });

  test('attacker key with a trusted kid is rejected', () async {
    final attacker = JsonWebKey.fromJson({
      ...JsonWebKey.generate('RS256', keyBitLength: 2048).toJson(),
      'kid': 'test-key',
    });
    await expectLater(
      auth.verifyIdToken(signedToken(key: attacker)),
      throwsA(isA<FirebaseAuthException>()),
    );
  });

  test('token-provided keys and URLs never become trust sources', () async {
    for (final header in [
      {'jku': 'https://attacker.invalid/keys'},
      {'jwk': testSigningKey.toJson()},
      {'x5u': 'https://attacker.invalid/cert'},
      {
        'x5c': [testCertificate],
      },
    ]) {
      await expectLater(
        auth.verifyIdToken(signedToken(header: header)),
        throwsA(isA<FirebaseAuthException>()),
      );
    }
    expect(client.requests, 0);
  });

  test(
    'unknown key is rejected without accepting an unrelated cached key',
    () async {
      await expectLater(
        auth.verifyIdToken(
          signedToken(
            key: JsonWebKey.fromJson({
              ...testSigningKey.toJson(),
              'kid': 'unknown',
            }),
          ),
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    },
  );

  test('invalid signed claims cannot authenticate', () async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (final override in <Map<String, dynamic>>[
      {'aud': 'other-project'},
      {
        'aud': ['demo-project'],
      },
      {'iss': 'https://securetoken.google.com/other-project'},
      {'sub': ''},
      {'sub': 'x' * 129},
      {'user_id': 'other-user'},
      {'exp': now},
      {'exp': '9999999999'},
      {'iat': now + 60},
      {'iat': null},
      {'auth_time': now + 60},
      {'auth_time': null},
      {'firebase': null},
    ]) {
      await expectLater(
        auth.verifyIdToken(
          signedToken(
            claims: {
              ...tokenClaims(now: now),
              ...override,
            },
          ),
        ),
        throwsA(isA<FirebaseAuthException>()),
        reason: override.keys.join(','),
      );
    }
  });

  test('optional user_id is normalized from the verified subject', () async {
    final claims = tokenClaims()..remove('user_id');
    expect(
      (await auth.verifyIdToken(signedToken(claims: claims)))['uid'],
      'user-123',
    );
  });

  test('concurrent and repeated calls share one cached key fetch', () async {
    final token = signedToken();
    await Future.wait(List.generate(8, (_) => auth.verifyIdToken(token)));
    await auth.verifyIdToken(token);
    expect(client.requests, 1);
  });

  test('expired key cache refreshes and outages fail closed', () async {
    var now = DateTime.now();
    final verifier = VerifyIdTokenService(auth: auth, clock: () => now);
    client.responseHeaders = {'cache-control': 'max-age=60', 'age': '50'};
    final token = signedToken();
    await verifier.verifyIdToken(token);
    now = now.add(const Duration(seconds: 11));
    client.status = 503;
    await expectLater(
      verifier.verifyIdToken(token),
      throwsA(isA<FirebaseAuthException>()),
    );
    expect(client.requests, 2);
    client.status = 200;
    await verifier.verifyIdToken(token);
    expect(client.requests, 3);
  });

  test('malformed upstream keys fail without leaking token contents', () async {
    client.body = '{"test-key":"not a certificate"}';
    final token = signedToken();
    try {
      await auth.verifyIdToken(token);
      fail('Malformed keys must fail verification');
    } on FirebaseAuthException catch (error) {
      expect(error.message, isNot(contains(token)));
      expect(error.message, isNot(contains('not a certificate')));
    }
  });

  test('unsigned claims cannot authenticate a user', () async {
    String encode(Map<String, dynamic> value) =>
        base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final token =
        '${encode({'alg': 'none'})}.${encode({
          'iss': 'https://securetoken.google.com/demo-project',
          'aud': 'demo-project',
          'sub': 'synthetic-user',
          'user_id': 'synthetic-user',
          'exp': now + 3600,
          'iat': now,
          'auth_time': now,
          'email_verified': true,
          'firebase': {'sign_in_provider': 'password'},
        })}.';
    await expectLater(
      FirebaseAuth(projectId: 'demo-project').verifyIdToken(token),
      throwsA(isA<FirebaseAuthException>()),
    );
  });
}
