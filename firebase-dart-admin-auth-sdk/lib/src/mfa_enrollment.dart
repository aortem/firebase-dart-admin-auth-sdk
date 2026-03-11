/// Represents a multi-factor enrollment.
class MultiFactorEnrollment {
  /// The factor type (`phone`, `totp`, `email`) when it can be inferred.
  final String factorId;

  /// Firebase enrollment identifier for the factor.
  final String? enrollmentId;

  /// The display name.
  final String? displayName;

  /// The phone number.
  final String? phoneNumber;

  /// Email address for email-based factors.
  final String? emailAddress;

  /// The enrollment timestamp.
  final DateTime? enrolledAt;

  /// The user ID.
  final String? uid;

  /// Creates a new [MultiFactorEnrollment] instance.
  MultiFactorEnrollment({
    required this.factorId,
    this.enrollmentId,
    this.displayName,
    this.phoneNumber,
    this.emailAddress,
    this.enrolledAt,
    this.uid,
  });

  /// Creates a [MultiFactorEnrollment] from a JSON object.
  factory MultiFactorEnrollment.fromJson(Map<String, dynamic> json) {
    final emailInfo = json['emailInfo'];
    return MultiFactorEnrollment(
      factorId:
          json['factorId'] ??
          (json['phoneInfo'] != null
              ? 'phone'
              : json['totpInfo'] != null
              ? 'totp'
              : emailInfo != null
              ? 'email'
              : ''),
      enrollmentId: json['mfaEnrollmentId'],
      displayName: json['displayName'],
      phoneNumber: json['phoneInfo'],
      emailAddress: emailInfo is Map<String, dynamic>
          ? emailInfo['emailAddress']
          : null,
      enrolledAt: json['enrolledAt'] == null
          ? null
          : DateTime.tryParse(json['enrolledAt'].toString()),
      uid: json['uid'],
    );
  }

  /// Converts the [MultiFactorEnrollment] to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'factorId': factorId,
      'mfaEnrollmentId': enrollmentId,
      'displayName': displayName,
      'phoneInfo': phoneNumber,
      if (emailAddress != null) 'emailInfo': {'emailAddress': emailAddress},
      'enrolledAt': enrolledAt?.toIso8601String(),
      'uid': uid,
    };
  }
}
