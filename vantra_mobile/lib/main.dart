import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:vantra_mobile/screens/farmer_home.dart';
import 'package:vantra_mobile/screens/financials.dart';
import 'package:vantra_mobile/screens/settings_screen.dart';
import 'package:vantra_mobile/screens/tasks_screen.dart';
import 'package:vantra_mobile/screens/home_screen.dart';
import 'package:vantra_mobile/screens/aggregator_home_screen.dart'; // Add this import
import 'package:vantra_mobile/widgets/splash_screen.dart';
import 'package:vantra_mobile/widgets/template.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<bool> _isDarkMode = ValueNotifier<bool>(false);

  void _toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isDarkMode,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'VanTra Mobile',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: AuthWrapper(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
          routes: {
            '/home': (context) => HomeScreen(),
            '/farmer': (context) => FarmerHomeScreen(),
            '/financials': (context) => FinancialsScreen(),
            '/aggregator': (context) => AggregatorHomeScreen(), // Fixed this line
            '/transporter': (context) => SettingsScreen(
                  toggleTheme: _toggleTheme,
                  isDarkMode: _isDarkMode,
                ),
            '/processor': (context) => TasksScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final Function toggleTheme;
  final ValueNotifier<bool> isDarkMode;

  const AuthWrapper({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          if (user == null) {
            return SplashScreen();
          }

          // Check user role and navigate accordingly
          if (user.email?.endsWith('@farmer.com') ?? false) {
            return FarmerHomeScreen();
          } else if (user.email?.endsWith('@aggregator.com') ?? false) {
            return AggregatorHomeScreen(); // Fixed this line
          } else {
            return Template(); // Fixed this line - removed Navigator
          }
        }

        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}