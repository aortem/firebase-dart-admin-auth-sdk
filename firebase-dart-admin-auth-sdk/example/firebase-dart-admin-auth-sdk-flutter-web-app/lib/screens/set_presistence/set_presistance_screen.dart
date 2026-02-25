// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'dart:developer';

import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/material.dart';

import 'firebase_presistance.dart';

/// A dropdown widget for selecting the Firebase Auth persistence type.
class PersistenceSelectorDropdown extends StatefulWidget {
  /// Constructs the [PersistenceSelectorDropdown] widget.
  const PersistenceSelectorDropdown({super.key});

  @override
  State<PersistenceSelectorDropdown> createState() =>
      _PersistenceSelectorDropdownState();
}

class _PersistenceSelectorDropdownState
    extends State<PersistenceSelectorDropdown> {
  String? _selectedPersistence;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownButton<String>(
          value: _selectedPersistence,
          hint: const Text('Choose Persistence Option'),
          onChanged: (String? newValue) async {
            setState(() {
              _selectedPersistence = newValue;
            });
            if (newValue != null) {
              if (_selectedPersistence != null) {
                try {
                  await FirebaseApp.firebaseAuth?.setPresistanceMethod(
                    _selectedPersistence!,
                    'firebasdartadminauthsdk',
                  );
                  //  log("response of pressitance $response");
                } catch (e) {
                  log("response of pressitance $e");
                }
              }
            }
          },
          items: const [
            DropdownMenuItem(
              value: FirebasePersistence.local,
              child: Text('Local'),
            ),
            DropdownMenuItem(
              value: FirebasePersistence.session,
              child: Text('Session'),
            ),
            DropdownMenuItem(
              value: FirebasePersistence.none,
              child: Text('None'),
            ),
          ],
        ),
      ),
    );
  }
}
