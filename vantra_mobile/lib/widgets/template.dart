import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:vantra_mobile/screens/home_screen.dart';
import 'package:vantra_mobile/screens/transactions_screen.dart';
import 'package:vantra_mobile/screens/financials.dart';
import 'package:vantra_mobile/screens/settings_screen.dart';
import 'package:vantra_mobile/screens/tasks_screen.dart';

class Template extends StatefulWidget {
  const Template({super.key});

  @override
  _TemplateState createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
  int _currentIndex = 0; // Track the selected index
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey =
      GlobalKey(); // Key for CurvedNavigationBar

  // ValueNotifier to manage dark mode state
  final ValueNotifier<bool> _isDarkMode = ValueNotifier<bool>(false);

  // Function to toggle dark mode
  void _toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(),
      TransactionsScreen(),
      TasksScreen(),
      FinancialsScreen(),
      SettingsScreen(
        toggleTheme: _toggleTheme,
        isDarkMode: _isDarkMode, // Pass the ValueNotifier directly
      ),
    ];

    return ValueListenableBuilder<bool>(
      valueListenable: _isDarkMode,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme:
              isDarkMode ? ThemeData.dark() : ThemeData.light(), // Apply theme
          home: Scaffold(
            body: screens[_currentIndex], // Render the selected screen

            bottomNavigationBar: CurvedNavigationBar(
              key: _bottomNavigationKey,
              index: _currentIndex,
              items: <Widget>[
                Icon(Icons.home_rounded, size: 30, color: Colors.white),
                Icon(Icons.attach_money_rounded, size: 30, color: Colors.white),
                Icon(Icons.check_circle_rounded, size: 30, color: Colors.white),
                Icon(Icons.handshake_rounded, size: 30, color: Colors.white),
                Icon(Icons.settings_rounded, size: 30, color: Colors.white),
              ],
              color: const Color.fromARGB(255, 49, 120, 51), // Green background
              buttonBackgroundColor: const Color.fromARGB(
                255,
                49,
                120,
                51,
              ), // Make button match background
              backgroundColor: Colors.transparent, // Transparent part
              animationCurve: Curves.easeInOut,
              animationDuration: Duration(milliseconds: 600),
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              letIndexChange: (index) => true,
            ),
          ),
        );
      },
    );
  }
}
