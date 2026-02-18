class MfaVerificationResult {
  final bool isMfaVerified;
  final String? secondFactor;
  final List<String> amr;
  final int? authTime;
  final Map<String, dynamic> claims;

  MfaVerificationResult({
    required this.isMfaVerified,
    required this.amr,
    required this.claims,
    this.secondFactor,
    this.authTime,
  });
}
