// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/apple_sign_in_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/apply_action_code.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/custom_token_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/email_link_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/email_password_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/gcp_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/generate_custom_token.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/get_additional_user_info.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/link_provider_to_user.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/oauth_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/phone_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/reload_user.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/send_email_verification_code.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/set_language_code.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/sign_out_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/unlink_provider.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/update_current_user.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/update_password.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/update_profile.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/user_device_language.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/verify_before_email_update.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/verify_password_reset_code.dart';
import 'package:firebase_dart_admin_auth_sdk/src/firebase_user/link_with_credentails.dart';
import 'package:firebase_dart_admin_auth_sdk/src/http_response.dart';
import 'package:firebase_dart_admin_auth_sdk/src/platform_resolver.dart';
import 'package:firebase_dart_admin_auth_sdk/src/popup_redirect_resolver.dart';
import 'package:firebase_dart_admin_auth_sdk/src/service_account.dart';

// New imports for Sprint 2 #16 to #21
import 'package:firebase_dart_admin_auth_sdk/src/auth/password_reset_email.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/revoke_access_token.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/id_token_changed.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/auth_state_changed.dart';

import 'package:firebase_dart_admin_auth_sdk/src/auth/fetch_sign_in_methods.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/create_user_with_email_and_password.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/connect_auth_emulator.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/get_redirect_result.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/recaptcha_config.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/confirm_password_reset.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/get_multi_factor.dart'
    as multi_factor;

import 'auth/before_auth_state_change.dart';
import 'auth/set_persistence.dart';
import 'auth/sign_in_anonymously.dart';
import 'firebase_user/get_language_code.dart';

import 'firebase_user/delete_user.dart';

import 'auth/parse_action_code_url.dart';

import 'firebase_user/set_language_code.dart';
import 'id_token_result_model.dart';
import 'auth/verify_id_token.dart';

/// Enum to specify the type of API request.
enum ApiType {
  /// Admin API request (requires service account / elevated privileges)
  admin,

  /// Client API request (normal Firebase client endpoints)
  client,
}

///Base Firebase auth class that contains all the methods provided by the sdk
class FirebaseAuth {
  ///THe api key for firebase project
  final String? apiKey;

  ///The project id for your firebase project
  final String? projectId;

  ///The access token to the firebase project
  final String? authDomain;

  ///The access token to the firebase project
  final String? messagingSenderId;

  ///The access token to the firebase project
  final String? appId;

  /// The access token to the firebase project
  String? accessToken;

  /// The service account of your firebase project
  final ServiceAccount? serviceAccount;

  /// The generated custom token
  final GenerateCustomToken? generateCustomToken;

  /// Local httpClient
  late http.Client httpClient;

  ///Projects bucket name
  final String? bucketName;

  /// For performing email and password auth
  late EmailPasswordAuth emailPassword;

  /// For generating customToken
  late CustomTokenAuth customToken;

  /// For sending email Link
  late EmailLinkAuth emailLink;

  /// For performing auth operations pertaing to phone
  late PhoneAuth phone;

  /// For performing auth operations pertaining to external authenticators
  late OAuthAuth oauth;

  ///sign out
  late FirebaseSignOut signOUt;

  ///redirect
  late SignInWithRedirectService signInRedirect;

  /// Update current User
  late UpdateCurrentUser updateUserService;

  /// Use the language of the device
  late UseDeviceLanguageService useDeviceLanguage;

  /// Verify password reset
  late VerifyPasswordResetCodeService verifyPasswordReset;

  /// Apply Action code
  late ApplyActionCode applyAction;

  late ReloadUser _reloadUser;
  late SendEmailVerificationCode _sendEmailVerificationCode;
  late SetLanguageCode _setLanguageCode;
  late UnlinkProvider _unlinkProvider;
  late UpdatePassword _updatePassword;

  // New service declarations for Sprint 2 #16 to #21
  /// Send Password reset email
  late PasswordResetEmailService passwordResetEmail;

  /// revoke access token
  late RevokeAccessTokenService revokeAccessTokenService;
  late OnIdTokenChangedService _onIdTokenChangedService;
  late OnAuthStateChangedService _onAuthStateChangedService;
  late AppleSignInAuth _appleAuth;
  late GCPAuth _gcpAuth;

  /// fetch sign in methods
  late FetchSignInMethodsService fetchSignInMethods;

  /// email password
  late CreateUserWithEmailAndPasswordService
  createUserWithEmailAndPasswordService;

  ///connect auth Emulator
  late ConnectAuthEmulatorService connectAuthEmulatorService;

  /// GetMultiFactor getMultiFactor;
  late GetRedirectResultService getRedirectResultService;

  /// FetchSignInMethodsService fetchSignInMethodsService;
  late final RecaptchaConfigService recaptchaConfigService;
  ////confirm password
  late ConfirmPasswordResetService confirmPasswordResetService;

  ///check action code
  late CheckActionCodeService checkActionCodeService;

  /// multi-factor
  late final multi_factor.MultiFactorService multiFactorService;
  late final RecaptchaVerifier _recaptchaVerifier;
  late final PopupRedirectResolver _popupRedirectResolver;
  late final RecaptchaConfigService _recaptchaConfigService;
  ////Ticket mo 36 to 41///////////////
  late FirebasePhoneNumberLink firebasePhoneNumberLink;

  /// Parase firebase url link
  late FirebaseParseUrlLink firebaseParseUrlLink;

  /// Delete User
  late FirebaseDeleteUser firebaseDeleteUser;

  ///link credential
  late LinkWithCredientialClass linkWithCredientialClass;

  late GetAdditionalUserInfo _getAdditionalUserInfo;
  late LinkProviderToUser _linkProviderToUser;
  late UpdateProfile _updateProfile;
  late VerifyBeforeEmailUpdate _verifyBeforeEmailUpdate;

  //Ticketr 5,7,23,24,61
  ///Sign in anonymously
  late FirebaseSignInAnonymously signInAnonymously;

  /// Set persistence
  late PersistenceService setPresistence;

  /// Set language code
  late LanguageService setLanguageService;

  /// Get firebase language code
  late LanguageGetService getLanguageService;

  /// Firebase before auth change
  late FirebaseBeforeAuthStateChangeService
  firebaseBeforeAuthStateChangeService;

  /// Current firebase auth user
  User? currentUser;

  /// StreamControllers for managing auth state
  final StreamController<User?> authStateChangedController =
      StreamController<User?>.broadcast();

  /// Stream Controller for manageing id token change events
  final StreamController<User?> idTokenChangedController =
      StreamController<User?>.broadcast();

  /// Service for verifying ID tokens
  late VerifyIdTokenService verifyTokenService;

  /// ✅ new reference to parent
  final FirebaseApp? firebaseApp; // ✅ new reference to parent
  /// Firebae Auth constructor class
  FirebaseAuth({
    this.apiKey,
    this.projectId,
    this.authDomain,
    this.messagingSenderId,
    http.Client? httpClient, // Add this parameter
    this.bucketName,
    this.appId,
    this.accessToken,
    this.serviceAccount,
    this.generateCustomToken,
    this.firebaseApp,
  }) {
    log(apiKey ?? 'api key');
    this.httpClient =
        httpClient ??
        http.Client(); // Use the injected client or default to a new one
    emailPassword = EmailPasswordAuth(this);
    customToken = CustomTokenAuth(this);
    emailLink = EmailLinkAuth(this);
    phone = PhoneAuth(this);
    oauth = OAuthAuth(this);
    signOUt = FirebaseSignOut();
    signInRedirect = SignInWithRedirectService(auth: this);
    updateUserService = UpdateCurrentUser(auth: this);
    useDeviceLanguage = UseDeviceLanguageService(auth: this);
    verifyPasswordReset = VerifyPasswordResetCodeService(auth: this);

    _reloadUser = ReloadUser(auth: this);
    _sendEmailVerificationCode = SendEmailVerificationCode(auth: this);
    _setLanguageCode = SetLanguageCode(auth: this);
    _unlinkProvider = UnlinkProvider(auth: this);
    _updatePassword = UpdatePassword(auth: this);

    // New service initializations for Sprint 2 #16 to #21
    passwordResetEmail = PasswordResetEmailService(auth: this);
    revokeAccessTokenService = RevokeAccessTokenService(auth: this);
    _onIdTokenChangedService = OnIdTokenChangedService(this);
    _onAuthStateChangedService = OnAuthStateChangedService(this);
    applyAction = ApplyActionCode(this);
    _appleAuth = AppleSignInAuth(this);
    _gcpAuth = GCPAuth(this);
    _recaptchaVerifier = createRecaptchaVerifier(appId ?? '');
    _popupRedirectResolver = createPopupRedirectResolver();
    _recaptchaConfigService = createRecaptchaConfigService();
    fetchSignInMethods = FetchSignInMethodsService(auth: this);
    createUserWithEmailAndPasswordService =
        CreateUserWithEmailAndPasswordService(auth: this);
    connectAuthEmulatorService = ConnectAuthEmulatorService(this);
    getRedirectResultService = GetRedirectResultService(auth: this);
    // recaptchaConfigService = RecaptchaConfigService();
    confirmPasswordResetService = ConfirmPasswordResetService(auth: this);
    checkActionCodeService = CheckActionCodeService(auth: this);
    multiFactorService = multi_factor.MultiFactorService(auth: this);
    firebasePhoneNumberLink = FirebasePhoneNumberLink(this);
    firebaseParseUrlLink = FirebaseParseUrlLink(auth: this);
    firebaseDeleteUser = FirebaseDeleteUser(auth: this);
    linkWithCredientialClass = LinkWithCredientialClass(auth: this);

    _getAdditionalUserInfo = GetAdditionalUserInfo(auth: this);
    _linkProviderToUser = LinkProviderToUser(auth: this);
    _updateProfile = UpdateProfile(this);
    _verifyBeforeEmailUpdate = VerifyBeforeEmailUpdate(this);
    signInAnonymously = FirebaseSignInAnonymously(this);
    setPresistence = PersistenceService(auth: this);
    setLanguageService = LanguageService(auth: this);
    getLanguageService = LanguageGetService(auth: this);
    firebaseBeforeAuthStateChangeService = FirebaseBeforeAuthStateChangeService(
      this,
    );
    verifyTokenService = VerifyIdTokenService(auth: this);
  }

  /// ✅ clean request wrapper with retry + token refresh
  Future<HttpResponse> performRequest(
    String endpoint,
    Map<String, dynamic> body, {
    ApiType? apiType,
  }) async {
    // Ensure we have a fresh access token if firebaseApp/serviceAccount used
    String? currentAccessToken = accessToken;
    if (firebaseApp != null && serviceAccount != null) {
      currentAccessToken = await firebaseApp!.getValidAccessToken();
      if (currentAccessToken != null && currentAccessToken != accessToken) {
        accessToken = currentAccessToken;
      }
    }
    final useAdmin =
        apiType == ApiType.admin ||
        (apiType == null && currentAccessToken != null && firebaseApp != null);
    if (useAdmin) {
      return await _performAdminRequest(endpoint, body, currentAccessToken);
    } else {
      return await _performClientRequest(endpoint, body, currentAccessToken);
    }
  }

  Future<HttpResponse> _performAdminRequest(
    String endpoint,
    Map<String, dynamic> body,
    String? token, {
    int maxRetries = 2,
  }) async {
    if (projectId == null) {
      throw FirebaseAuthException(
        code: 'missing-project-id',
        message: 'projectId is required for Admin API calls',
      );
    }
    final url = Uri.https(
      'firebase.googleapis.com',
      '/v1/projects/$projectId/accounts$endpoint',
    );
    int attempt = 0;
    while (attempt < maxRetries) {
      attempt++;
      final resp = await httpClient.post(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      if (resp.statusCode == 401 && firebaseApp != null && attempt == 1) {
        await firebaseApp!.refreshAccessToken();
        token = firebaseApp!.accessToken;
        continue;
      }
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        dynamic decoded;
        try {
          decoded = json.decode(resp.body);
        } catch (_) {
          decoded = null;
        }
        final code = decoded != null && decoded['error'] != null
            ? decoded['error']['message'] ?? 'admin-api-error'
            : 'admin-api-error';
        final message = decoded != null && decoded['error'] != null
            ? decoded['error']['message']
            : resp.body;
        throw FirebaseAuthException(code: code, message: message);
      }
      return HttpResponse(
        statusCode: resp.statusCode,
        body: json.decode(resp.body),
        headers: resp.headers,
      );
    }
    throw FirebaseAuthException(
      code: 'max-retries-exceeded',
      message: 'Admin request failed after $maxRetries attempts',
    );
  }

  Future<HttpResponse> _performClientRequest(
    String endpoint,
    Map<String, dynamic> body,
    String? token, {
    int maxRetries = 2,
  }) async {
    if (apiKey == null || apiKey == 'your_api_key') {
      throw FirebaseAuthException(
        code: 'missing-api-key',
        message: 'API Key is required for client endpoints',
      );
    }
    final url = Uri.https(
      'identitytoolkit.googleapis.com',
      '/v1/accounts:$endpoint',
      {'key': apiKey},
    );
    int attempt = 0;
    while (attempt < maxRetries) {
      attempt++;
      final resp = await httpClient.post(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      if (resp.statusCode != 200) {
        dynamic decoded;
        try {
          decoded = json.decode(resp.body);
        } catch (_) {
          decoded = null;
        }
        final code = decoded != null && decoded['error'] != null
            ? decoded['error']['message'] ?? 'client-api-error'
            : 'client-api-error';
        final message = decoded != null && decoded['error'] != null
            ? decoded['error']['message']
            : resp.body;
        if (resp.statusCode == 401 && firebaseApp != null && attempt == 1) {
          await firebaseApp!.refreshAccessToken();
          token = firebaseApp!.accessToken;
          continue;
        }
        throw FirebaseAuthException(code: code, message: message);
      }
      return HttpResponse(
        statusCode: resp.statusCode,
        body: json.decode(resp.body),
        headers: resp.headers,
      );
    }
    throw FirebaseAuthException(
      code: 'max-retries-exceeded',
      message: 'Client request failed after $maxRetries attempts',
    );
  }

  /// updateCurrentUser method to automatically trigger the streams
  void updateCurrentUser(User user) {
    // Check using the getter instead of private field
    if (user.apiKey == null && apiKey != null) {
      user = User(
        uid: user.uid,
        email: user.email,
        emailVerified: user.emailVerified,
        phoneNumber: user.phoneNumber,
        displayName: user.displayName,
        photoURL: user.photoURL,
        refreshToken: user.refreshToken,
        idToken: user.idToken,
        tenantId: user.tenantId,
        createdAt: user.createdAt,
        customAttributes: user.customAttributes,
        disabled: user.disabled,
        lastLoginAt: user.lastLoginAt,
        passwordUpdatedAt: user.passwordUpdatedAt,
        providerUserInfo: user.providerUserInfo,
        validSince: user.validSince,
        mfaEnabled: user.mfaEnabled,
        apiKey: apiKey,
      );
    }

    currentUser = currentUser == null ? user : currentUser?.copyWith(user);
    authStateChangedController.add(currentUser);
    idTokenChangedController.add(currentUser);
  }

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return emailPassword.signIn(email, password);
  }

  // Future<UserCredential> createUserWithEmailAndPassword(
  //     String email, String password) {
  //   return emailPassword.signUp(email, password);
  // } my assined ticket in issue #11 done down
  // Future<UserCredential?> createUserWithEmailAndPassword(
  //     String email, String password) {
  //   return emailPassword.signUp(email, password);
  // }

  /// Sign in with custom token
  Future<UserCredential> signInWithCustomToken(String? uid) async {
    assert(serviceAccount != null, 'Service Account cannot be null');
    assert(generateCustomToken != null, 'Custom token cannot be null');

    String token = await generateCustomToken!.generateSignInJwt(
      serviceAccount!,
      uid: uid,
    );
    return customToken.signInWithCustomToken(token);
  }

  ///sign in with credentials

  Future<Object?> signInWithCredential(AuthCredential credential) async {
    if (credential is EmailAuthCredential) {
      return signInWithEmailAndPassword(credential.email, credential.password);
    } else if (credential is PhoneAuthCredential) {
      // Use PhoneAuth.confirmCode instead of non-existent signInWithPhoneNumber
      final phoneAuth = PhoneAuth(this);
      return await phoneAuth.confirmCode(
        credential.verificationId, // sessionInfo
        credential.smsCode, // user-entered SMS code
      );
    } else if (credential is OAuthCredential) {
      // Map providerId string to actual AuthProvider instance
      final provider = AuthProvider.fromProviderId(credential.providerId);
      return signInWithPopup(provider, clientId);
    } else {
      throw FirebaseAuthException(
        code: 'unsupported-credential',
        message: 'Unsupported credential type',
      );
    }
  }

  ///client ID
  String clientId = ''; // Add this line to store the clientId

  /// Add a method to set the clientId
  void setClientId(String id) {
    clientId = id;
  }

  /// Sign in with popup
  Future<UserCredential> signInWithPopup(
    AuthProvider provider,
    String clientId,
  ) async {
    try {
      final userCredential = await oauth.signInWithPopup(provider, clientId);
      updateCurrentUser(userCredential.user);
      return userCredential;
    } catch (e) {
      print('Detailed signInWithPopup error: $e');
      throw FirebaseAuthException(
        code: 'popup-sign-in-error',
        message: 'Failed to sign in with popup: ${e.toString()}',
      );
    }
  }

  /// Sign in with phone number
  Future<void> signInWithPhone(
    String phoneNumber,
    ApplicationVerifier appVerifier,
  ) async {
    try {
      // Step 1: send verification code
      final sessionInfo = await phone.sendVerificationCode(
        phoneNumber,
        appVerifier,
      );

      // Step 2: confirm code (UI should collect smsCode from user)
      // final smsCode = await askUserForSmsCode(); // <- your UI logic here
      final user = await phone.confirmCode(sessionInfo, 'smsCode');

      log('[PhoneAuth] Signed in as ${user.uid}');
    } catch (e) {
      throw FirebaseAuthException(
        code: 'phone-auth-error',
        message: 'Failed to sign in with phone number: ${e.toString()}',
      );
    }
  }

  /// Sign in with emaillink
  Future<UserCredential> signInWithEmailLink(String email, String emailLink) {
    return this.emailLink.signInWithEmailLink(email, emailLink);
  }

  /// Sign out
  Future<void> signOut() async {
    log('[FirebaseAuth] SignOut: currentUser=${currentUser?.uid}');

    if (FirebaseApp.instance.getCurrentUser() == null) {
      throw FirebaseAuthException(
        code: 'user-not-signed-in',
        message: 'No user is currently signed in.',
      );
    }

    try {
      await signOUt.signOut();
      FirebaseApp.instance.setCurrentUser(null);
      currentUser = null;
      log('User Signout ');
      return;
    } catch (e) {
      log('Sign-out failed: $e');
      throw FirebaseAuthException(
        code: 'sign-out-error',
        message: 'Failed to sign out user.',
      );
    }
  }

  ///sign in redirect
  Future<UserCredential?> signInWithRedirect(
    String redirectUri,
    String idToken,
    String providerId,
  ) async {
    try {
      return await signInRedirect.signInWithRedirect(
        redirectUri,
        idToken,
        providerId,
      );
    } catch (e) {
      print('Sign-in with redirect failed: $e');
      throw FirebaseAuthException(
        code: 'sign-in-redirect-error',
        message: 'Failed to sign in with redirect.',
      );
    }
  }

  ///update user info

  Future<void> updateUserInformation(
    String userId,
    String idToken,
    Map<String, dynamic> userData,
  ) async {
    try {
      await updateUserService.updateCurrentUser(userId, idToken, userData);
    } catch (e) {
      print('Update current user information failed: $e');
      throw FirebaseAuthException(
        code: 'update-current-user-error',
        message: 'Failed to update current user information.',
      );
    }
  }

  /// Set device language
  Future<void> deviceLanguage(String languageCode) async {
    try {
      if (currentUser?.idToken == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No signed-in user available for this operation',
        );
      }

      await useDeviceLanguage.useDeviceLanguage(
        currentUser!.idToken!,
        languageCode,
      );
    } catch (e) {
      print('Use device language failed: $e');
      throw FirebaseAuthException(
        code: 'use-device-language-error',
        message: 'Failed to set device language.',
      );
    }
  }

  ///verify passwird

  Future<String?> verifyPasswordResetCode(String code) async {
    try {
      return await verifyPasswordReset.verifyPasswordResetCode(code);
    } catch (e) {
      print('Verify password reset code failed: $e');
      throw FirebaseAuthException(
        code: 'verify-password-reset-code-error',
        message: 'Failed to verify password reset code.',
      );
    }
  }

  ///Apply action code
  Future<bool> applyActionCode(String actionCode) {
    return applyAction.applyActionCode(actionCode);
  }

  ///Reload/Refresh user
  Future<User> reloadUser() {
    return _reloadUser.reloadUser(currentUser?.idToken);
  }

  ///Send verification code to user email
  Future<void> sendEmailVerificationCode() {
    return _sendEmailVerificationCode.sendEmailVerificationCode(
      currentUser?.idToken,
    );
  }

  ///Set language code
  Future<User> setLanguageCode(String languageCode) {
    return _setLanguageCode.setLanguageCode(currentUser?.idToken, languageCode);
  }

  /// Unlink a provider
  Future<User> unlinkProvider(String providerId) {
    return _unlinkProvider.unlinkProvider(currentUser?.idToken, providerId);
  }

  /// Update password
  Future<User> updatePassword(String newPassowrd) {
    return _updatePassword.updatePassword(newPassowrd, currentUser?.idToken);
  }

  // New methods with complete functionality Sprint 2 #16 to #21

  /// Sends a password reset email to the specified email address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await passwordResetEmail.sendPasswordResetEmail(email);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'password-reset-error',
        message: 'Failed to send password reset email: ${e.toString()}',
      );
    }
  }

  /// Revokes the specified access token.
  Future<void> revokeToken(String idToken) async {
    try {
      await revokeAccessTokenService.revokeAccessToken();
    } catch (e) {
      throw FirebaseAuthException(
        code: 'revoke-access-token-error',
        message: 'Failed to revoke access token: ${e.toString()}',
      );
    }
  }

  /// Returns a stream of User objects when the ID token changes.
  Stream<User?> onIdTokenChanged() {
    return idTokenChangedController.stream;
  }

  /// Returns a stream of User objects when the auth state changes.
  Stream<User?> onAuthStateChanged() {
    return authStateChangedController.stream;
  }

  /// Checks if the provided URL is a valid sign-in link for email authentication.
  bool isSignInWithEmailLink(String emailLink) {
    return this.emailLink.isSignInWithEmailLink(emailLink);
  }

  /// Sends a sign-in link to the specified email address using the provided ActionCodeSettings.
  Future<void> sendSignInLinkToEmail(
    String email, {
    ActionCodeSettings? actionCode,
  }) {
    return emailLink.sendSignInLinkToEmail(email, actionCode: actionCode);
  }

  ///link account credential

  Future<UserCredential?> linkAccountWithCredientials(
    String redirectUri,
    String idToken,
    String providerId,
  ) async {
    try {
      return await linkWithCredientialClass.linkWithCrediential(
        redirectUri,
        idToken,
        providerId,
      );
    } catch (e) {
      print('Sign-in with redirect failed: $e');
      throw FirebaseAuthException(
        code: 'sign-in-redirect-error',
        message: 'Failed to sign in with redirect.',
      );
    }
  }

  /// Get additonal User info
  Future<User> getAdditionalUserInfo() async {
    return await _getAdditionalUserInfo.getAdditionalUserInfo(
      currentUser?.idToken,
    );
  }

  ///Link provider to user
  Future<bool> linkProviderToUser(
    String providerId,
    String providerIdToken,
  ) async {
    return _linkProviderToUser.linkProviderToUser(
      currentUser?.idToken,
      providerId,
      providerIdToken,
    );
  }

  ///Update profile
  Future<User> updateProfile(String displayName, String displayImage) async {
    return await _updateProfile.updateProfile(
      displayName,
      displayImage,
      currentUser?.idToken,
    );
  }

  ///Verify before email update
  Future<bool> verifyBeforeEmailUpdate(
    String newEmail, {
    ActionCodeSettings? action,
  }) async {
    return await _verifyBeforeEmailUpdate.verifyBeforeEmailUpdate(
      currentUser?.idToken,
      newEmail,
      action: action,
    );
  }

  ///Parse a Firebase action code URL
  Future<dynamic> parseActionCodeUrl(String url) async {
    Uri uri = Uri.parse(url);

    if (uri.queryParameters.isEmpty) {
      return null;
    }

    // Extract query parameters
    String? mode = uri.queryParameters['mode'];
    String? oobCode = uri.queryParameters['oobCode'];
    String? continueUrl = uri.queryParameters['continueUrl'];
    String? lang = uri.queryParameters['lang'];

    if (mode == null || oobCode == null) {
      return null;
    }

    // Return the parsed parameters as a map
    return {
      'mode': mode,
      'oobCode': oobCode,
      'continueUrl': continueUrl ?? '',
      'lang': lang ?? '',
    };
  }

  ///FirebaseUser phone number link
  Future<void> firebasePhoneNumberLinkMethod(
    String phone,
    String verificationCode,
  ) async {
    try {
      await firebasePhoneNumberLink.linkPhoneNumber(
        currentUser!.idToken!,
        phone,
        verificationCode,
      );
    } catch (e) {
      log("error is $e");
      throw FirebaseAuthException(
        code: 'verification-code-error',
        message:
            'Failed to send verification code to phone number: ${e.toString()}',
      );
    }
  }

  ///FirebaseUser.deleteUser
  Future<void> deleteFirebaseUser() async {
    if (FirebaseApp.instance.getCurrentUser() == null && currentUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-signed-in',
        message: 'No user is currently signed in.',
      );
    }
    // var accesToken = FirebaseAppInitialize.instance.getAccessToken();
    //  log("access token is$accesToken");
    try {
      await firebaseDeleteUser.deleteUser(
        currentUser!.idToken!,
        currentUser!.uid,
      );
      FirebaseApp.instance.setCurrentUser(null);
      log('User Deleted ');
      return;
    } catch (e) {
      log('User Delete failed: $e');
      throw FirebaseAuthException(
        code: 'user-delete-error',
        message: 'Failed to delete user.',
      );
    }
  }

  /////////FirebaseUser.getIdToken
  Future<String?> getIdToken() async {
    final user = currentUser;
    return await user?.getIdToken();
  }

  //////////// FirebaseUser.getIdTokenResult
  Future<IdTokenResult?> getIdTokenResult() async {
    final user = currentUser;
    return await user?.getIdTokenResult();
  }

  /////////////////Firebase SignIn Anonymously /////////////////////////

  Future<UserCredential?> signInAnonymouslyMethod() async {
    try {
      return await signInAnonymously.signInAnonymously();
    } catch (e) {
      print('Sign-in with anonymously failed: $e');
      throw FirebaseAuthException(
        code: 'sign-in-anonymously-error',
        message: 'Failed to sign in with anonymously.',
      );
    }
  }

  ///////////////////////////////
  ///////////////////////////////
  Future<void> setPresistanceMethod(
    String presistanceType,
    String databaseName,
  ) {
    try {
      return setPresistence.setPersistence(
        currentUser!.uid,
        currentUser!.idToken!,
        presistanceType,
        databaseName,
      );
    } catch (e) {
      print('Failed Set Persistence: $e');
      throw FirebaseAuthException(
        code: 'set-persistence-error',
        message: 'Failed to Set Persistence.',
      );
    }
  }

  /////////////////
  Future<void> setLanguageCodeMethod(String languageCode, String dataBaseName) {
    try {
      return setLanguageService.setLanguagePreference(
        currentUser!.uid,
        currentUser!.idToken!,
        languageCode,
        dataBaseName,
      );
    } catch (e) {
      print('Failed Set Language: $e');
      throw FirebaseAuthException(
        code: 'set-language-error',
        message: 'Failed to set language.',
      );
    }
  }

  ///////////////////
  Future<void> getLanguageCodeMethod(String databaseName) {
    try {
      return getLanguageService.getLanguagePreference(
        currentUser!.uid,
        currentUser!.idToken!,
        databaseName,
      );
    } catch (e) {
      // print('Failed to Get Set Language: $e');
      throw FirebaseAuthException(
        code: 'get-language-error',
        message: 'No language is set ',
      );
    }
  }

  ////////
  Future<void> getAuthBeforeChange() {
    try {
      return firebaseBeforeAuthStateChangeService.beforeAuthStateChange(
        currentUser!.idToken!,
        currentUser!.refreshToken!,
      );
    } catch (e) {
      print('Failed Before Auth State Changed: $e');
      throw FirebaseAuthException(
        code: 'before-auth-state-changed-error',
        message: 'Failed to Before Auth State Changed.',
      );
    }
  }

  /// Disposes of the FirebaseAuth instance and releases resources.
  void dispose() {
    authStateChangedController.close();
    idTokenChangedController.close();
    httpClient.close();
  }

  ///fetch signin methods
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    try {
      List<String> methods = await fetchSignInMethods
          .fetchSignInMethodsForEmail(email);
      return methods;
    } catch (e) {
      print('Fetch sign-in methods failed: $e');
      throw FirebaseAuthException(
        code: 'fetch-sign-in-methods-error',
        message: 'Failed to fetch sign-in methods for email.',
      );
    }
  }

  ///get redirect results
  Future<Map<String, dynamic>?> getRedirectResult() async {
    try {
      // Use the GetRedirectResultService instead of popup resolver
      return await getRedirectResultService.getRedirectResult();
    } catch (e) {
      log('Get redirect result failed: $e');
      throw FirebaseAuthException(
        code: 'get-redirect-result-error',
        message: 'Failed to get redirect result.',
      );
    }
  }

  ///initialize recaptcha
  Future<void> initializeRecaptchaConfig(String siteKey) async {
    try {
      await _recaptchaConfigService.initializeRecaptchaConfig(siteKey);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'recaptcha-config-error',
        message: 'Failed to initialize reCAPTCHA config: ${e.toString()}',
      );
    }
  }

  ///create user email
  // Future<UserCredential> createUserWithEmailAndPassword(
  //   String email,
  //   String password,
  // ) async {
  //   // Ensure token is valid before making request
  //   if (firebaseApp != null) {
  //     await firebaseApp!.getValidAccessToken();
  //   }

  //   return createUserWithEmailAndPasswordService.create(email, password, this);
  // }

  ///create user email
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      //print('[FirebaseAuth] Creating user with email: $email');
      //print('[FirebaseAuth] API Key available: ${apiKey != null}');
      //print('[FirebaseAuth] Access Token available: ${accessToken != null}');

      // Ensure token is valid before making request
      if (firebaseApp != null) {
        await firebaseApp!.getValidAccessToken();
      }

      // Make the signup request directly here to ensure proper token handling
      final response = await performRequest('signUp', {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      });

      //print('[FirebaseAuth] Signup response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userData = response.body;

        //print('[FirebaseAuth] Response contains:');
        //print('[FirebaseAuth] - idToken: ${userData['idToken'] != null}');
        //print(
        //  '[FirebaseAuth] - refreshToken: ${userData['refreshToken'] != null}',
        //);
        //print('[FirebaseAuth] - localId: ${userData['localId']}');

        // Create User with proper API key for token operations
        final user = User(
          uid: userData['localId'] ?? userData['uid'],
          email: userData['email'],
          emailVerified: userData['emailVerified'] ?? false,
          displayName: userData['displayName'] ?? email.split('@').first,
          photoURL: userData['photoUrl'] ?? userData['photoURL'],
          mfaEnabled: userData['mfaEnabled'] ?? false,
          idToken: userData['idToken'],
          refreshToken: userData['refreshToken'],
          tenantId: userData['tenantId'],
          apiKey: apiKey, // CRITICAL: Pass the API key for token operations
        );

        // Set token expiration
        if (userData['expiresIn'] != null) {
          final expiresIn = userData['expiresIn'] is String
              ? int.tryParse(userData['expiresIn']) ?? 3600
              : userData['expiresIn'] as int;
          // This would need to be set via reflection or a setter method
          // For now, the User constructor should handle this
        }

        //print('[FirebaseAuth] Created User object:');
        //print('[FirebaseAuth] - uid: ${user.uid}');
        //print('[FirebaseAuth] - idToken exists: ${user.idToken != null}');
        //print(
        //  '[FirebaseAuth] - refreshToken exists: ${user.refreshToken != null}',
        //);
        //print('[FirebaseAuth] - apiKey exists: ${user.apiKey != null}');

        final userCredential = UserCredential(
          user: user,
          additionalUserInfo: AdditionalUserInfo(
            isNewUser: true,
            providerId: 'password',
          ),
          operationType: 'signUp',
        );

        // Update current user
        updateCurrentUser(user);

        return userCredential;
      } else {
        final error = response.body['error'];
        throw FirebaseAuthException(
          code: error['message'] ?? 'signup-failed',
          message: error['message'] ?? 'Failed to create user',
        );
      }
    } catch (e) {
      print('[FirebaseAuth] Error creating user: $e');
      if (e is FirebaseAuthException) rethrow;
      throw FirebaseAuthException(code: 'signup-error', message: e.toString());
    }
  }

  ///connect auth Emulator
  void connectAuthEmulator(String host, int port) {
    connectAuthEmulatorService.connect(host, port);
  }

  ///emulator
  void setEmulatorUrl(String url) {
    // Implementation to set the emulator URL
    print('Emulator URL set to: $url');
  }

  ///confirm password reset
  Future<void> confirmPasswordReset(String oobCode, String newPassword) async {
    try {
      await confirmPasswordResetService.confirmPasswordReset(
        oobCode,
        newPassword,
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'confirm-password-reset-error',
        message: 'Failed to confirm password reset: ${e.toString()}',
      );
    }
  }

  ///check action code
  Future<ActionCodeInfo> checkActionCode(String code) async {
    try {
      final result = await checkActionCodeService.checkActionCode(code);
      if (result.operation == 'PASSWORD_RESET') {
        // If it's a password reset, we'll handle it specially
        return result;
      } else {
        throw FirebaseAuthException(
          code: 'invalid-action',
          message: 'The action code is not for password reset.',
        );
      }
    } catch (e) {
      throw FirebaseAuthException(
        code: 'check-action-code-error',
        message: 'Failed to check action code: ${e.toString()}',
      );
    }
  }

  ///getmulti
  Future<multi_factor.MultiFactorResolver> getMultiFactorResolver(
    multi_factor.MultiFactorError error,
  ) async {
    try {
      return await multiFactorService.getMultiFactorResolver(error);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'multi-factor-resolver-error',
        message: 'Failed to get multi-factor resolver: ${e.toString()}',
      );
    }
  }

  ///sign in with apple
  Future<UserCredential> signInWithApple(String idToken, {String? nonce}) {
    return _appleAuth.signInWithApple(idToken, nonce: nonce);
  }

  ///sign in with GCP
  Future<UserCredential> signInWithGCP({
    required String clientId,
    required String clientSecret,
  }) {
    return _gcpAuth.signInWithGCP(
      clientId: clientId,
      clientSecret: clientSecret,
    );
  }

  /// Verifies a Firebase ID token and returns the decoded token information
  ///
  /// Takes a [idToken] string and returns a map containing the verified user data
  /// Throws [FirebaseAuthException] if verification fails
  Future<Map<String, dynamic>> verifyIdToken(String idToken) async {
    try {
      // Initialize verification service if not already created
      verifyTokenService = VerifyIdTokenService(auth: this);

      // Use direct token verification without additional parameters
      // since service account context is handled in VerifyIdTokenService
      return await verifyTokenService.verifyIdToken(idToken);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'token-verification-failed',
        message: 'Failed to verify ID token: ${e.toString()}',
      );
    }
  }
}
