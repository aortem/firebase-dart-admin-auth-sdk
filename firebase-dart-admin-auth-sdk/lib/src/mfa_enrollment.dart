class MultiFactorEnrollment {
  final String factorId;
  final String? displayName;
  final String? phoneNumber;
  final DateTime? enrolledAt;
  final String? uid;

  MultiFactorEnrollment({
    required this.factorId,
    this.displayName,
    this.phoneNumber,
    this.enrolledAt,
    this.uid,
  });

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
