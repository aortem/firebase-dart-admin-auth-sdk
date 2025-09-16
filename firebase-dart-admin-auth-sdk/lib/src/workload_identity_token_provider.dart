import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:firebase_dart_admin_auth_sdk/src/token_info.dart';
import 'package:googleapis_auth/auth_io.dart';

/// Provides OAuth2 access tokens using Workload Identity Federation.
class WorkloadIdentityTokenProvider {
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

  /// Actual retrieval: try metadata server first, then ADC fallback.
  Future<AccessTokenInfo> _fetchToken() async {
    try {
      final token = await _getTokenFromMetadataServer();
      return token;
    } catch (e) {
      stderr.writeln(
        '[WorkloadIdentityTokenProvider] Metadata fetch failed: $e. Falling back to ADC.',
      );
      return await _getTokenFromADC();
    }
  }

  Future<AccessTokenInfo> _getTokenFromMetadataServer() async {
    final uri = Uri.parse(
      'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token',
    );
    final resp = await _client
        .get(uri, headers: {'Metadata-Flavor': 'Google'})
        .timeout(const Duration(seconds: 3));

    if (resp.statusCode != 200) {
      throw Exception('Metadata server token fetch failed: ${resp.body}');
    }
    final body = jsonDecode(resp.body);
    final token = body['access_token'] as String;
    final expiresIn = body['expires_in'] as int? ?? 3600;
    return AccessTokenInfo(
      token,
      DateTime.now().toUtc().add(Duration(seconds: expiresIn)),
    );
  }

  Future<AccessTokenInfo> _getTokenFromADC() async {
    // Requires googleapis_auth in pubspec.yaml
    final client = await clientViaApplicationDefaultCredentials(
      scopes: [
        'https://www.googleapis.com/auth/cloud-platform',
        'https://www.googleapis.com/auth/firebase',
      ],
    );
    try {
      final creds = client.credentials;
      return AccessTokenInfo(
        creds.accessToken.data,
        creds.accessToken.expiry?.toUtc() ??
            DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
    } finally {
      client.close();
    }
  }
}
