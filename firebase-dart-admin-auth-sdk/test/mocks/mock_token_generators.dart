import 'dart:async';
import 'package:firebase_dart_admin_auth_sdk/src/auth/get_access_token_with_generated_token.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/generate_custom_token.dart';
import 'package:firebase_dart_admin_auth_sdk/src/service_account.dart';
import 'package:jwt_generator/src/token.dart';

class MockAccessTokenGen implements GetAccessTokenWithGeneratedToken {
  int calls = 0;
  final Map<String, dynamic> nextResponse;

  MockAccessTokenGen(this.nextResponse);

  @override
  Future<Map<String, dynamic>> getAccessTokenWithGeneratedTokenResponse(
    String jwt, {
    String? targetServiceAccountEmail,
  }) async {
    calls++;
    return nextResponse;
  }

  @override
  Future<String> getAccessTokenWithGeneratedToken(
    String jwt, {
    String? targetServiceAccountEmail,
  }) async {
    calls++;
    return (nextResponse['access_token'] as String?) ?? '';
  }
}

class MockCustomTokenGen implements GenerateCustomToken {
  @override
  Future<String> generateServiceAccountJwt(
    ServiceAccount serviceAccount, {
    String? impersonatedEmail,
  }) async {
    // Any constant is fine; we stub downstream anyway.
    return 'mock-jwt';
  }

  @override
  Future<String> generateCustomToken(FcmTokenDto fcmToken, String privateKey) {
    // TODO: implement generateCustomToken
    throw UnimplementedError();
  }

  @override
  Future<String> generateSignInJwt(ServiceAccount serviceAccount,
      {String? uid, Map<String, dynamic>? additionalClaims}) {
    // TODO: implement generateSignInJwt
    throw UnimplementedError();
  }
}
