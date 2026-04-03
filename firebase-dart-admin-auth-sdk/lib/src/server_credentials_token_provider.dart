import 'dart:convert';
import 'dart:io';

import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:firebase_dart_admin_auth_sdk/src/access_token_provider.dart';
import 'package:firebase_dart_admin_auth_sdk/src/token_info.dart';
import 'package:googleapis_auth/auth_io.dart' as auth_io;

/// The effective server credential mode used for Firebase admin calls.
enum ServerCredentialMode {
  /// Uses the runtime's effective identity directly.
  direct,

  /// Uses the runtime identity to impersonate a target service account.
  impersonated,
}

/// Resolves keyless server credentials for backend Firebase access.
///
/// Uses application-default credentials first and can optionally impersonate a
/// target Google service account. A local `gcloud auth application-default`
/// fallback is preserved for development environments.
class ServerCredentialsTokenProvider implements AccessTokenProvider {
  static const List<String> _scopes = <String>[
    'https://www.googleapis.com/auth/cloud-platform',
    'https://www.googleapis.com/auth/firebase',
    'https://www.googleapis.com/auth/identitytoolkit',
    'https://www.googleapis.com/auth/datastore',
    'https://www.googleapis.com/auth/firebase.database',
  ];

  /// The target service account to impersonate, when one is required.
  final String? targetServiceAccount;
  final http.Client _client;
  final bool _ownsClient;

  AccessTokenInfo? _cachedToken;

  /// Creates a provider backed by ADC and optional IAM impersonation.
  ServerCredentialsTokenProvider({
    String? targetServiceAccount,
    http.Client? client,
  }) : targetServiceAccount = _normalizeTargetServiceAccount(
         targetServiceAccount,
       ),
       _client = client ?? http.Client(),
       _ownsClient = client == null;

  /// Returns the currently configured credential mode.
  ServerCredentialMode get mode => targetServiceAccount == null
      ? ServerCredentialMode.direct
      : ServerCredentialMode.impersonated;

  @override
  Future<AccessTokenInfo> getAccessToken() async {
    if (_cachedToken != null && !_cachedToken!.isExpired) {
      return _cachedToken!;
    }

    final sourceToken = await _getSourceAccessToken();
    if (mode == ServerCredentialMode.direct) {
      _cachedToken = sourceToken;
      return sourceToken;
    }

    final impersonatedToken = await _impersonateServiceAccount(
      sourceToken.accessToken,
    );
    _cachedToken = impersonatedToken;
    return impersonatedToken;
  }

  /// Closes any owned HTTP resources.
  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Future<AccessTokenInfo> _getSourceAccessToken() async {
    try {
      final authClient = await auth_io.clientViaApplicationDefaultCredentials(
        scopes: _scopes,
      );
      try {
        final token = authClient.credentials.accessToken;
        return AccessTokenInfo(token.data, token.expiry.toUtc());
      } finally {
        authClient.close();
      }
    } catch (_) {
      return _getAccessTokenFromGcloud();
    }
  }

  Future<AccessTokenInfo> _impersonateServiceAccount(
    String sourceAccessToken,
  ) async {
    final target = targetServiceAccount;
    if (target == null || target.isEmpty) {
      throw StateError(
        'Target service account email is required for impersonated credentials.',
      );
    }

    final response = await _client.post(
      Uri.parse(
        'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/'
        '$target:generateAccessToken',
      ),
      headers: <String, String>{
        'Authorization': 'Bearer $sourceAccessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'scope': _scopes,
        'lifetime': '3600s',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to impersonate service account: '
        '${response.statusCode} ${response.body}',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = payload['accessToken']?.toString();
    final expireTime = payload['expireTime']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception(
        'Impersonation response did not include an access token.',
      );
    }

    return AccessTokenInfo(
      accessToken,
      expireTime == null
          ? DateTime.now().toUtc().add(const Duration(minutes: 55))
          : DateTime.parse(expireTime).toUtc(),
    );
  }

  Future<AccessTokenInfo> _getAccessTokenFromGcloud() async {
    final result = await Process.run(
      'gcloud',
      <String>['auth', 'application-default', 'print-access-token'],
    );

    if (result.exitCode != 0) {
      throw Exception(
        'Unable to resolve server credentials from ADC or gcloud: '
        '${result.stderr}',
      );
    }

    final accessToken = result.stdout.toString().trim();
    if (accessToken.isEmpty) {
      throw Exception('gcloud returned an empty application-default token.');
    }

    return AccessTokenInfo(
      accessToken,
      DateTime.now().toUtc().add(const Duration(minutes: 55)),
    );
  }

  static String? _normalizeTargetServiceAccount(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
