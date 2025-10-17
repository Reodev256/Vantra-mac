// widgets/logout_button.dart
import 'package:flutter/material.dart';
import 'package:vantra_mobile/services/auth_service.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () => AuthService.logoutWithConfirmation(context),
    );
  }
}