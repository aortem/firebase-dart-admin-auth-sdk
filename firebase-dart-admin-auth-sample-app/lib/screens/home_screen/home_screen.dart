import 'package:dart_admin_auth_sample_app/shared/shared.dart';
import 'package:dart_admin_auth_sample_app/utils/extensions.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Increased height
        child: AppBar(
          backgroundColor: const Color(0xFF6A0DAD), // Matches gradient start color
          elevation: 0, // Flat app bar
          centerTitle: true,
          foregroundColor: Colors.white, // Centered title
          title: const Text(
            'Test App',
            style: TextStyle(
              fontSize: 24, // Larger font size
              fontWeight: FontWeight.bold, // Bold text
              color: Colors.white,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1), // Divider thickness
            child: Container(
              color: Colors.white.withOpacity(0.5), // Divider color
              height: 1,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A0DAD), Color(0xFF4B0082)], // Purple gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // Smooth scrolling
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height, // Full page height
              ),
              child: Padding(
                padding: const EdgeInsets.all(20), // Consistent padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ActionTile(
                      onTap: () {},
                      title: "Verify Before Update Email",
                    ),
                    10.vSpace,
                    ActionTile(
                      onTap: () {},
                      title: "Update Profile",
                    ),
                    10.vSpace,
                    ActionTile(
                      onTap: () {},
                      title: "Update Password",
                    ),
                    10.vSpace,
                    ActionTile(
                      onTap: () {},
                      title: "Send Verification Email",
                    ),
                    10.vSpace,
                    ActionTile(
                      onTap: () {},
                      title: "Send Password Reset Email",
                    ),
                    10.vSpace,
                    ActionTile(
                      onTap: () {},
                      title: "Sign Out",
                    ),
                    10.vSpace,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}