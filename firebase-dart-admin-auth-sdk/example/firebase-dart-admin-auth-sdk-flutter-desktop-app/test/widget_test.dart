import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_admin_desktop_example/main.dart';

void main() {
  testWidgets('desktop sample renders admin shell', (WidgetTester tester) async {
    await tester.pumpWidget(const FirebaseAdminDesktopExampleApp());

    expect(find.text('Firebase Admin Desktop Sample'), findsOneWidget);
    expect(find.text('Initialize Admin SDK'), findsOneWidget);
    expect(find.text('Lookup User'), findsOneWidget);
  });
}
