import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantra_mobile/widgets/splash_screen.dart';
import 'package:vantra_mobile/screens/onboarding_screens.dart';
import 'package:vantra_mobile/widgets/logout_confirmation_dialog.dart';
import 'package:vantra_mobile/components/settings/profile_details.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ValueNotifier<bool> isDarkMode;

  const SettingsScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkOnboardingStatus();
  }

  void _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    _currentUser = _auth.currentUser;
    
    if (_currentUser != null) {
      try {
        final doc = await _firestore
            .collection('farmers')
            .doc(_currentUser!.uid)
            .get();
        
        if (doc.exists) {
          setState(() {
            _userData = doc.data()!;
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboardingCompleted') ?? false;
    
    if (!completed && _currentUser != null) {
      try {
        final doc = await _firestore
            .collection('farmers')
            .doc(_currentUser!.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          final firestoreCompleted = data['onboardingCompleted'] ?? false;
          setState(() {
            _onboardingCompleted = firestoreCompleted;
          });
          
          if (firestoreCompleted) {
            await prefs.setBool('onboardingCompleted', true);
          }
        }
      } catch (e) {
        print('Error checking onboarding status: $e');
      }
    } else {
      setState(() {
        _onboardingCompleted = completed;
      });
    }
  }

  void _navigateToOnboarding() {
    if (_currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreens.getOnboardingWrapper(
            farmerId: _currentUser!.uid,
            email: _currentUser!.email ?? '',
            fullName: _userData?['fullName'] ?? '',
            userName: _userData?['username'] ?? _currentUser!.email!.split('@').first,
          ),
        ),
      ).then((_) {
        // Reload data when returning from onboarding
        _loadUserData();
        _checkOnboardingStatus();
      });
    }
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userData?['fullName']?.isNotEmpty == true 
                        ? _userData!['fullName']
                        : 'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _currentUser?.email ?? 'No email',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (_userData?['location'] != null)
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          _userData!['location'],
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadUserData,
              icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingReminder() {
    if (_onboardingCompleted || _isLoading) return SizedBox();

    return Card(
      elevation: 4.0,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Finish setting up your farm profile to unlock all features and personalized recommendations.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('Complete Setup Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.refresh),
        //     onPressed: _loadUserData,
        //   ),
        // ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(),
                  
                  SizedBox(height: 20),
                  
                  // Onboarding Reminder
                  _buildOnboardingReminder(),
                  
                  SizedBox(height: 20),

                  // Account Settings
                  _buildSettingsSection(
                    'ACCOUNT SETTINGS',
                    [
                      _buildSettingItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileDetailsPage(),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1),
                      _buildSettingItem(
                        icon: Icons.security,
                        title: 'Privacy & Security',
                        subtitle: 'Manage your privacy settings',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Privacy Settings - Coming Soon')),
                          );
                        },
                      ),
                      Divider(height: 1),
                      _buildSettingItem(
                        icon: Icons.notifications_active,
                        title: 'Notifications',
                        subtitle: 'Configure notification preferences',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Notification Settings - Coming Soon')),
                          );
                        },
                      ),
                    ],
                  ),

                  // App Preferences
                  _buildSettingsSection(
                    'APP PREFERENCES',
                    [
                      _buildSettingItem(
                        icon: widget.isDarkMode.value 
                            ? Icons.dark_mode 
                            : Icons.light_mode,
                        title: 'Dark Mode',
                        subtitle: widget.isDarkMode.value 
                            ? 'Dark theme enabled' 
                            : 'Light theme enabled',
                        trailing: Switch(
                          value: widget.isDarkMode.value,
                          onChanged: (value) => widget.toggleTheme(),
                        ),
                        iconColor: widget.isDarkMode.value 
                            ? Colors.amber 
                            : Colors.blue,
                      ),
                      Divider(height: 1),
                      _buildSettingItem(
                        icon: Icons.language,
                        title: 'Language',
                        subtitle: 'English (US)',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Language Settings - Coming Soon')),
                          );
                        },
                      ),
                    ],
                  ),

                  // Farm Management
                  if (_userData?['farmSize'] != null || _userData?['mainCrops'] != null)
                    _buildSettingsSection(
                      'FARM MANAGEMENT',
                      [
                        if (_userData?['farmSize'] != null)
                          _buildSettingItem(
                            icon: Icons.agriculture,
                            title: 'Farm Size',
                            subtitle: _userData!['farmSize'],
                          ),
                        if (_userData?['farmSize'] != null && _userData?['mainCrops'] != null)
                          Divider(height: 1),
                        if (_userData?['mainCrops'] != null)
                          _buildSettingItem(
                            icon: Icons.spa,
                            title: 'Main Crops',
                            subtitle: _userData!['mainCrops'],
                          ),
                        Divider(height: 1),
                        _buildSettingItem(
                          icon: Icons.edit,
                          title: 'Update Farm Details',
                          onTap: _navigateToOnboarding,
                        ),
                      ],
                    ),

                  // Support & About
                  _buildSettingsSection(
                    'SUPPORT & ABOUT',
                    [
                      _buildSettingItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Help & Support - Coming Soon')),
                          );
                        },
                      ),
                      Divider(height: 1),
                      _buildSettingItem(
                        icon: Icons.info_outline,
                        title: 'About Vantra Mobile',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Vantra Mobile',
                            applicationVersion: '1.0.0',
                            applicationIcon: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Icon(Icons.agriculture, color: Colors.white),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1),
                      _buildSettingItem(
                        icon: Icons.privacy_tip,
                        title: 'Privacy Policy',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Privacy Policy - Coming Soon')),
                          );
                        },
                      ),
                    ],
                  ),

                  // Danger Zone
                  _buildSettingsSection(
                    'ACCOUNT MANAGEMENT',
                    [
                      _buildSettingItem(
                        icon: Icons.delete_outline,
                        title: 'Delete Account',
                        subtitle: 'Permanently delete your account and data',
                        iconColor: Colors.red,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Account Deletion - Coming Soon')),
                          );
                        },
                      ),
                      Divider(height: 1),
                      _buildSettingItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        iconColor: Colors.red,
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => LogoutConfirmationDialog(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}