/// Represents a multi-factor enrollment for a user.
class MultiFactorEnrollment {
  /// The ID of the enrolled factor (e.g., 'phone').
  final String factorId;

  /// The display name of the enrolled factor.
  final String? displayName;

  /// The phone number info of the enrolled factor.
  final String? phoneNumber;

  /// The date the factor was enrolled.
  final DateTime? enrolledAt;

  /// The UID of the enrolled user.
  final String? uid;

  /// Creates a [MultiFactorEnrollment].
  MultiFactorEnrollment({
    required this.factorId,
    this.displayName,
    this.phoneNumber,
    this.enrolledAt,
    this.uid,
  });

  /// Creates a [MultiFactorEnrollment] from a JSON object.
  factory MultiFactorEnrollment.fromJson(Map<String, dynamic> json) {
    return MultiFactorEnrollment(
      factorId: json['factorId'] ?? '',
      displayName: json['displayName'],
      phoneNumber: json['phoneInfo'],
      enrolledAt: json['enrolledAt'] == null
          ? null
          : DateTime.tryParse(json['enrolledAt'].toString()),
      uid: json['uid'],
    );
  }

  /// Converts this [MultiFactorEnrollment] to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'factorId': factorId,
      'displayName': displayName,
      'phoneInfo': phoneNumber,
      'enrolledAt': enrolledAt?.toIso8601String(),
      'uid': uid,
    };
  }
}
