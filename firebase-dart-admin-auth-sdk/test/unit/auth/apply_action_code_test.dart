import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:firebase_dart_admin_auth_sdk/src/action_code_settings.dart';

void main() {
  group('ActionCodeSettings', () {
    test('creates an instance with required parameters', () {
      final settings = ActionCodeSettings(url: 'https://example.com');

      expect(settings.url, 'https://example.com');
      expect(settings.handleCodeInApp, isFalse);
      expect(settings.iOSBundleId, isNull);
      expect(settings.androidPackageName, isNull);
      expect(settings.androidInstallApp, isNull);
      expect(settings.androidMinimumVersion, isNull);
      expect(settings.dynamicLinkDomain, isNull);
    });

    test('converts non-null values to map', () {
      final settings = ActionCodeSettings(
        url: 'https://example.com',
        handleCodeInApp: true,
        iOSBundleId: 'com.example.ios',
        androidPackageName: 'com.example.android',
        androidInstallApp: true,
        androidMinimumVersion: '1.0.0',
        dynamicLinkDomain: 'example.page.link',
      );

      expect(settings.toMap(), {
        'url': 'https://example.com',
        'handleCodeInApp': true,
        'iOSBundleId': 'com.example.ios',
        'androidPackageName': 'com.example.android',
        'androidInstallApp': true,
        'androidMinimumVersion': '1.0.0',
        'dynamicLinkDomain': 'example.page.link',
      });
    });
  });

  group('IOSSettings', () {
    test('stores the bundle id', () {
      final iosSettings = IOSSettings(bundleId: 'com.example.ios');

      expect(iosSettings.bundleId, 'com.example.ios');
    });
  });

  group('AndroidSettings', () {
    test('creates an instance with required parameters', () {
      final androidSettings = AndroidSettings(
        packageName: 'com.example.android',
      );

      expect(androidSettings.packageName, 'com.example.android');
      expect(androidSettings.installApp, isNull);
      expect(androidSettings.minimumVersion, isNull);
    });

    test('creates an instance with optional parameters', () {
      final androidSettings = AndroidSettings(
        packageName: 'com.example.android',
        installApp: true,
        minimumVersion: '2.0.0',
      );

      expect(androidSettings.packageName, 'com.example.android');
      expect(androidSettings.installApp, isTrue);
      expect(androidSettings.minimumVersion, '2.0.0');
    });
  });
}
