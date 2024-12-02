import 'dart:math';
import 'dart:async';
import 'dart:io';

/// Validates if the provided email is in a proper format.
///
/// The email must match the format: [username]@[domain].[extension]
/// Example: "example@example.com"
///
/// Returns:
/// - `null` if the email is valid.
/// - An error message if the email format is invalid.
String? validateEmail(String email) {
  final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
  if (!emailRegExp.hasMatch(email)) {
    return 'Invalid email format';
  }
  return null;
}

/// Validates if the provided password meets the minimum length requirement.
///
/// The password must be at least 6 characters long.
///
/// Returns:
/// - `null` if the password is valid.
/// - An error message if the password is too short.
String? validatePassword(String password) {
  if (password.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}

/// Settings used when sending an action code (such as email verification or password reset).
/// Contains details about how the action code should be handled on the client-side.
class ActionCodeSettings {
  final String url;
  final bool handleCodeInApp;
  final String? iOSBundleId;
  final String? androidPackageName;
  final bool? androidInstallApp;
  final String? androidMinimumVersion;
  final String? dynamicLinkDomain;

  ActionCodeSettings({
    required this.url,
    this.handleCodeInApp = false,
    this.iOSBundleId,
    this.androidPackageName,
    this.androidInstallApp,
    this.androidMinimumVersion,
    this.dynamicLinkDomain,
  });

  Map<String, dynamic> toMap() {
    return {
      'continueUrl': url,
      'canHandleCodeInApp': handleCodeInApp,
      if (iOSBundleId != null) 'iOSBundleId': iOSBundleId,
      if (androidPackageName != null) 'androidPackageName': androidPackageName,
      if (androidInstallApp != null) 'androidInstallApp': androidInstallApp,
      if (androidMinimumVersion != null)
        'androidMinimumVersion': androidMinimumVersion,
      if (dynamicLinkDomain != null) 'dynamicLinkDomain': dynamicLinkDomain,
    };
  }
}

/// Generates a unique identifier (UID) in the format of a UUIDv4.
String generateUid() {
  final random = Random.secure();

  String generateRandomHex(int length) {
    const hexDigits = '0123456789abcdef';
    return List.generate(length, (_) => hexDigits[random.nextInt(16)]).join();
  }

  String uuid = '${generateRandomHex(8)}-'
      '${generateRandomHex(4)}-'
      '4${generateRandomHex(3)}-' // UUID version 4
      '${(random.nextInt(16) & 0x3 | 0x8).toRadixString(16)}${generateRandomHex(3)}-' // Variant
      '${generateRandomHex(12)}';

  return uuid;
}

/// Sorts a list of users by a specified field (e.g., name, email).
List<Map<String, dynamic>> sortUsers(
    List<Map<String, dynamic>> users, String field) {
  users.sort((a, b) => a[field].toString().compareTo(b[field].toString()));
  return users;
}

/// Filters a list of users based on a search query.
List<Map<String, dynamic>> filterUsers(
    List<Map<String, dynamic>> users, String query) {
  final lowerQuery = query.toLowerCase();
  return users.where((user) {
    final name = user['name']?.toString().toLowerCase() ?? '';
    final email = user['email']?.toString().toLowerCase() ?? '';
    return name.contains(lowerQuery) || email.contains(lowerQuery);
  }).toList();
}

/// Displays an animated spinner in the terminal.
///
/// [message] is the text displayed next to the spinner.
/// [durationInSeconds] specifies how long the spinner runs.
void showSpinner(String message, [int durationInSeconds = 5]) {
  const frames = ['|', '/', '-', '\\'];
  int index = 0;

  // Start a periodic timer to show spinner animation
  Timer? timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
    stdout.write('\r$message ${frames[index]}');
    index = (index + 1) % frames.length;
  });

  // Stop the spinner after the specified duration
  Future.delayed(Duration(seconds: durationInSeconds), () {
    timer.cancel();
    stdout.write('\r$message Done!\n');
  });
}
