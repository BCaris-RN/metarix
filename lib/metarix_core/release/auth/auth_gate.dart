import 'package:flutter/widgets.dart';

import 'app_session_controller.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    required this.controller,
    required this.child,
    super.key,
  });

  final AppSessionController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return child;
      },
    );
  }
}

