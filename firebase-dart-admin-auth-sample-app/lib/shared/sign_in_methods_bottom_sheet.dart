import 'package:dart_admin_auth_sample_app/screens/sign_in_with_credential/sign_in_with_credential.dart';
import 'package:dart_admin_auth_sample_app/screens/sign_in_with_email_and_password_screen/sign_in_with_email_and_password_screen.dart';
import 'package:dart_admin_auth_sample_app/screens/sign_in_with_email_link_screen/sign_in_with_email_link_screen.dart';
import 'package:dart_admin_auth_sample_app/screens/sign_in_with_phone_number_screen/sign_in_with_phone_number_screen.dart';
import 'package:dart_admin_auth_sample_app/shared/shared.dart';
import 'package:dart_admin_auth_sample_app/utils/extensions.dart';
import 'package:flutter/material.dart';

void showSignMethodsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => const SignInMethodsBottomSheet(),
  );
}

class SignInMethodsBottomSheet extends StatelessWidget {
  const SignInMethodsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A0DAD), Color(0xFF4B0082)], // Purple gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ), // Rounded corners for the top of the bottom sheet
      ),
      padding: const EdgeInsets.all(20), // Consistent padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Adjusts height to content
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ActionTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignInWithEmailAndPasswordScreen(),
              ),
            ),
            title: "Sign In With Email&Password",
          ),
          20.vSpace,
          ActionTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignInWithPhoneNumberScreen(),
              ),
            ),
            title: "Sign In With Phone Number",
          ),
          20.vSpace,
          ActionTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignInWithEmailLinkScreen(),
              ),
            ),
            title: "Sign In With Email Link",
          ),
          20.vSpace,
          ActionTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignInWithCredential(),
              ),
            ),
            title: "Sign In With Credential",
          ),
        ],
      ),
    );
  }
}
