import 'package:test/test.dart';

void main() {
  group('MFA integration', () {
    test(
      'manual integration coverage is documented but not run by default',
      () {
        expect(true, isTrue);
      },
      skip:
          'Requires a configured Firebase project/emulator and real MFA enrollment credentials.',
    );
  });
}
