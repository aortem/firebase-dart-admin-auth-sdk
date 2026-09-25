// Synthetic local signing material; never used with a Firebase project.
// ignore_for_file: public_member_api_docs
import 'dart:convert';
import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:jose/jose.dart';
import 'package:x509/x509.dart' as x509;
import 'package:asn1lib/asn1lib.dart';

final testSigningKey = JsonWebKey.fromJson({
  ...JsonWebKey.generate('RS256', keyBitLength: 2048).toJson(),
  'kid': 'test-key',
});
final testCertificate = _publicKeyPem();

String _publicKeyPem() {
  final key = testSigningKey.cryptoKeyPair.publicKey! as x509.RsaPublicKey;
  final rsa = ASN1Sequence()
    ..add(ASN1Integer(key.modulus))
    ..add(ASN1Integer(key.exponent));
  final algorithm = ASN1Sequence()
    ..add(ASN1ObjectIdentifier.fromComponentString('1.2.840.113549.1.1.1'))
    ..add(ASN1Null());
  final spki = ASN1Sequence()
    ..add(algorithm)
    ..add(ASN1BitString(rsa.encodedBytes));
  return '-----BEGIN PUBLIC KEY-----\n${base64.encode(spki.encodedBytes)}\n'
      '-----END PUBLIC KEY-----';
}

Map<String, dynamic> tokenClaims({
  String projectId = 'demo-project',
  int? now,
}) {
  now ??= DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return {
    'iss': 'https://securetoken.google.com/$projectId',
    'aud': projectId,
    'sub': 'user-123',
    'user_id': 'user-123',
    'exp': now + 3600,
    'iat': now,
    'auth_time': now,
    'email': 'synthetic@example.invalid',
    'email_verified': true,
    'firebase': {'sign_in_provider': 'password'},
  };
}

String signedToken({
  Map<String, dynamic>? claims,
  Map<String, dynamic> header = const {},
  JsonWebKey? key,
}) {
  final builder = JsonWebSignatureBuilder()
    ..jsonContent = claims ?? tokenClaims()
    ..addRecipient(key ?? testSigningKey, algorithm: 'RS256');
  for (final entry in header.entries) {
    builder.setProtectedHeader(entry.key, entry.value);
  }
  return builder.build().toCompactSerialization();
}

class CertificateClient extends http.BaseClient {
  int requests = 0;
  int status = 200;
  String? body;
  Map<String, String> responseHeaders = {
    'cache-control': 'public, max-age=3600',
  };
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests++;
    if (request.method != 'GET' ||
        request.url.toString() !=
            'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com') {
      throw StateError('Unexpected signing-key request');
    }
    return http.StreamedResponse(
      Stream.value(
        utf8.encode(body ?? jsonEncode({'test-key': testCertificate})),
      ),
      status,
      headers: responseHeaders,
    );
  }
}
