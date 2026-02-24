// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase/screens/home_screen/home_screen.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'sign_in_with_credential_view_model.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class SignInWithCredential extends StatelessWidget {
  const SignInWithCredential({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MicrosoftSignIn(),
      child: Consumer<MicrosoftSignIn>(
        builder: (context, value, child) => Scaffold(
          body: SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    value.signInWithGoogle(
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Text("Sign In With Google"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    value.loginWithFacebook(context);
                  },
                  child: const Text("Sign In With Facebook"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    value.signInWithMicrosoft(kIsWeb ? true : false, context);
                  },
                  child: const Text("Sign In With Microsoft"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
