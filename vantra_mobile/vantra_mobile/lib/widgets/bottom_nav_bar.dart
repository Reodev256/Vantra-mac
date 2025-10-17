import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:vantra_mobile/screens/home_screen.dart';

void main() => runApp(MaterialApp(home: BottomNavBar()));

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        items: <Widget>[
          Icon(Icons.home, size: 30), // Home
          Icon(Icons.attach_money, size: 30), // Transactions
          Icon(Icons.check_circle, size: 30), // Tasks
          Icon(Icons.business, size: 30), // Aggregator
          Icon(Icons.settings, size: 30), // Settings
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = 0; // Force navigation to HomeScreen only
          });
        },
        letIndexChange: (index) => true,
      ),
      body: HomeScreen(), // Always display HomeScreen
    );
  }
}
