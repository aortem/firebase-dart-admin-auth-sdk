import 'dart:convert';
import 'package:firebase_dart_admin_auth_sdk/src/provider_user_info.dart';
import 'id_token_result_model.dart';
import 'package:ds_standard_features/ds_standard_features.dart' as http;

/// Represents a user object that contains all the necessary information
/// related to a user in Firebase Authentication.
///
/// This class contains the user's details, authentication tokens, and metadata
/// related to the user's account, such as email verification, phone number,
/// and additional provider-specific information.
class User {
  /// Unique identifier for the user.
  final String uid;

  /// The user's email address.
  String? email;

  /// Whether the user's email is verified.
  bool? emailVerified;

  /// The user's phone number.
  String? phoneNumber;

  /// The user's display name.
  String? displayName;

  /// URL to the user's photo.
  String? photoURL;

  /// The authentication ID token for the user.
  String? idToken;

  /// Expiration time for the ID token.
  DateTime? _idTokenExpiration;

  /// The user's refresh token.
  String? refreshToken;

  /// A list of provider-specific information related to the user.
  List<ProviderUserInfo>? providerUserInfo;

  /// The time the user's password was last updated.
  DateTime? passwordUpdatedAt;

  /// The time from which the user's credentials are valid.
  DateTime? validSince;

  /// Whether the user account is disabled.
  bool? disabled;

  /// The time the user last logged in.
  DateTime? lastLoginAt;

  /// The time the user's account was created.
  DateTime? createdAt;

  /// Custom attributes associated with the user.
  Map<String, dynamic>? customAttributes;

  /// Whether the user is enrolled in multi-factor authentication (MFA).
  final bool mfaEnabled;

  /// The tenant ID for the user.
  String? tenantId;

  /// Firebase API key for token refresh
  final String? _apiKey;

  /// Getter for API key
  String? get apiKey => _apiKey;

  /// Creates an instance of the [User] class with the given parameters.
  ///
  /// The constructor initializes the user's details, authentication tokens,
  /// and metadata.
  User({
    required this.uid,
    this.email,
    this.emailVerified = false,
    this.phoneNumber,
    this.displayName,
    this.photoURL,
    this.refreshToken,
    this.createdAt,
    this.customAttributes,
    this.disabled,
    this.lastLoginAt,
    this.passwordUpdatedAt,
    this.providerUserInfo,
    this.validSince,
    this.mfaEnabled = false,
    this.idToken,
    this.tenantId,
    String? apiKey,
  }) : _apiKey = apiKey;

  /// A getter to determine if the user is signed in anonymously.
  ///
  /// This returns `true` if both the email and phone number are null,
  /// indicating an anonymous sign-in, otherwise it returns `false`.
  bool get isAnonymous => email == null && phoneNumber == null;

  /// Returns the current ID token, refreshing it if necessary.
  ///
  /// If the `forceRefresh` flag is set to `true` or if the token is expired
  /// or null, this method will refresh the ID token and return the new token.
  /// This method now properly refreshes tokens using Firebase REST API.
  Future<String> getIdToken([bool forceRefresh = false]) async {
    // Debug logging
    //print('[User.getIdToken] Called with forceRefresh=$forceRefresh');
    //print('[User.getIdToken] Current idToken exists: ${idToken != null}');
    //print('[User.getIdToken] Current idToken length: ${idToken?.length ?? 0}');
    //print('[User.getIdToken] RefreshToken exists: ${refreshToken != null}');
    //print('[User.getIdToken] API key exists: ${_apiKey != null}');

    // First, check if we have a valid token that doesn't need refreshing
    if (!forceRefresh && idToken != null && idToken!.isNotEmpty) {
      // Check expiration if we have it
      if (_idTokenExpiration != null) {
        final bufferTime = _idTokenExpiration!.subtract(Duration(seconds: 30));
        if (DateTime.now().isBefore(bufferTime)) {
          //print('[User.getIdToken] Returning existing valid token');
          return idToken!;
        }
        //print('[User.getIdToken] Token exists but is expired');
      } else {
        // No expiration set, but we have a token - set default expiration
        // print(
        //   '[User.getIdToken] Token exists without expiration, setting default',
        // );
        _idTokenExpiration = DateTime.now().add(Duration(hours: 1));
        return idToken!;
      }
    }

    // Try to refresh if we have the necessary credentials
    if (forceRefresh || (idToken == null || idToken!.isEmpty)) {
      if (refreshToken != null && refreshToken!.isNotEmpty && _apiKey != null) {
        print('[User.getIdToken] Attempting to refresh token');
        try {
          final response = await http.post(
            Uri.parse(
              'https://securetoken.googleapis.com/v1/token?key=$_apiKey',
            ),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'grant_type=refresh_token&refresh_token=$refreshToken',
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            idToken = data['id_token'];
            refreshToken = data['refresh_token'];
            final expiresIn = int.parse(data['expires_in'] ?? '3600');
            _idTokenExpiration = DateTime.now().add(
              Duration(seconds: expiresIn),
            );
            //print('[User.getIdToken] Token refreshed successfully');
            return idToken!;
          } else {
            //print('[User.getIdToken] Refresh failed: ${response.body}');
          }
        } catch (e) {
          //print('[User.getIdToken] Refresh error: $e');
        }
      } else {
        //print('[User.getIdToken] Cannot refresh - missing credentials');
      }
    }

    // Last resort - if we have any token at all, return it
    if (idToken != null && idToken!.isNotEmpty) {
      //print('[User.getIdToken] Returning existing token as last resort');
      _idTokenExpiration ??= DateTime.now().add(Duration(hours: 1));
      return idToken!;
    }

    // No token available at all
    //print('[User.getIdToken] No token available - throwing exception');
    //print('[User.getIdToken] Debug info: uid=$uid, email=$email');
    throw Exception('No valid ID token available');
  }

  /// Updates the user's ID token and refresh token.
  void updateIdToken(String newToken) {
    idToken = newToken;
    _idTokenExpiration = DateTime.now().add(Duration(hours: 1));
    // Don't overwrite refresh token with ID token
    // refreshToken should only be updated when we get a new refresh token
  }

  /// Converts the [User] instance to a map for easy serialization.
  ///
  /// This method is useful for converting the user object into a format
  /// suitable for API responses or database storage.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'emailVerified': emailVerified,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoURL': photoURL,
      'isAnonymous': isAnonymous,
      'refreshToken': refreshToken,
      'mfaEnabled': mfaEnabled,
    };
  }

  /// Factory constructor to create a [User] instance from a JSON object.
  ///
  /// This is useful for parsing JSON responses from Firebase or other services.
  factory User.fromJson(Map<String, dynamic> json, {String? apiKey}) {
    final user = User(
      uid: json['localId'] ?? json['uid'],
      email: json['email'],
      emailVerified: json['emailVerified'] ?? false,
      phoneNumber: json['phoneNumber'],
      displayName: json['displayName'],
      photoURL: json['photoUrl'] ?? json['photoURL'],
      mfaEnabled: json['mfaEnabled'] ?? false,
      idToken: json['idToken'],
      refreshToken: json['refreshToken'],
      tenantId: json['tenantId'],
      apiKey: apiKey,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime?.fromMillisecondsSinceEpoch(
              int.tryParse(json['createdAt'].toString()) ?? 0,
            ),
      customAttributes: json['customAttributes'] == null
          ? null
          : jsonDecode(json['customAttributes']),
      disabled: json['disabled'],
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime?.fromMillisecondsSinceEpoch(
              int.tryParse(json['lastLoginAt'].toString()) ?? 0,
            ),
      passwordUpdatedAt: json['passwordUpdatedAt'] == null
          ? null
          : DateTime?.fromMillisecondsSinceEpoch(
              int.tryParse(json['passwordUpdatedAt'].toString()) ?? 0,
            ),
      providerUserInfo: json['providerUserInfo'] == null
          ? null
          : json['providerUserInfo'] != null
              ? (json['providerUserInfo'] as List)
                  .map((e) => ProviderUserInfo.fromJson(e))
                  .toList()
              : null,
      validSince: json['validSince'] == null
          ? null
          : DateTime?.fromMillisecondsSinceEpoch(
              int.tryParse(json['validSince'].toString()) ?? 0,
            ),
    );

    // Set token expiration based on expiresIn if available
    if (user.idToken != null && user.idToken!.isNotEmpty) {
      final expiresIn = json['expiresIn'];
      if (expiresIn != null) {
        // Parse expiresIn which could be string or int (seconds)
        final seconds = expiresIn is String
            ? int.tryParse(expiresIn) ?? 3600
            : (expiresIn as int);
        user._idTokenExpiration = DateTime.now().add(
          Duration(seconds: seconds),
        );
      } else {
        // Default to 1 hour expiration for new tokens
        user._idTokenExpiration = DateTime.now().add(Duration(hours: 1));
      }
    }

    return user;
  }

  /// Creates a copy of the [User] instance with optional updates to fields.
  ///
  /// This method allows you to create a new [User] object with some updated
  /// values while keeping the unchanged fields from the original instance.
  User copyWith(User user) {
    final copiedUser = User(
      uid: user.uid,
      displayName: user.displayName ?? displayName,
      email: user.email ?? email,
      emailVerified: user.emailVerified ?? emailVerified,
      idToken: user.idToken ?? idToken,
      phoneNumber: user.phoneNumber ?? phoneNumber,
      photoURL: user.photoURL ?? photoURL,
      refreshToken: user.refreshToken ?? refreshToken,
      createdAt: user.createdAt ?? createdAt,
      customAttributes: user.customAttributes ?? customAttributes,
      disabled: user.disabled ?? disabled,
      lastLoginAt: user.lastLoginAt ?? lastLoginAt,
      passwordUpdatedAt: user.passwordUpdatedAt ?? passwordUpdatedAt,
      providerUserInfo: user.providerUserInfo ?? providerUserInfo,
      validSince: user.validSince ?? validSince,
      apiKey: user._apiKey ?? _apiKey,
    );

    // Copy over the token expiration if we're copying the token
    if (user.idToken != null && user.idToken == copiedUser.idToken) {
      copiedUser._idTokenExpiration =
          user._idTokenExpiration ?? _idTokenExpiration;
    }

    return copiedUser;
  }

  /// Returns a string representation of the [User] object.
  ///
  /// This is useful for debugging and logging purposes.
  @override
  String toString() {
    return 'User{uid: $uid, email: $email, emailVerified: $emailVerified, phoneNumber: $phoneNumber, displayName: $displayName, photoURL: $photoURL, _idToken: $idToken, _idTokenExpiration: $_idTokenExpiration}';
  }

  /// Returns an [IdTokenResult] containing the token information.
  ///
  /// This method fetches the ID token and returns the associated information
  /// such as token expiration time and issuance time.
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    final token = await getIdToken(forceRefresh);
    return IdTokenResult(
      token: token,
      expirationTime: _idTokenExpiration?.millisecondsSinceEpoch ??
          DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
      issuedAtTime: DateTime.now().millisecondsSinceEpoch,
      signInProvider: 'password', // or 'phone' or 'google.com' etc.
      userId: uid,
      authTime: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Implements equality based on the user's fields.
  ///
  /// This method compares two [User] objects based on their field values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.uid == uid &&
        other.email == email &&
        other.emailVerified == emailVerified &&
        other.phoneNumber == phoneNumber &&
        other.displayName == displayName &&
        other.photoURL == photoURL &&
        other.idToken == idToken &&
        other._idTokenExpiration == _idTokenExpiration;
  }

  /// Computes a hash code for the [User] object based on its fields.
  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        emailVerified.hashCode ^
        phoneNumber.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode ^
        idToken.hashCode ^
        _idTokenExpiration.hashCode;
  }

  ///provider data
  dynamic get providerData => null;
}
