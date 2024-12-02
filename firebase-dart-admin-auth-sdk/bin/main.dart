import 'package:firebase_dart_admin_auth_sdk/src/firebase_auth.dart';
import 'package:firebase_dart_admin_auth_sdk/src/firebase_user/firebase_user_service.dart';
import 'package:firebase_dart_admin_auth_sdk/src/utils.dart';
import '../../utils.dart'; // Import the spinner function


void main() async {
  final auth =
      FirebaseAuth(apiKey: 'YOUR_API_KEY', projectId: 'YOUR_PROJECT_ID');
  final userService = FirebaseUserService(); // Initialize the user service

  try {
    // Display a spinner while initializing Firebase Auth
    showSpinner('Initializing Firebase Auth', 3);

    // Sign up a new user
    final newUser = await auth.createUserWithEmailAndPassword(
        'newuser@aortem.com', 'password123');
    print('User created: ${newUser.user.displayName}');
    print('User created: ${newUser.user.email}');

    // Sign in with the new user
    final userCredential = await auth.signInWithEmailAndPassword(
        'newuser@aortem.com', 'password123');
    print('Signed in: ${userCredential?.user.email}');

    // Fetch users
    print('Fetching users...');
    final users = await userService.fetchUsers();
    print('Fetched ${users.length} users.');

    // Sort users by name
    print('Sorting users by name...');
    final sortedUsers = userService.sortUsers(users, 'name');
    for (final user in sortedUsers) {
      print('Name: ${user['name']}, Email: ${user['email']}');
    }

    // Filter users with query 'john'
    print('Filtering users with query "john"...');
    final filteredUsers = userService.filterUsers(users, 'john');
    for (final user in filteredUsers) {
      print('Filtered - Name: ${user['name']}, Email: ${user['email']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
