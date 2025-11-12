/// Holds an OAuth2 access token and expiry.
class AccessTokenInfo {
  /// The OAuth2 access token string.
  final String accessToken;

  /// The expiry time of the access token.
  final DateTime expiry;

  /// Creates an instance of [AccessTokenInfo].
  AccessTokenInfo(this.accessToken, this.expiry);

  /// Returns true if the token is expired or will expire within 5 minutes.
  bool get isExpired =>
      DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
}
