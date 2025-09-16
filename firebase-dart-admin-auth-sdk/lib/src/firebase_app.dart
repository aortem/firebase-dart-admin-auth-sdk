import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:ds_standard_features/ds_standard_features.dart'
    show visibleForTesting;

import 'package:firebase_dart_admin_auth_sdk/src/firebase_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/firebase_storage.dart';
import 'package:firebase_dart_admin_auth_sdk/src/service_account.dart';
import 'package:firebase_dart_admin_auth_sdk/src/user.dart';
import 'package:firebase_dart_admin_auth_sdk/src/workload_identity_token_provider.dart';
import 'auth/generate_custom_token.dart';
import 'auth/get_access_token_with_generated_token.dart';

/// The base class to initialize the firebase dart admin sdk
class FirebaseApp {
  ///Instance of the Firebase App
  static FirebaseApp? _instance;
  //API key associated with the project
  final String? _apiKey;
  //The ID of the project
  final String? _projectId;
  //The authDomain of the project
  final String _authdomain;
  //The messagingSenderId of the project
  final String _messagingSenderId;
  final String? _bucketName;
  final String? _appId;

  ///The access token
  String? accessToken; // remove 'final'
  ///The access token expire time
  DateTime? tokenExpiryTime; // new
  ///The access token refresh time
  static const Duration tokenRefreshBuffer = Duration(minutes: 5); // new
  ServiceAccount? _serviceAccount;

  /// HTTP client for making requests
  static http.Client httpClient = http.Client();

  ///The class to interact with the various firebase auth methods
  static FirebaseAuth? firebaseAuth;
  static GetAccessTokenWithGeneratedToken? _accessTokenGen;
  static GenerateCustomToken? _tokenGen;

  ///The class to interact with the various firebase storage methods
  static FirebaseStorage? firebaseStorage;
  static bool _cachedIsGCP = false;
  static bool? _isGCPChecked;

  FirebaseApp._(
    this._apiKey,
    this._projectId,
    this._authdomain,
    this._messagingSenderId,
    this._bucketName,
    this._appId,
    this._serviceAccount,
    this.accessToken,
  );

  // --- token refresh concurrency control ---
  static Completer<void>? _refreshCompleter;

  bool _isTokenValid() {
    if (accessToken == null || tokenExpiryTime == null) return false;
    return DateTime.now().isBefore(
      tokenExpiryTime!.subtract(tokenRefreshBuffer),
    );
  }

  /// Refreshes OAuth2 token
  static bool _isRefreshing = false;

  /// Used only in unit tests to reset static state.
  @visibleForTesting
  static void resetForTests() {
    httpClient = http.Client();
    _instance = null;
    _refreshCompleter = null;
    firebaseAuth = null;
    firebaseStorage = null;
    _isGCPChecked = null;
    _cachedIsGCP = false;
  }

  /// Refreshes OAuth2 token
  Future<void> refreshAccessToken() async {
    // If already refreshing, wait for it and return
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      return;
    }

    _refreshCompleter = Completer<void>();

    try {
      if (_serviceAccount == null) {
        throw Exception('Cannot refresh token: No service account available');
      }

      final tokenGen = _tokenGen ??= GenerateCustomTokenImplementation();
      final accessTokenGen = _accessTokenGen ??=
          GetAccessTokenWithGeneratedTokenImplementation();

      final jwt = await tokenGen.generateServiceAccountJwt(_serviceAccount!);
      final tokenResponse = await accessTokenGen
          .getAccessTokenWithGeneratedTokenResponse(jwt);

      accessToken = tokenResponse['access_token'] as String?;
      final expiresIn = tokenResponse['expires_in'] as int? ?? 3600;
      tokenExpiryTime = DateTime.now().add(Duration(seconds: expiresIn));

      log('✅ Access token refreshed, expires at $tokenExpiryTime');
    } catch (e) {
      log('⚠️ refreshAccessToken failed: $e');
      rethrow;
    } finally {
      // Complete the completer and clear it
      _refreshCompleter?.complete();
      _refreshCompleter = null;
    }
  }

  /// Returns valid access token
  Future<String?> getValidAccessToken() async {
    if (!_isTokenValid()) {
      await refreshAccessToken();
    }
    return accessToken;
  }

  User? _currentUser;

  /// Method to set the current user
  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  /// Method to get the current User
  User? getCurrentUser() => _currentUser;

  ///Exposed the firebase app singleton
  static FirebaseApp get instance {
    if (_instance == null) {
      throw StateError(
        "FirebaseApp is not initialized. Call initializeApp() first.",
      );
    }
    return _instance!;
  }
  // --- Initialization methods ---

  ///Used to initialize the project with enviroment variables
  ///[apiKey] is the API Key associated with the project
  ///[projectId] is the ID of the project
  static Future<FirebaseApp> initializeAppWithEnvironmentVariables({
    required String apiKey,
    required String authdomain,
    required String projectId,
    required String messagingSenderId,
    required String bucketName,
    required String appId,
  }) async {
    // Asserts that the API key, Project ID, and Bucket Name are not empty
    assert(apiKey.isNotEmpty, "API Key cannot be empty");
    assert(projectId.isNotEmpty, "Project ID cannot be empty");
    assert(bucketName.isNotEmpty, "Bucket Name cannot be empty");
    assert(authdomain.isNotEmpty, "Auth Domain cannot be empty");
    assert(messagingSenderId.isNotEmpty, "Messaging Sender ID cannot be empty");
    assert(appId.isNotEmpty, "App ID cannot be empty");

    // Returns an instance of FirebaseApp if it exists or create a new instance based on the parameters passed
    return _instance ??= FirebaseApp._(
      apiKey,
      projectId,
      authdomain,
      messagingSenderId,
      bucketName,
      appId,
      null,
      null,
    );
  }

  ///Used to initialize the project with service account
  ///[serviceAccountContent] is the encoded string of the service account
  static Future<FirebaseApp> initializeAppWithServiceAccount({
    required String serviceAccountContent,
  }) async {
    final tokenGen = _tokenGen ??= GenerateCustomTokenImplementation();
    final accessTokenGen = _accessTokenGen ??=
        GetAccessTokenWithGeneratedTokenImplementation();

    try {
      final Map<String, dynamic> serviceAccount = json.decode(
        serviceAccountContent,
      );
      final ServiceAccount serviceAccountModel = ServiceAccount.fromJson(
        serviceAccount,
      );

      // 1. Generate token
      final jwt = await tokenGen.generateServiceAccountJwt(serviceAccountModel);
      final tokenResponse = await accessTokenGen
          .getAccessTokenWithGeneratedTokenResponse(jwt);

      final accessToken = tokenResponse['access_token'] as String;
      final expiresIn = tokenResponse['expires_in'] as int? ?? 3600;

      // 2. Extract config values
      final projectId = serviceAccount['project_id'];
      final authDomain = serviceAccount['auth_domain'] ?? '';
      final messagingSenderId = serviceAccount['messaging_sender_id'] ?? '';
      final bucketName = serviceAccount['bucket_name'];
      final appId = serviceAccount['app_id'];

      if (projectId == null) {
        throw FormatException('Missing project_id in service account JSON');
      }

      // 3. Create or update instance
      if (_instance == null) {
        _instance = FirebaseApp._(
          null,
          projectId,
          authDomain,
          messagingSenderId,
          bucketName,
          appId,
          serviceAccountModel,
          accessToken,
        );
      } else {
        _instance!
          ..accessToken = accessToken
          .._serviceAccount = serviceAccountModel;
      }

      // 4. Now safe to set expiry
      _instance!.tokenExpiryTime = DateTime.now().add(
        Duration(seconds: expiresIn),
      );

      return _instance!;
    } catch (e) {
      throw Exception('Failed to initialize Firebase with service account: $e');
    }
  }

  ///This is for unit testing purposes
  static void overrideInstanceForTesting(
    GetAccessTokenWithGeneratedToken tokenGen,
    GenerateCustomToken generateCustomToken,
  ) {
    _accessTokenGen = tokenGen;
    _tokenGen = generateCustomToken;
  }

  ///Used to initialize the project with service account impersonation
  ///[serviceAccountContent] is the encoded string of the service account
  ///[impersonatedEmail] is the email of the impersonated account
  static Future<FirebaseApp> initializeAppWithServiceAccountImpersonation({
    required String serviceAccountContent,
    required String impersonatedEmail,
  }) async {
    final tokenGen = _tokenGen ??= GenerateCustomTokenImplementation();
    final accessTokenGen = _accessTokenGen ??=
        GetAccessTokenWithGeneratedTokenImplementation();
    // Parse the JSON content
    final Map<String, dynamic> serviceAccount = json.decode(
      serviceAccountContent,
    );

    final ServiceAccount serviceAccountModel = ServiceAccount.fromJson(
      serviceAccount,
    );

    final jwt = await tokenGen.generateServiceAccountJwt(
      serviceAccountModel,
      impersonatedEmail: impersonatedEmail,
    );

    final accessToken = await accessTokenGen.getAccessTokenWithGeneratedToken(
      jwt,
    );
    final projectId = serviceAccount['project_id'];
    if (projectId == null) {
      throw Exception('Missing project_id in service account JSON');
    }

    return _instance ??= FirebaseApp._(
      null,
      projectId, // projectId dynamically resolved
      '$projectId.firebaseapp.com', // auth domain
      '', // messaging sender ID (can be set if needed)
      '$projectId.appspot.com', // bucket name
      '', // app ID (optional, can be set)
      serviceAccountModel,
      accessToken,
    );
  }

  ///Used to initialize the project with service account impersonation in a GCP enviroment
  ///[gcpAccessToken] is the encoded string of the service account
  ///[impersonatedEmail] is the email of the impersonated account
  static Future<FirebaseApp> initializeAppWithServiceAccountImpersonationGCP({
    required String gcpAccessToken,
    required String impersonatedEmail,
    required String firebaseProjectId,
  }) async {
    final accessTokenGen = _accessTokenGen ??=
        GetAccessTokenWithGcpTokenImplementation();

    final accessToken = await accessTokenGen.getAccessTokenWithGeneratedToken(
      gcpAccessToken,
      targetServiceAccountEmail: impersonatedEmail,
    );

    return _instance ??= FirebaseApp._(
      null,
      firebaseProjectId, // firebaseProjectId dynamically resolved
      '$firebaseProjectId.firebaseapp.com', // auth domain
      '', // messaging sender ID (can be set if needed)
      '$firebaseProjectId.appspot.com', // bucket name
      '', // app ID (optional, can be set)
      null,
      accessToken,
    );
  }

  ///Used to initialize the project with service account
  static Future<String> impersonateServiceAccount(
    String serviceAccountEmail,
  ) async {
    log("resposns is 434");
    // Get the access token for the current authenticated user (ADC).
    Future<String> getAuthToken() async {
      log("resposns is 987");
      final response = await httpClient.get(
        Uri.parse(
          'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token',
        ),
        headers: {'Metadata-Flavor': 'Google'},
      );
      log("resposns is $response");
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['access_token'];
      } else {
        throw Exception('Failed to retrieve ADC token: ${response.body}');
      }
    }

    // Obtain the current authentication token.
    final authToken = await getAuthToken();

    // Make the impersonation request.
    final response = await httpClient.post(
      Uri.parse(
        'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$serviceAccountEmail:generateAccessToken',
      ),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'scope': ['https://www.googleapis.com/auth/cloud-platform'],
      }),
    );

    // Parse the response and return the access token.
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['accessToken'];
    } else {
      throw Exception(
        'Failed to impersonate service account: ${response.body}',
      );
    }
  }

  static Future<String> _getIdToken() async {
    if (Platform.isAndroid || Platform.isIOS) {
      throw Exception(
        'Service account impersonation is not supported in mobile environment. Please use a different authentication method.',
      );
    }

    try {
      // First try GCP metadata server
      final response = await httpClient.get(
        Uri.parse(
          'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity',
        ),
        headers: {'Metadata-Flavor': 'Google'},
      );

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      // If metadata server is not accessible, try alternative authentication
      final credentials = await _getCredentialsFile();
      if (credentials != null) {
        // Use credentials to get token
        return credentials['token'] ?? '';
      }
    }

    throw Exception(
      'Failed to get ID token. Please ensure you are running on GCP or have valid credentials.',
    );
  }

  static Future<Map<String, dynamic>?> _getCredentialsFile() async {
    final credentialsPath =
        Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
    if (credentialsPath != null) {
      final credentialsFile = File(credentialsPath);
      if (await credentialsFile.exists()) {
        return jsonDecode(await credentialsFile.readAsString());
      }
    }
    return null;
  }

  static Future<String> _impersonateServiceAccount(
    String idToken,
    String serviceAccountEmail,
  ) async {
    final response = await httpClient.post(
      Uri.parse(
        'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$serviceAccountEmail:generateAccessToken',
      ),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'scope': [
          'https://www.googleapis.com/auth/cloud-platform',
          'https://www.googleapis.com/auth/firebase',
          'https://www.googleapis.com/auth/identitytoolkit',
          'https://www.googleapis.com/auth/datastore',
          'https://www.googleapis.com/auth/firebase.database',
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to impersonate service account: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    return data['accessToken'];
  }

  ///Used to initialize the project with service account
  static Future<void> initializeWithServiceAccountImpersonation({
    required String serviceAccountEmail,
  }) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        throw Exception(
          'Service account impersonation is not supported in mobile environment.',
        );
      }

      String? accessToken;

      try {
        // Try GCP impersonation flow first
        final idToken = await _getIdToken();
        accessToken = await _impersonateServiceAccount(
          idToken,
          serviceAccountEmail,
        );
        log("access token is $accessToken");
      } catch (e) {
        log("GCP impersonation failed: $e");
        rethrow;
      }

      log("Successfully obtained access token");
      // Use the access token for Firebase operations
    } catch (e) {
      log('Error during Firebase initialization: $e');
      throw Exception('Failed to initialize Firebase with impersonation: $e');
    }
  }

  /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////
  /// Initialize Firebase with Workload Identity Federation.
  ///
  /// - If [externalToken] is provided → External IdP flow (Google Workspace, Azure AD, Okta, CI/CD, etc.)
  /// - If no token but running on GCP → Workload Identity flow via metadata server (GKE/Cloud Run)
  /// - Otherwise → throws exception

  // For GKE Workload Identity
  static Future<FirebaseApp> initializeAppWithWorkloadIdentity({
    required String targetServiceAccount,
    required String firebaseProjectId,
  }) async {
    final provider = WorkloadIdentityTokenProvider(
      targetServiceAccount: targetServiceAccount,
      firebaseProjectId: firebaseProjectId,
      client: httpClient,
    );

    final tokenInfo = await provider.getAccessToken();

    _instance = FirebaseApp._(
      null,
      firebaseProjectId,
      '$firebaseProjectId.firebaseapp.com',
      '',
      '$firebaseProjectId.appspot.com',
      '',
      null,
      tokenInfo.accessToken,
    )..tokenExpiryTime = tokenInfo.expiry;

    log("✅ Firebase initialized with Workload Identity for $firebaseProjectId");
    return _instance!;
  }

  // For Workforce Identity Federation (external IdP like GitHub, Azure AD, etc.)
  /// See: https://cloud.google.com/iam/docs/workload-identity-federation
  static Future<FirebaseApp> initializeAppWithWorkloadIdentityFederation({
    required String targetServiceAccount,
    required String externalToken,
    required String projectNumber,
    required String workforcePoolId,
    required String providerId,
    required String firebaseProjectId,
  }) async {
    if (externalToken.isEmpty) throw ArgumentError('externalToken required');
    if (projectNumber.isEmpty) throw ArgumentError('projectNumber required');
    if (workforcePoolId.isEmpty) {
      throw ArgumentError('workforcePoolId required');
    }
    if (providerId.isEmpty) throw ArgumentError('providerId required');

    final accessToken = await _exchangeExternalToken(
      externalToken,
      targetServiceAccount,
      projectNumber,
      workforcePoolId,
      providerId,
    );
    return _initializeWithAccessToken(
      accessToken,
      targetServiceAccount,
      firebaseProjectId,
    );
  }

  static Future<bool> _isRunningOnGCP() async {
    if (_isGCPChecked != null) return _cachedIsGCP;

    try {
      final response = await httpClient
          .get(
            Uri.parse("http://metadata.google.internal"),
            headers: {"Metadata-Flavor": "Google"},
          )
          .timeout(const Duration(seconds: 1));
      _cachedIsGCP = response.statusCode == 200;
    } catch (_) {
      _cachedIsGCP = false;
    }
    _isGCPChecked = true;
    return _cachedIsGCP;
  }

  /// Exchange external IdP token for Firebase access token
  static Future<String> _exchangeExternalToken(
    String externalToken,
    String targetServiceAccount,
    String projectNumber,
    String workforcePoolId,
    String providerId,
  ) async {
    final audience =
        "//iam.googleapis.com/projects/$projectNumber/locations/global/workforcePools/$workforcePoolId/providers/$providerId";
    final body = <String, String>{
      'grant_type': 'urn:ietf:params:oauth:grant-type:token-exchange',
      'audience': audience,
      'scope': 'https://www.googleapis.com/auth/cloud-platform',
      'requested_token_type': 'urn:ietf:params:oauth:token-type:access_token',
      'subject_token_type': 'urn:ietf:params:oauth:token-type:access_token',
      'subject_token': externalToken,
    };
    final stsResponse = await httpClient.post(
      Uri.parse('https://sts.googleapis.com/v1/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&'),
    );

    if (stsResponse.statusCode != 200) {
      throw Exception('STS exchange failed: ${stsResponse.body}');
    }

    final stsJson = jsonDecode(stsResponse.body) as Map<String, dynamic>;
    final stsAccessToken = stsJson['access_token'] as String?;
    final expiresIn = stsJson['expires_in'] as int? ?? 3600;

    if (stsAccessToken == null) {
      throw Exception('STS response did not contain access_token');
    }

    final impersonatedAccessToken = await _impersonateServiceAccount(
      stsAccessToken,
      targetServiceAccount,
    );

    _instance?.tokenExpiryTime = DateTime.now().add(
      Duration(seconds: expiresIn),
    );

    return impersonatedAccessToken;
  }

  /// Get token from GCP metadata server (Workload Identity on GKE/Cloud Run)
  static Future<String> _getTokenFromMetadataServer(
    String targetServiceAccount,
  ) async {
    final adcResponse = await httpClient.get(
      Uri.parse(
        "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token",
      ),
      headers: {"Metadata-Flavor": "Google"},
    );

    if (adcResponse.statusCode != 200) {
      throw Exception("Failed to get ADC token: ${adcResponse.body}");
    }
    final adcJson = jsonDecode(adcResponse.body) as Map<String, dynamic>;
    final adcAccessToken = adcJson['access_token'] as String?;
    final expiresIn = adcJson['expires_in'] as int? ?? 3600;

    if (adcAccessToken == null) {
      throw Exception('Metadata server did not return an access token');
    }

    final impersonatedAccessToken = await _impersonateServiceAccount(
      adcAccessToken,
      targetServiceAccount,
    );

    _instance?.tokenExpiryTime = DateTime.now().add(
      Duration(seconds: expiresIn),
    );

    return impersonatedAccessToken;
  }

  /// Final initializer with access token (Fix: no hardcoded values, projectId extracted)
  static Future<FirebaseApp> _initializeWithAccessToken(
    String accessToken,
    String targetServiceAccount,
    String firebaseProjectId,
  ) async {
    // Extract projectId from service account email (firebase-admin@<project-id>.iam.gserviceaccount.com)
    final projectId = targetServiceAccount.split('@')[1].split('.')[0];

    _instance = FirebaseApp._(
      null,
      firebaseProjectId, // projectId dynamically resolved
      '$firebaseProjectId.firebaseapp.com', // auth domain
      '', // messaging sender ID (can be set if needed)
      '$firebaseProjectId.appspot.com', // bucket name
      '', // app ID (optional, can be set)
      null,
      accessToken,
    );

    _instance!.tokenExpiryTime = DateTime.now().add(const Duration(hours: 1));
    log("✅ Firebase initialized with Workload Identity for $projectId");
    return _instance!;
  }

  ////////////////////////////////////////////////////////
  ///
  ///
  //e Auth instance associated with the Project
  ///Throws not initialized if Firebase app is not intialized
  FirebaseAuth getAuth() {
    if (accessToken == null && _apiKey == null) {
      throw Exception(
        'No credentials available. Provide either an API key (client flows) or an access token/service account (admin flows).',
      );
    }
    if (_projectId == null) {
      throw StateError('Project ID is null');
    }

    if (!_isTokenValid() && _serviceAccount != null) {
      Future.microtask(() async {
        try {
          await refreshAccessToken();
        } catch (e) {
          log('⚠️ Background token refresh failed: $e');
        }
      });
    }
    return firebaseAuth ??= FirebaseAuth(
      apiKey: _apiKey,
      projectId: _projectId,
      authDomain: _authdomain,
      messagingSenderId: _messagingSenderId,
      bucketName: _bucketName,
      accessToken: accessToken,
      serviceAccount: _serviceAccount,
      generateCustomToken: _tokenGen,
      appId: _appId,
      firebaseApp: this, // 🔥 add reference so FirebaseAuth can refresh itself
    );
  }

  ///Used to get firebase storage
  ///[apiKey] is the API Key associated with the project
  ///[projectId] is the ID of the project
  FirebaseStorage getStorage() {
    if (_instance == null) {
      throw StateError(
        "FirebaseApp is not initialized. Call initializeApp() first.",
      );
    }

    return firebaseStorage ??= FirebaseStorage.getStorage(
      apiKey: _apiKey!,
      projectId: _projectId!,
      bucketName: _bucketName!,
    );
  }
}
