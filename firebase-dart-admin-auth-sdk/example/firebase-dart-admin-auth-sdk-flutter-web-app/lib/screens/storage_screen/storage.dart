// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// Your Firebase SDK

class StorageExample extends StatefulWidget {
  const StorageExample({super.key});

  @override
  State<StorageExample> createState() => _StorageExampleState();
}

class _StorageExampleState extends State<StorageExample> {
  final FirebaseStorage storage = FirebaseApp.instance.getStorage();
  Uint8List? fileBytes; // File data
  String? fileName; // File name

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        fileBytes = kIsWeb
            ? result.files.single.bytes
            : await result.files.single.readStream!.toList().then(
                (parts) => Uint8List.fromList(parts.expand((x) => x).toList()),
              );
        fileName = result.files.single.name;
        setState(() {});
      } else {
        if (kDebugMode) {
          print('No file selected');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking file: $e');
      }
    }
  }

  Future<void> uploadFile() async {
    if (fileBytes != null && fileName != null) {
      try {
        await storage.uploadFile(
          'uploads/$fileName',
          fileBytes!,
          //Set appropriate MIME type based on file
        );
        if (kDebugMode) {
          print("File uploaded successfully");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Failed to upload file: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print('No file selected or file data is empty');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Storage Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickFile,
              child: const Text('Pick a File'),
            ),
            const SizedBox(height: 20),
            if (fileName != null) Text('Picked File: $fileName'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadFile,
              child: const Text('Upload File to Firebase Storage'),
            ),
          ],
        ),
      ),
    );
  }
}
