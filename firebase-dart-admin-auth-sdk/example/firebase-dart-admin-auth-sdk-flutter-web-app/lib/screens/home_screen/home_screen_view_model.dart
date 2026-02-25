// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:firebase/utils/platform_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// ViewModel for the [HomeScreen].
class HomeScreenViewModel extends ChangeNotifier {
  /// Constructs the [HomeScreenViewModel].
  HomeScreenViewModel() {
    _googleSignIn.onCurrentUserChanged.listen((event) async {
      signInAccount = event;
    });

    refreshUser();
  }

  /// Refreshes the current user's information.
  void refreshUser() {
    displayName = _firebaseSdk?.currentUser?.displayName ?? '';
    displayImage = _firebaseSdk?.currentUser?.photoURL;
    numberOfLinkedProviders =
        _firebaseSdk?.currentUser?.providerUserInfo?.length ?? 0;
    notifyListeners();
  }

  /// The Google Sign-In account used for authentication.
  GoogleSignInAccount? signInAccount;

  /// The list of scopes requested for Google Sign-In.
  List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: scopes,
    signInOption: SignInOption.standard,
  );
  final FirebaseAuth? _firebaseSdk = FirebaseApp.firebaseAuth;

  /// The display name of the current user.
  String displayName = '';

  /// The URL of the current user's profile image.
  String? displayImage;

  /// The number of providers linked to the current user.
  int numberOfLinkedProviders = 0;

  /// Indicates whether an operation is currently in progress.
  bool loading = false;

  /// Sets the loading state to [load] and notifies listeners.
  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  /// Reloads the current user's data from the server.
  Future<void> reloadUser() async {
    try {
      setLoading(true);
      await _firebaseSdk?.reloadUser();
      refreshUser();
      BotToast.showText(text: 'Reload Successful');
    } catch (e) {
      BotToast.showText(text: e.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Indicates whether a verification email is being sent.
  bool verificationLoading = false;

  /// Sets the verification loading state to [load] and notifies listeners.
  void setVerificationLoading(bool load) {
    verificationLoading = load;
    notifyListeners();
  }

  /// Sends an email verification code to the current user.
  Future<void> sendEmailVerificationCode(VoidCallback onSuccess) async {
    try {
      setVerificationLoading(true);

      await _firebaseSdk?.sendEmailVerificationCode();

      onSuccess();
      BotToast.showText(text: 'Code Sent');
    } catch (e) {
      BotToast.showText(text: e.toString());
    } finally {
      setVerificationLoading(false);
    }
  }

  /// Indicates whether additional user info is being fetched.
  bool getAdditionalInfoLoading = false;

  /// Sets the additional info loading state to [load] and notifies listeners.
  void setAdditionalInfoLoading(bool load) {
    getAdditionalInfoLoading = load;
    notifyListeners();
  }

  /// Retrieves additional information about the current user.
  Future<void> getAdditionalUserInfo() async {
    try {
      setAdditionalInfoLoading(true);
      await _firebaseSdk?.getAdditionalUserInfo();

      BotToast.showText(text: 'Additional Info Gotten Successfully');
      refreshUser();
    } catch (e) {
      BotToast.showText(text: e.toString());
    } finally {
      setAdditionalInfoLoading(false);
    }
  }

  /// Indicates whether a provider is being linked.
  bool linkProviderLoading = false;

  /// Sets the link provider loading state to [load] and notifies listeners.
  void setLinkProviderLoading(bool load) {
    linkProviderLoading = load;
    notifyListeners();
  }

  /// Links a Google provider to the current user.
  Future<void> linkProvider() async {
    try {
      setLinkProviderLoading(true);

      if (kIsWeb) {
        signInAccount = await _googleSignIn.signInSilently();
      } else {
        signInAccount = await _googleSignIn.signIn();
      }

      var signInAuth = await signInAccount?.authentication;
      await _firebaseSdk?.linkProviderToUser(
        getPlatformId(),
        signInAuth!.idToken!,
      );

      BotToast.showText(text: 'Linking Successful');
      refreshUser();
    } catch (e) {
      BotToast.showText(text: e.toString());
    } finally {
      setLinkProviderLoading(false);
    }
  }
}
