/// Represents the result of a multi-factor verification attempt.
class MfaVerificationResult {
  /// Whether the multi-factor authentication was successfully verified.
  final bool isMfaVerified;

  /// The second factor.
  final String? secondFactor;

  /// List of authentication method references.
  final List<String> amr;

  /// The authentication time.
  final int? authTime;

  /// Additional claims.
  final Map<String, dynamic> claims;

  /// Creates a new [MfaVerificationResult] instance.
  MfaVerificationResult({
    required this.isMfaVerified,
    required this.amr,
    required this.claims,
    this.secondFactor,
    this.authTime,
  });
}
