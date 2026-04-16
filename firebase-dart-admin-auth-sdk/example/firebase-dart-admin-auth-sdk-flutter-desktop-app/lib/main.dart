import 'dart:io';

import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FirebaseAdminDesktopExampleApp());
}

class FirebaseAdminDesktopExampleApp extends StatelessWidget {
  const FirebaseAdminDesktopExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Admin Desktop Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D5C63),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F1EA),
        useMaterial3: true,
      ),
      home: const AdminToolHome(),
    );
  }
}

class AdminToolHome extends StatefulWidget {
  const AdminToolHome({super.key});

  @override
  State<AdminToolHome> createState() => _AdminToolHomeState();
}

class _AdminToolHomeState extends State<AdminToolHome> {
  final TextEditingController _serviceAccountPathController =
      TextEditingController();
  final TextEditingController _uidController = TextEditingController();

  bool _initializing = false;
  bool _lookingUpUser = false;
  bool _initialized = false;
  String _status =
      'Enter a local service-account JSON path to initialize the admin SDK.';
  String? _userSummary;

  @override
  void dispose() {
    _serviceAccountPathController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  Future<void> _initializeWithServiceAccount() async {
    final path = _serviceAccountPathController.text.trim();
    if (path.isEmpty) {
      setState(() {
        _status = 'Enter a service-account JSON file path first.';
      });
      return;
    }

    setState(() {
      _initializing = true;
      _userSummary = null;
      _status = 'Reading service-account JSON and initializing Firebase...';
    });

    try {
      final jsonContent = await File(path).readAsString();
      await FirebaseApp.initializeAppWithServiceAccount(
        serviceAccountContent: jsonContent,
      );

      FirebaseApp.instance.getAuth();
      setState(() {
        _initialized = true;
        _status =
            'Firebase admin app initialized. You can now look up a user by UID.';
      });
    } catch (error) {
      setState(() {
        _initialized = false;
        _status = 'Initialization failed: $error';
      });
    } finally {
      setState(() {
        _initializing = false;
      });
    }
  }

  Future<void> _lookupUserByUid() async {
    final uid = _uidController.text.trim();
    if (!_initialized) {
      setState(() {
        _status = 'Initialize Firebase first.';
      });
      return;
    }
    if (uid.isEmpty) {
      setState(() {
        _status = 'Enter a Firebase UID to look up.';
      });
      return;
    }

    setState(() {
      _lookingUpUser = true;
      _status = 'Looking up Firebase user...';
    });

    try {
      final user = await FirebaseApp.instance.getAuth().getUserByUid(uid);
      if (user == null) {
        setState(() {
          _userSummary = null;
          _status = 'No Firebase user was found for UID "$uid".';
        });
        return;
      }
      setState(() {
        _userSummary =
            'UID: ${user.uid}\nEmail: ${user.email ?? 'n/a'}\n'
            'Display Name: ${user.displayName ?? 'n/a'}\n'
            'Disabled: ${user.disabled ?? false}';
        _status = 'User lookup completed.';
      });
    } catch (error) {
      setState(() {
        _userSummary = null;
        _status = 'User lookup failed: $error';
      });
    } finally {
      setState(() {
        _lookingUpUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminPanel = _Panel(
      title: 'Admin Initialization',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _serviceAccountPathController,
            decoration: const InputDecoration(
              labelText: 'Service account JSON path',
              hintText: r'C:\keys\firebase-admin-service-account.json',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _initializing ? null : _initializeWithServiceAccount,
            icon: _initializing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.security),
            label: Text(
              _initializing ? 'Initializing...' : 'Initialize Admin SDK',
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Lookup a Firebase user by UID',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _uidController,
            decoration: const InputDecoration(
              labelText: 'Firebase UID',
              hintText: 'Enter a Firebase user UID',
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _lookingUpUser ? null : _lookupUserByUid,
            icon: _lookingUpUser
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_search),
            label: Text(_lookingUpUser ? 'Looking up...' : 'Lookup User'),
          ),
        ],
      ),
    );
    final statusPanel = _Panel(
      title: 'Status',
      child: SelectableText(
        _status,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
    final resultPanel = _Panel(
      title: 'Result',
      child: SelectableText(
        _userSummary ?? 'No user lookup has been completed yet.',
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useWideLayout = constraints.maxWidth >= 920;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Firebase Admin Desktop Sample',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Local desktop demo for backend/admin Firebase flows. '
                        'Use this for development tooling, not as a pattern for '
                        'shipping privileged credentials to end users.',
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      if (useWideLayout)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: adminPanel),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  statusPanel,
                                  const SizedBox(height: 24),
                                  resultPanel,
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            adminPanel,
                            const SizedBox(height: 24),
                            statusPanel,
                            const SizedBox(height: 24),
                            resultPanel,
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9D2C3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
