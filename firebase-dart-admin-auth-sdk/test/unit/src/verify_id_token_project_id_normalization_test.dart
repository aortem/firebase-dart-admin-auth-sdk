import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:test/test.dart';
import '../../helpers/signed_id_token.dart';

void main() {
  test(
    'verifyIdToken tolerates BOM and trailing whitespace in configured projectId',
    () async {
      final client = CertificateClient();
      addTearDown(client.close);
      final auth = FirebaseAuth(
        projectId: '\uFEFFdemo-project\r\n',
        httpClient: client,
      );
      final decoded = await auth.verifyIdToken(signedToken());
      expect(decoded['uid'], 'user-123');
      expect(auth.projectId, 'demo-project');
    },
  );
}
