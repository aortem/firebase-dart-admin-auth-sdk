import 'dart:async';
import 'dart:convert';

import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:firebase_dart_admin_auth_sdk/src/access_token_provider.dart';
import 'package:firebase_dart_admin_auth_sdk/src/token_info.dart';

/// Provides OAuth2 access tokens using Workload Identity Federation.
class WorkloadIdentityTokenProvider implements AccessTokenProvider {
  final http.Client _client;

  /// The target service account email.
  final String targetServiceAccount;

  /// The Firebase project ID.
  final String firebaseProjectId;

  AccessTokenInfo? _cachedToken;
  Completer<void>? _refreshing;

  /// Creates an instance of [WorkloadIdentityTokenProvider].
  WorkloadIdentityTokenProvider({
    required this.targetServiceAccount,
    required this.firebaseProjectId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Returns a valid access token, refreshing if needed.
  @override
  Future<AccessTokenInfo> getAccessToken() async {
    if (_cachedToken != null && !_cachedToken!.isExpired) {
      return _cachedToken!;
    }
    if (_refreshing != null) {
      await _refreshing!.future;
      return _cachedToken!;
    }

    _refreshing = Completer<void>();
    try {
      final token = await _fetchToken();
      _cachedToken = token;
      return token;
    } finally {
      _refreshing?.complete();
      _refreshing = null;
    }
  }

  Future<AccessTokenInfo> _fetchToken() async {
    return _getTokenFromMetadataServer();
  }

  Future<AccessTokenInfo> _getTokenFromMetadataServer() async {
    final metadataRoot = await _client
        .get(
          Uri.parse('http://metadata.google.internal'),
          headers: {'Metadata-Flavor': 'Google'},
        )
        .timeout(const Duration(seconds: 3));

    if (metadataRoot.statusCode != 200) {
      throw Exception('Workload Identity unavailable: metadata server not reachable.');
    }

    final tokenResponse = await _client
        .get(
          Uri.parse(
            'http://metadata.google.internal/computeMetadata/v1/instance/'
            'service-accounts/default/token',
          ),
          headers: {'Metadata-Flavor': 'Google'},
        )
        .timeout(const Duration(seconds: 3));

    if (tokenResponse.statusCode != 200) {
      throw Exception(
        'Workload Identity unavailable: metadata token fetch failed: '
        '${tokenResponse.body}',
      );
    }

    final body = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
    final token = body['access_token'] as String;
    final expiresIn = body['expires_in'] as int? ?? 3600;

    final sourceToken = AccessTokenInfo(
      token,
      DateTime.now().toUtc().add(Duration(seconds: expiresIn)),
    );

    if (targetServiceAccount.isEmpty) {
      return sourceToken;
    }

    return _impersonateServiceAccount(sourceToken.accessToken);
  }

  Future<AccessTokenInfo> _impersonateServiceAccount(String sourceAccessToken) async {
    final response = await _client.post(
      Uri.parse(
        'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/'
        '$targetServiceAccount:generateAccessToken',
      ),
      headers: <String, String>{
        'Authorization': 'Bearer $sourceAccessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'scope': <String>[
          'https://www.googleapis.com/auth/cloud-platform',
          'https://www.googleapis.com/auth/firebase',
          'https://www.googleapis.com/auth/identitytoolkit',
          'https://www.googleapis.com/auth/datastore',
          'https://www.googleapis.com/auth/firebase.database',
        ],
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
}
