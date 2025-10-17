import 'package:flutter/material.dart';
import 'package:vantra_mobile/services/auth_service.dart';

class HomeAppBar extends StatelessWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onSettingsPressed;
  final String username;

  const HomeAppBar({
    super.key,
    required this.onProfilePressed,
    required this.onSettingsPressed,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Text('Profile'),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Text('Settings'),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Text('Logout'),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'profile':
            onProfilePressed();
            break;
          case 'settings':
            onSettingsPressed();
            break;
          case 'logout':
            // Use the confirmation dialog
            AuthService.logoutWithConfirmation(context);
            break;
        }
      },
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person,
          size: 35,
          color: const Color(0xFF41754E),
        ),
      ),
    );
  }
}