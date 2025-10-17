import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vantra_mobile/components/home/home_header.dart';
import 'package:vantra_mobile/components/home/home_content.dart';
import 'package:vantra_mobile/components/home/home_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = 'Farmer';
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  bool _isDisposed = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    if (_isDisposed) return;

    try {
      final user = _auth.currentUser;
      if (user == null || _isDisposed) return;

      _userSubscription?.cancel();

      _userSubscription = _firestore
          .collection('farmers')
          .doc(user.uid)
          .snapshots()
          .listen(
            (DocumentSnapshot snapshot) {
              if (_isDisposed) return;

              if (snapshot.exists) {
                final data = snapshot.data() as Map<String, dynamic>? ?? {};
                if (!_isDisposed) {
                  setState(() {
                    username = data['username'] ?? 'Farmer';
                  });
                }
              }
            },
            onError: (error) {
              if (!_isDisposed) {
                setState(() {
                  username = 'Farmer';
                });
              }
            },
          );
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          username = 'Farmer';
        });
      }
    }
  }

  void _handleProfilePressed() {
    // Navigate to profile screen
    print('Navigate to profile');
  }

  void _handleSettingsPressed() {
    // Navigate to settings screen
    print('Navigate to settings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            HomeHeader(
              username: username,
              onProfilePressed: _handleProfilePressed,
              onSettingsPressed: _handleSettingsPressed,
            ),
            const HomeContent(),
          ],
        ),
      ),
    );
  }
}