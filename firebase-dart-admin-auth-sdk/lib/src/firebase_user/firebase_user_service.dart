import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils.dart'; // Import showSpinner from utils

class FirebaseUserService {
  final String apiUrl =
      'https://your-api-endpoint/users'; 

  /// Fetch users from the backend API
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    showSpinner('Fetching users', 3); // Show spinner while fetching
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  /// Sort users by a specific field
  List<Map<String, dynamic>> sortUsers(
      List<Map<String, dynamic>> users, String field) {
    users.sort((a, b) => a[field].compareTo(b[field]));
    return users;
  }

  /// Filter users based on a query string
  List<Map<String, dynamic>> filterUsers(
      List<Map<String, dynamic>> users, String query) {
    return users
        .where((user) =>
            user['name'].toLowerCase().contains(query.toLowerCase()) ||
            user['email'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
