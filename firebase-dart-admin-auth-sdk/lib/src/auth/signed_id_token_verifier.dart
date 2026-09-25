import 'dart:async';
import 'dart:convert';

import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:firebase_dart_admin_auth_sdk/src/project_id_utils.dart';
import 'package:jose/jose.dart';

/// Verifies Firebase ID tokens against Google's pinned signing-key endpoint.
/// Never trusts token-provided keys, URLs, unsigned tokens or decoded claims.
class VerifyIdTokenService {
  /// Owning SDK instance and its configured Firebase project / HTTP client.
  final FirebaseAuth auth;
  final DateTime Function() _clock;
  Map<String, JsonWebKey> _keys = {};
  DateTime? _expiresAt;
  Future<void>? _loadingKeys;

  static final _certificatesUri = Uri.parse(
    'https://www.googleapis.com/robot/v1/metadata/x509/'
    'securetoken@system.gserviceaccount.com',
  );

  /// Creates a verifier with a per-instance signing-key cache.
  VerifyIdTokenService({required this.auth, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// Verifies the signature and required claims before returning user data.
  /// Does not perform a remote account-disabled or token-revocation lookup.
  Future<Map<String, dynamic>> verifyIdToken(String idToken) async {
    try {
      final parts = idToken.split('.');
      if (parts.length != 3 || parts.any((part) => part.isEmpty)) {
        throw const FormatException('Invalid signed token');
      }
      final header = _decode(parts[0]);
      final keyId = header['kid'];
      if (header['alg'] != 'RS256' ||
          keyId is! String ||
          keyId.isEmpty ||
          header.containsKey('crit') ||
          header.containsKey('jwk') ||
          header.containsKey('jku') ||
          header.containsKey('x5u') ||
          header.containsKey('x5c')) {
        throw const FormatException('Invalid signing header');
      }
      await _ensureKeys();
      final key = _keys[keyId];
      if (key == null) throw const FormatException('Unknown signing key');
      final store = JsonWebKeyStore()..addKey(key);
      final signed = JsonWebSignature.fromCompactSerialization(idToken);
      final verified = await signed.getPayload(
        store,
        allowedAlgorithms: ['RS256'],
      );
      final payload = verified.jsonContent;
      if (payload is! Map<String, dynamic>) {
        throw const FormatException('Invalid claims');
      }
      final projectId = normalizeProjectId(auth.projectId);
      if (payload['iss'] != 'https://securetoken.google.com/$projectId' ||
          payload['aud'] != projectId) {
        throw const FormatException('Invalid issuer or audience');
      }
      final now = _clock().millisecondsSinceEpoch ~/ 1000;
      final expiry = payload['exp'];
      final issued = payload['iat'];
      final authenticated = payload['auth_time'];
      if (expiry is! int ||
          issued is! int ||
          authenticated is! int ||
          expiry <= now ||
          issued > now ||
          authenticated > now ||
          issued < 0 ||
          authenticated < 0 ||
          expiry <= issued) {
        throw const FormatException('Invalid token timing');
      }
      final subject = payload['sub'];
      if (subject is! String ||
          subject.isEmpty ||
          subject.length > 128 ||
          (payload.containsKey('user_id') && payload['user_id'] != subject)) {
        throw const FormatException('Invalid subject');
      }
      if (payload['firebase'] is! Map<String, dynamic>) {
        throw const FormatException('Invalid Firebase claims');
      }
      return {
        'uid': subject,
        'email': payload['email'],
        'email_verified': payload['email_verified'] == true,
        'name': payload['name'],
        'picture': payload['picture'],
        'auth_time': authenticated,
        'firebase': payload['firebase'],
        'claims': payload,
      };
    } catch (_) {
      // Never include raw tokens, payloads, upstream bodies or headers in errors.
      throw FirebaseAuthException(
        code: 'token-verification-failed',
        message: 'Firebase ID token could not be verified.',
      );
    }
  }

  Map<String, dynamic> _decode(String part) =>
      jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(part))))
          as Map<String, dynamic>;

  Future<void> _ensureKeys() async {
    if (_expiresAt != null && _clock().isBefore(_expiresAt!)) return;
    final loading = _loadingKeys;
    if (loading != null) return loading;
    final fetch = _fetchKeys();
    _loadingKeys = fetch;
    try {
      await fetch;
    } finally {
      _loadingKeys = null;
    }
  }

  Future<void> _fetchKeys() async {
    final response = await auth.httpClient
        .get(_certificatesUri)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw StateError('Signing keys unavailable');
    }
    final certificates = jsonDecode(response.body);
    if (certificates is! Map<String, dynamic> || certificates.isEmpty) {
      throw const FormatException('Invalid signing keys');
    }
    final keys = <String, JsonWebKey>{};
    for (final entry in certificates.entries) {
      if (entry.value is! String || entry.key.isEmpty) {
        throw const FormatException('Invalid signing certificate');
      }
      final key = JsonWebKey.fromPem(entry.value as String, keyId: entry.key);
      if (key.keyType != 'RSA') throw const FormatException('Invalid key type');
      keys[entry.key] = key;
    }
    final cacheControl = response.headers['cache-control'] ?? '';
    final match = RegExp(r'(?:^|,)\s*max-age=(\d+)').firstMatch(cacheControl);
    final maxAge = int.tryParse(match?.group(1) ?? '') ?? 0;
    final age = int.tryParse(response.headers['age'] ?? '') ?? 0;
    final seconds = (maxAge - age).clamp(0, 21600);
    _keys = keys;
    _expiresAt = _clock().add(
      Duration(
        seconds:
            cacheControl.contains('no-store') ||
                cacheControl.contains('no-cache')
            ? 0
            : seconds,
      ),
    );
  }
}
