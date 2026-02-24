// ignore_for_file: library_private_types_in_public_apipublic_member_api_docs uri_does_not_exist undefined_class undefined_function undefined_identifier undefined_method undefined_getter creation_with_non_type extends_non_class super_formal_parameter_without_associated_named undefined_super_member override_on_non_overriding_member non_type_as_type_argument non_constant_list_element unchecked_use_of_nullable_value

import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:firebase/shared/shared.dart';
import 'package:provider/provider.dart';

class ConnectAuthEmulatorScreen extends StatefulWidget {
  const ConnectAuthEmulatorScreen({super.key});

  @override
  _ConnectAuthEmulatorScreenState createState() =>
      _ConnectAuthEmulatorScreenState();
}

class _ConnectAuthEmulatorScreenState extends State<ConnectAuthEmulatorScreen> {
  final TextEditingController _hostController = TextEditingController(
    text: 'localhost',
  );
  final TextEditingController _portController = TextEditingController(
    text: '9099',
  );
  String _result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Auth Emulator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InputField(
              controller: _hostController,
              hint: 'Enter host',
              label: 'Host',
            ),
            const SizedBox(height: 10),
            InputField(
              controller: _portController,
              hint: 'Enter port',
              label: 'Port',
              textInputType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Button(onTap: _connectToEmulator, title: 'Connect to Emulator'),
            const SizedBox(height: 20),
            Text(_result, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _connectToEmulator() {
    final host = _hostController.text;
    final port = int.tryParse(_portController.text) ?? 9099;

    try {
      final auth = Provider.of<FirebaseAuth>(context, listen: false);
      auth.connectAuthEmulator(host, port);
      setState(() {
        _result = 'Connected to Auth Emulator at $host:$port';
      });
    } catch (e) {
      setState(() {
        _result = 'Error connecting to Auth Emulator: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
