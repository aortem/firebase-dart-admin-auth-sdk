/// The result of verifying a multi-factor authentication (MFA) challenge.
class MfaVerificationResult {
  /// Whether the MFA factor is verified.
  final bool isMfaVerified;

  /// The second factor used in verification.
  final String? secondFactor;

  /// The authenticated methods references (AMR).
  final List<String> amr;

  /// The authentication time.
  final int? authTime;

  /// The updated custom claims.
  final Map<String, dynamic> claims;

  /// Creates an [MfaVerificationResult].
  MfaVerificationResult({
    required this.isMfaVerified,
    required this.amr,
    required this.claims,
    this.secondFactor,
    this.authTime,
  });
}
