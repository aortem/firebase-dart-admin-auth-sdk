import 'dart:convert';

import 'package:firebase_dart_admin_auth_sdk/src/exceptions.dart';
import 'package:firebase_dart_admin_auth_sdk/src/firebase_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/user.dart';
import 'package:firebase_dart_admin_auth_sdk/src/user_credential.dart';

String _normalizeAuthMessage(String? message, {required String fallback}) {
  final normalized = (message ?? '').trim();
  if (normalized.isEmpty) {
    return fallback;
  }
  return normalized;
}

Future<String?> _resolveAuthAccessToken(FirebaseAuth auth) async {
  if (auth.firebaseApp != null) {
    final token = await auth.firebaseApp!.getValidAccessToken();
    if (token != null && token != auth.accessToken) {
      auth.accessToken = token;
    }
  }
  return auth.accessToken;
}

Uri _buildIdentityToolkitUri(
  FirebaseAuth auth,
  String path, {
  String version = 'v2',
}) {
  final apiKey = (auth.apiKey ?? '').trim();
  return Uri.https(
    'identitytoolkit.googleapis.com',
    '/$version/$path',
    apiKey.isEmpty || apiKey == 'your_api_key' ? null : {'key': apiKey},
  );
}

Future<Map<String, dynamic>> _postJson(
  FirebaseAuth auth,
  String path,
  Map<String, dynamic> body, {
  String version = 'v2',
}) async {
  final token = await _resolveAuthAccessToken(auth);
  final response = await auth.httpClient.post(
    _buildIdentityToolkitUri(auth, path, version: version),
    headers: {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  final decoded = response.body.isEmpty
      ? <String, dynamic>{}
      : Map<String, dynamic>.from(jsonDecode(response.body) as Map);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return decoded;
  }

  final error = decoded['error'];
  final errorMap = error is Map<String, dynamic>
      ? error
      : <String, dynamic>{};
  throw FirebaseAuthException(
    code: _normalizeAuthMessage(
      errorMap['message']?.toString(),
      fallback: 'mfa-request-failed',
    ),
    message: _normalizeAuthMessage(
      errorMap['message']?.toString(),
      fallback: 'Failed to complete multi-factor request.',
    ),
  );
}

/// Attempts to extract an MFA challenge payload from a REST response.
MultiFactorError? tryParseMultiFactorError(
  Map<String, dynamic> responseBody, {
  String? code,
  String? message,
}) {
  Map<String, dynamic>? findPayload(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      if (map['mfaPendingCredential'] != null && map['mfaInfo'] is List) {
        return map;
      }
      for (final entry in map.values) {
        final nested = findPayload(entry);
        if (nested != null) {
          return nested;
        }
      }
    } else if (value is List) {
      for (final entry in value) {
        final nested = findPayload(entry);
        if (nested != null) {
          return nested;
        }
      }
    }
    return null;
  }

  final payload = findPayload(responseBody);
  if (payload == null) {
    return null;
  }
  return MultiFactorError.fromResponse(
    payload,
    code: code,
    message: message,
  );
}

/// Multi-factor authentication service.
class MultiFactorService {
  /// Auth instance.
  final FirebaseAuth auth;

  /// MFA service.
  MultiFactorService({required this.auth});

  /// Builds a resolver from the MFA-required error returned during sign-in.
  Future<MultiFactorResolver> getMultiFactorResolver(
    MultiFactorError error,
  ) async {
    return MultiFactorResolver(
      hints: error.hints,
      session: error.session,
      auth: auth,
    );
  }

  /// Starts enrollment for SMS or TOTP.
  Future<MfaEnrollmentStartResponse> startMfaEnrollment({
    required String idToken,
    String? tenantId,
    StartPhoneMfaEnrollmentInfo? phoneEnrollmentInfo,
    bool totp = false,
  }) async {
    if ((phoneEnrollmentInfo == null && !totp) ||
        (phoneEnrollmentInfo != null && totp)) {
      throw FirebaseAuthException(
        code: 'invalid-mfa-enrollment-request',
        message:
            'Provide either phoneEnrollmentInfo for SMS or set totp=true for TOTP enrollment.',
      );
    }

    final request = <String, dynamic>{
      'idToken': idToken,
      if ((tenantId ?? '').trim().isNotEmpty) 'tenantId': tenantId!.trim(),
      if (phoneEnrollmentInfo != null)
        'phoneEnrollmentInfo': phoneEnrollmentInfo.toJson(),
      if (totp) 'totpEnrollmentInfo': <String, dynamic>{},
    };

    final response = await _postJson(
      auth,
      'accounts/mfaEnrollment:start',
      request,
    );
    return MfaEnrollmentStartResponse.fromJson(response);
  }

  /// Finalizes enrollment for SMS or TOTP.
  Future<MfaEnrollmentFinalizeResponse> finalizeMfaEnrollment({
    required String idToken,
    String? displayName,
    String? tenantId,
    FinalizePhoneMfaEnrollmentInfo? phoneVerificationInfo,
    FinalizeTotpMfaEnrollmentInfo? totpVerificationInfo,
  }) async {
    final hasPhone = phoneVerificationInfo != null;
    final hasTotp = totpVerificationInfo != null;
    if (hasPhone == hasTotp) {
      throw FirebaseAuthException(
        code: 'invalid-mfa-finalize-request',
        message:
            'Provide exactly one verification payload: phoneVerificationInfo or totpVerificationInfo.',
      );
    }

    final request = <String, dynamic>{
      'idToken': idToken,
      if ((displayName ?? '').trim().isNotEmpty)
        'displayName': displayName!.trim(),
      if ((tenantId ?? '').trim().isNotEmpty) 'tenantId': tenantId!.trim(),
      if (phoneVerificationInfo != null)
        'phoneVerificationInfo': phoneVerificationInfo.toJson(),
      if (totpVerificationInfo != null)
        'totpVerificationInfo': totpVerificationInfo.toJson(),
    };

    final response = await _postJson(
      auth,
      'accounts/mfaEnrollment:finalize',
      request,
    );
    return MfaEnrollmentFinalizeResponse.fromJson(response, apiKey: auth.apiKey);
  }
}

/// Resolver returned after a primary sign-in triggers an MFA challenge.
class MultiFactorResolver {
  /// Available enrolled factors the user can satisfy.
  final List<MultiFactorInfo> hints;

  /// MFA pending credential/session.
  final MultiFactorSession session;

  /// Auth instance.
  final FirebaseAuth auth;

  /// Creates a resolver.
  MultiFactorResolver({
    required this.hints,
    required this.session,
    required this.auth,
  });

  /// Starts an SMS challenge for a specific enrolled factor.
  Future<MfaSignInStartResponse> startSignInChallenge({
    required String enrollmentId,
    StartPhoneMfaSignInInfo? phoneSignInInfo,
  }) async {
    final request = <String, dynamic>{
      'mfaPendingCredential': session.pendingCredential,
      'mfaEnrollmentId': enrollmentId,
      if (phoneSignInInfo != null) 'phoneSignInInfo': phoneSignInInfo.toJson(),
    };

    final response = await _postJson(auth, 'accounts/mfaSignIn:start', request);
    return MfaSignInStartResponse.fromJson(response);
  }

  /// Finalizes the MFA challenge and returns a real Firebase sign-in result.
  Future<UserCredential> resolveSignIn(MultiFactorAssertion assertion) async {
    final request = <String, dynamic>{
      'mfaPendingCredential': session.pendingCredential,
      if ((session.tenantId ?? '').trim().isNotEmpty)
        'tenantId': session.tenantId!.trim(),
    };

    switch (assertion.factorId) {
      case 'phone':
        if ((assertion.sessionInfo ?? '').trim().isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-session-info',
            message:
                'Phone MFA resolution requires the sessionInfo returned by startSignInChallenge().',
          );
        }
        request['phoneVerificationInfo'] = {
          'sessionInfo': assertion.sessionInfo!.trim(),
          'code': assertion.secret,
        };
        break;
      case 'totp':
        request['totpVerificationInfo'] = {
          'verificationCode': assertion.secret,
        };
        break;
      default:
        throw FirebaseAuthException(
          code: 'invalid-mfa-assertion',
          message: 'Unsupported MFA assertion factor: ${assertion.factorId}.',
        );
    }

    final response = await _postJson(
      auth,
      'accounts/mfaSignIn:finalize',
      request,
    );

    final user = User.fromJson(response, apiKey: auth.apiKey);
    final userCredential = UserCredential(
      user: user,
      operationType: 'signIn',
      providerId: assertion.factorId,
    );
    auth.updateCurrentUser(user);
    return userCredential;
  }
}

/// Structured MFA challenge error.
class MultiFactorError extends FirebaseAuthException {
  /// Available second-factor hints.
  final List<MultiFactorInfo> hints;

  /// Pending session/pending credential.
  final MultiFactorSession session;

  /// Raw challenge payload from Google Identity Toolkit.
  final Map<String, dynamic> rawResponse;

  /// MFA error.
  MultiFactorError({
    required this.hints,
    required this.session,
    required this.rawResponse,
    super.code = 'multi-factor-auth-required',
    super.message = 'Multi-factor authentication is required to complete sign-in.',
  });

  /// Builds the error from the Identity Toolkit MFA challenge payload.
  factory MultiFactorError.fromResponse(
    Map<String, dynamic> response, {
    String? code,
    String? message,
  }) {
    final rawHints = response['mfaInfo'];
    final hints = rawHints is List
        ? rawHints
              .whereType<Map>()
              .map((entry) => MultiFactorInfo.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
        : <MultiFactorInfo>[];

    return MultiFactorError(
      hints: hints,
      session: MultiFactorSession(
        pendingCredential:
            response['mfaPendingCredential']?.toString().trim() ?? '',
        tenantId: response['tenantId']?.toString(),
      ),
      rawResponse: Map<String, dynamic>.from(response),
      code: _normalizeAuthMessage(
        code,
        fallback: 'multi-factor-auth-required',
      ),
      message: _normalizeAuthMessage(
        message,
        fallback:
            'Second factor required. Use getMultiFactorResolver() to continue the sign-in flow.',
      ),
    );
  }
}

/// Available MFA hint from the challenge payload.
class MultiFactorInfo {
  /// Factor type: `phone`, `totp`, or `email`.
  final String factorId;

  /// Firebase enrollment identifier for the factor.
  final String? enrollmentId;

  /// Optional display name shown to the user.
  final String displayName;

  /// Unobfuscated phone number if this is an SMS factor.
  final String? phoneNumber;

  /// Email address if this is an email-based factor.
  final String? emailAddress;

  /// Hint info.
  MultiFactorInfo({
    required this.factorId,
    required this.displayName,
    this.enrollmentId,
    this.phoneNumber,
    this.emailAddress,
  });

  /// Parses Identity Toolkit hint data.
  factory MultiFactorInfo.fromJson(Map<String, dynamic> json) {
    final factorId = (json['factorId']?.toString().trim().isNotEmpty ?? false)
        ? json['factorId'].toString().trim()
        : json['phoneInfo'] != null
        ? 'phone'
        : json['totpInfo'] != null
        ? 'totp'
        : json['emailInfo'] != null
        ? 'email'
        : 'unknown';

    final displayName = json['displayName']?.toString().trim();
    final phone = json['phoneInfo']?.toString() ??
        json['unobfuscatedPhoneInfo']?.toString();
    final emailInfo = json['emailInfo'];
    final emailAddress = emailInfo is Map<String, dynamic>
        ? emailInfo['emailAddress']?.toString()
        : null;

    return MultiFactorInfo(
      factorId: factorId,
      enrollmentId: json['mfaEnrollmentId']?.toString(),
      displayName:
          (displayName == null || displayName.isEmpty)
          ? (phone ?? emailAddress ?? factorId)
          : displayName,
      phoneNumber: phone,
      emailAddress: emailAddress,
    );
  }
}

/// Pending MFA session.
class MultiFactorSession {
  /// Pending credential returned by Identity Toolkit.
  final String pendingCredential;

  /// Optional tenant ID for multi-tenant flows.
  final String? tenantId;

  /// Session instance.
  MultiFactorSession({required this.pendingCredential, this.tenantId});

  /// Backward-compatible alias used in older sample code.
  String get id => pendingCredential;
}

/// Assertion used to finalize MFA sign-in.
class MultiFactorAssertion {
  /// Factor type: `phone` or `totp`.
  final String factorId;

  /// Verification code.
  final String secret;

  /// SMS challenge session info returned by `startSignInChallenge`.
  final String? sessionInfo;

  /// Generic constructor kept for backward compatibility.
  MultiFactorAssertion({
    required this.factorId,
    required this.secret,
    this.sessionInfo,
  });

  /// Builds a phone assertion from the SMS challenge session and code.
  factory MultiFactorAssertion.phone({
    required String sessionInfo,
    required String verificationCode,
  }) {
    return MultiFactorAssertion(
      factorId: 'phone',
      secret: verificationCode,
      sessionInfo: sessionInfo,
    );
  }

  /// Builds a TOTP assertion from the authenticator code.
  factory MultiFactorAssertion.totp({required String verificationCode}) {
    return MultiFactorAssertion(
      factorId: 'totp',
      secret: verificationCode,
    );
  }
}

/// Request payload for starting SMS factor enrollment.
class StartPhoneMfaEnrollmentInfo {
  /// Phone number to enroll.
  final String phoneNumber;

  /// Optional reCAPTCHA token for browser verification.
  final String? recaptchaToken;

  /// Optional safety net receipt for iOS.
  final String? iosReceipt;

  /// Optional iOS secret.
  final String? iosSecret;

  /// Creates phone enrollment info.
  StartPhoneMfaEnrollmentInfo({
    required this.phoneNumber,
    this.recaptchaToken,
    this.iosReceipt,
    this.iosSecret,
  });

  /// Serializes request JSON.
  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    if ((recaptchaToken ?? '').trim().isNotEmpty)
      'recaptchaToken': recaptchaToken!.trim(),
    if ((iosReceipt ?? '').trim().isNotEmpty) 'iosReceipt': iosReceipt!.trim(),
    if ((iosSecret ?? '').trim().isNotEmpty) 'iosSecret': iosSecret!.trim(),
  };
}

/// Request payload for starting SMS sign-in.
class StartPhoneMfaSignInInfo {
  /// Optional reCAPTCHA token for browser verification.
  final String? recaptchaToken;

  /// Optional safety net receipt for iOS.
  final String? iosReceipt;

  /// Optional iOS secret.
  final String? iosSecret;

  /// Creates phone sign-in info.
  StartPhoneMfaSignInInfo({this.recaptchaToken, this.iosReceipt, this.iosSecret});

  /// Serializes request JSON.
  Map<String, dynamic> toJson() => {
    if ((recaptchaToken ?? '').trim().isNotEmpty)
      'recaptchaToken': recaptchaToken!.trim(),
    if ((iosReceipt ?? '').trim().isNotEmpty) 'iosReceipt': iosReceipt!.trim(),
    if ((iosSecret ?? '').trim().isNotEmpty) 'iosSecret': iosSecret!.trim(),
  };
}

/// Response returned when MFA enrollment is started.
class MfaEnrollmentStartResponse {
  /// SMS session info for phone enrollment.
  final String? sessionInfo;

  /// TOTP secret/session for authenticator app enrollment.
  final String? totpSessionInfo;

  /// Raw response payload.
  final Map<String, dynamic> rawResponse;

  /// Enrollment start response.
  const MfaEnrollmentStartResponse({
    this.sessionInfo,
    this.totpSessionInfo,
    required this.rawResponse,
  });

  /// Parses response JSON.
  factory MfaEnrollmentStartResponse.fromJson(Map<String, dynamic> json) {
    final phoneInfo = json['phoneSessionInfo'];
    final totpInfo = json['totpSessionInfo'];
    return MfaEnrollmentStartResponse(
      sessionInfo: phoneInfo is Map<String, dynamic>
          ? phoneInfo['sessionInfo']?.toString()
          : null,
      totpSessionInfo: totpInfo is Map<String, dynamic>
          ? totpInfo['sessionInfo']?.toString()
          : null,
      rawResponse: Map<String, dynamic>.from(json),
    );
  }
}

/// Response returned when MFA sign-in SMS challenge is started.
class MfaSignInStartResponse {
  /// SMS session info required to finalize the sign-in.
  final String? sessionInfo;

  /// Raw response payload.
  final Map<String, dynamic> rawResponse;

  /// Sign-in start response.
  const MfaSignInStartResponse({this.sessionInfo, required this.rawResponse});

  /// Parses response JSON.
  factory MfaSignInStartResponse.fromJson(Map<String, dynamic> json) {
    final phoneInfo = json['phoneResponseInfo'];
    return MfaSignInStartResponse(
      sessionInfo: phoneInfo is Map<String, dynamic>
          ? phoneInfo['sessionInfo']?.toString()
          : null,
      rawResponse: Map<String, dynamic>.from(json),
    );
  }
}

/// Payload used to finalize phone enrollment.
class FinalizePhoneMfaEnrollmentInfo {
  /// Session returned by `startMfaEnrollment`.
  final String sessionInfo;

  /// SMS code sent to the phone number.
  final String code;

  /// Finalizes phone enrollment.
  const FinalizePhoneMfaEnrollmentInfo({
    required this.sessionInfo,
    required this.code,
  });

  /// Serializes JSON.
  Map<String, dynamic> toJson() => {
    'sessionInfo': sessionInfo,
    'code': code,
  };
}

/// Payload used to finalize TOTP enrollment.
class FinalizeTotpMfaEnrollmentInfo {
  /// Session returned by `startMfaEnrollment`.
  final String sessionInfo;

  /// Verification code from the authenticator app.
  final String verificationCode;

  /// Finalizes TOTP enrollment.
  const FinalizeTotpMfaEnrollmentInfo({
    required this.sessionInfo,
    required this.verificationCode,
  });

  /// Serializes JSON.
  Map<String, dynamic> toJson() => {
    'sessionInfo': sessionInfo,
    'verificationCode': verificationCode,
  };
}

/// Response returned when enrollment is finalized.
class MfaEnrollmentFinalizeResponse {
  /// Authenticated user.
  final User user;

  /// Optional ID token returned by Firebase.
  final String? idToken;

  /// Optional refresh token returned by Firebase.
  final String? refreshToken;

  /// Raw response payload.
  final Map<String, dynamic> rawResponse;

  /// Finalize response.
  const MfaEnrollmentFinalizeResponse({
    required this.user,
    required this.rawResponse,
    this.idToken,
    this.refreshToken,
  });

  /// Parses response JSON.
  factory MfaEnrollmentFinalizeResponse.fromJson(
    Map<String, dynamic> json, {
    String? apiKey,
  }) {
    return MfaEnrollmentFinalizeResponse(
      user: User.fromJson(json, apiKey: apiKey),
      idToken: json['idToken']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      rawResponse: Map<String, dynamic>.from(json),
    );
  }
}
