// widgets/logout_card.dart
import 'package:flutter/material.dart';
import 'package:vantra_mobile/services/auth_service.dart';

class LogoutCard extends StatelessWidget {
  const LogoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: Colors.red[50], // Light red background
      child: ListTile(
        leading: Icon(
          Icons.logout,
          color: Colors.red[700],
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.red[700],
          size: 16,
        ),
        onTap: () => AuthService.logoutWithConfirmation(context),
      ),
    );
  }
}