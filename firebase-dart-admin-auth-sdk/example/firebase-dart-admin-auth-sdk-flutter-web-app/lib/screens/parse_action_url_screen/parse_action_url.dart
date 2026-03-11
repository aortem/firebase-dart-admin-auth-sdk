// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../shared/button.dart';
import '../../shared/input_field.dart';

/// A screen for parsing action codes from a URL.
class ParseActionUrl extends StatefulWidget {
  /// Constructs the [ParseActionUrl] widget.
  const ParseActionUrl({super.key});

  @override
  State<ParseActionUrl> createState() => _ParseActionUrlState();
}

class _ParseActionUrlState extends State<ParseActionUrl> {
  final TextEditingController parseActionUrlController =
      TextEditingController();
  Map<String, String>? parseUrlResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputField(
                controller: parseActionUrlController,
                label: 'Parse Link',
                hint: '',
              ),
              const SizedBox(height: 20),
              Button(
                onTap: () async {
                  String actionCodeUrl = parseActionUrlController.text;

                  parseUrlResult = await FirebaseApp.firebaseAuth
                      ?.parseActionCodeUrl(actionCodeUrl);

                  if (parseUrlResult != null) {
                    if (kDebugMode) {
                      print(" Mode: ${parseUrlResult!['mode']}");
                      print("OobCode: ${parseUrlResult!['oobCode']}");
                      print("  ContinueUrl: ${parseUrlResult!['continueUrl']}");
                      print(" Lang: ${parseUrlResult!['lang']}");
                    }
                  } else {
                    if (kDebugMode) {
                      print("  Invalid action code URL.");
                    }
                  }

                  setState(() {}); // Refresh the UI
                },
                title: 'Submit',
              ),
              const SizedBox(height: 20),
              parseUrlResult == null
                  ? const SizedBox()
                  : Column(
                      children: [
                        Row(
                          children: [
                            const Text('code: '),
                            Text(parseUrlResult!['code'] ?? 'N/A'),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('apiKey: '),
                            Text(parseUrlResult!['apiKey'] ?? 'N/A'),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('mode: '),
                            Text(parseUrlResult!['mode'] ?? 'N/A'),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('continueUrl: '),
                            Text(parseUrlResult!['continueUrl'] ?? 'N/A'),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('languageCode: '),
                            Text(parseUrlResult!['languageCode'] ?? 'N/A'),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('clientId: '),
                            Text(parseUrlResult!['clientId'] ?? 'N/A'),
                          ],
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
