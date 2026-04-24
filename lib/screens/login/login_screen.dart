import 'package:flutter/material.dart';

import '../../metarix_core/release/auth/app_session_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.controller, super.key});

  final AppSessionController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _workspaceController =
      TextEditingController(text: 'Demo Workspace');

  @override
  void dispose() {
    _workspaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final session = widget.controller.session;
          final status = widget.controller.isLoading
              ? 'Loading session...'
              : session == null
                  ? 'Not signed in'
                  : session.isExpired
                      ? 'Session expired'
                      : 'Signed in';

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                if (widget.controller.errorCode != null)
                  Text(
                    '${widget.controller.errorCode}: ${widget.controller.message ?? 'Unable to complete auth.'}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                if (session != null) ...[
                  const SizedBox(height: 12),
                  Text('Workspace: ${session.workspaceName}'),
                  Text('Role: ${session.role}'),
                  Text('Token preview: ${session.accessTokenPreview}'),
                  Text('Expires: ${session.expiresAtIso}'),
                ],
                const SizedBox(height: 24),
                TextField(
                  controller: _workspaceController,
                  decoration: const InputDecoration(
                    labelText: 'Demo workspace name',
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      onPressed: widget.controller.isLoading
                          ? null
                          : () async {
                              await widget.controller.signInDemoWorkspace(
                                _workspaceController.text,
                              );
                            },
                      child: const Text('Sign in demo workspace'),
                    ),
                    OutlinedButton(
                      onPressed: widget.controller.isLoading || session == null
                          ? null
                          : widget.controller.logout,
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

