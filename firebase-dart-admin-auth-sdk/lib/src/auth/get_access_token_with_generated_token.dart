import 'dart:convert';
import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:firebase_dart_admin_auth_sdk/src/exceptions.dart';

/// Abstract class defining the method to retrieve an access token using a JWT.
abstract class GetAccessTokenWithGeneratedToken {
  /// Retrieves only the access token string
  Future<String> getAccessTokenWithGeneratedToken(
    String jwt, {
    String? targetServiceAccountEmail,
  });

  /// ✅ New method: retrieves full response (token + expiry)
  Future<Map<String, dynamic>> getAccessTokenWithGeneratedTokenResponse(
    String jwt, {
    String? targetServiceAccountEmail,
  });
}

/// Implementation for obtaining an access token using a JWT.
class GetAccessTokenWithGeneratedTokenImplementation
    extends GetAccessTokenWithGeneratedToken {
  @override
  Future<String> getAccessTokenWithGeneratedToken(
    String jwt, {
    String? targetServiceAccountEmail,
  }) async {
    final client = http.Client();
    final response = await client.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': jwt,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['access_token'];
    } else {
      throw FirebaseAuthException(
        code: 'get-access-token-failed',
        message: 'Failed to obtain access token: ${response.body}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getAccessTokenWithGeneratedTokenResponse(
    String jwt, {
    String? targetServiceAccountEmail,
  }) async {
    final client = http.Client();
    final response = await client.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': jwt,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {
        'access_token': responseData['access_token'],
        'expires_in': responseData['expires_in'] ?? 3600,
        'token_type': responseData['token_type'] ?? 'Bearer',
      };
    } else {
      throw FirebaseAuthException(
        code: 'get-access-token-failed',
        message: 'Failed to obtain access token: ${response.body}',
      );
    }
  }
}

/// Implementation for GCP tokens
class GetAccessTokenWithGcpTokenImplementation
    extends GetAccessTokenWithGeneratedToken {
  @override
  Future<String> getAccessTokenWithGeneratedToken(
    String gcpAccessToken, {
    String? targetServiceAccountEmail,
  }) async {
    final client = http.Client();
    final response = await client.post(
      Uri.parse(
        'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$targetServiceAccountEmail:generateAccessToken',
      ),
      headers: {
        'Authorization': 'Bearer $gcpAccessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'scope': ['https://www.googleapis.com/auth/firebase'],
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['accessToken'];
    } else {
      throw FirebaseAuthException(
        code: 'get-access-token-failed',
        message: 'Failed to obtain GCP access token: ${response.body}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getAccessTokenWithGeneratedTokenResponse(
    String gcpAccessToken, {
    String? targetServiceAccountEmail,
  }) async {
    final client = http.Client();
    final response = await client.post(
      Uri.parse(
        'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$targetServiceAccountEmail:generateAccessToken',
      ),
      headers: {
        'Authorization': 'Bearer $gcpAccessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'scope': ['https://www.googleapis.com/auth/firebase'],
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {
        'access_token': responseData['accessToken'],
        'expires_in': responseData['expireTime'] ?? 3600,
        'token_type': 'Bearer',
      };
    } else {
      throw FirebaseAuthException(
        code: 'get-access-token-failed',
        message: 'Failed to obtain GCP access token: ${response.body}',
      );
    }
  }
}
