// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/material.dart';

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key});
  @override
  State<UpdateUserScreen> createState() => UpdateUserScreenState();
}

class UpdateUserScreenState extends State<UpdateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FirebaseApp auth = FirebaseApp.instance;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = auth.getCurrentUser();

        if (user != null) {
          FirebaseApp.firebaseAuth
              ?.updateUserInformation(user.uid, user.idToken!, {
                'email': _emailController.text,
                'phoneNumber': _phoneNumberController.text,
                'password': _passwordController.text,
                'displayName': _displayNameController.text,
              });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User details updated successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update user: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update User Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your display name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
