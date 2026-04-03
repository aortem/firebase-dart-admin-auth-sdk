import 'package:firebase_dart_admin_auth_sdk/src/token_info.dart';

/// Supplies short-lived OAuth2 access tokens for server-side Firebase calls.
abstract class AccessTokenProvider {
  /// Returns a valid access token, refreshing it when necessary.
  Future<AccessTokenInfo> getAccessToken();
}
