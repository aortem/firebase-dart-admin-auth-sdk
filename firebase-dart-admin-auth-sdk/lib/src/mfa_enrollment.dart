/// Represents a multi-factor enrollment.
class MultiFactorEnrollment {
  /// The factor ID.
  final String factorId;

  /// The display name.
  final String? displayName;

  /// The phone number.
  final String? phoneNumber;

  /// The enrollment timestamp.
  final DateTime? enrolledAt;

  /// The user ID.
  final String? uid;

  /// Creates a new [MultiFactorEnrollment] instance.
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

  /// Converts the [MultiFactorEnrollment] to a JSON object.
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
