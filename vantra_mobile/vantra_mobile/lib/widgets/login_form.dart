import 'package:vantra_mobile/components/onboarding/onboarding_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantra_mobile/screens/home_screen.dart';
import 'package:vantra_mobile/widgets/custom_snackbar.dart';
import 'package:vantra_mobile/widgets/template.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vantra_mobile/screens/onboarding_screens.dart';

class LoginForm extends StatefulWidget {
  final Function(double) onHeightChange; // Callback to change height

  const LoginForm({super.key, required this.onHeightChange});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final _emailController =
      TextEditingController(); // Controller for email input
  final _passwordController =
      TextEditingController(); // Controller for password input
  final _fullNameController =
      TextEditingController(); // Controller for full name input
  final _userNameController =
      TextEditingController(); // Controller for user name input
  bool _obscurePassword = true; // Track password visibility
  bool _isLoading = false; // Track loading state
  bool _rememberMe = false; // Track "Remember Me" state

  // Define custom colors
  final Color customGreen = Color(0xFF41754E); // #41754e
  final Color lightGreen = Color(0xFFDBE6DE); // #dbe6de

  // Track current card content
  String _currentCardContent =
      'login'; // 'login', 'forgotPassword', or 'signUp'

  @override
  void initState() {
    super.initState();
    // Load saved credentials if "Remember Me" was checked
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  // Load saved email and password
  void _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  // Save email and password if "Remember Me" is checked
  void _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('rememberMe');
    }
  }

  // Login function
void _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      // Sign in with Firebase
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

      // Get farmer details from Firestore
      final farmerDoc = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(userCredential.user!.uid)
          .get();

      if (!farmerDoc.exists) {
        throw Exception('Farmer details not found');
      }

      final farmerData = farmerDoc.data() as Map<String, dynamic>;

      // Save credentials if "Remember Me" is checked
      _saveCredentials();

      // Save farmer data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('farmerId', farmerData['farmerId']);
      await prefs.setString('fullName', farmerData['fullName']);
      await prefs.setString('userName', farmerData['userName']);
      await prefs.setString('email', farmerData['email']);
      await prefs.setString('role', farmerData['role']);
      
      // Check if onboarding was completed
      final onboardingCompleted = farmerData['onboardingCompleted'] ?? false;
      await prefs.setBool('onboardingCompleted', onboardingCompleted);

      // Show success snackbar
      CustomSnackbar.showSuccess(context, 'Login successful!');

      // Use post-frame callback for navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!onboardingCompleted) {
          // Redirect to onboarding if not completed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OnboardingWrapper(
                farmerId: farmerData['farmerId'],
                email: farmerData['email'],
                fullName: farmerData['fullName'],
                userName: farmerData['userName'],
              ),
            ),
          );
        } else {
          // Navigate to home screen if onboarding completed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Template()),
          );
        }
      });

    } on FirebaseAuthException catch (e) {
      CustomSnackbar.showError(context, 'Login failed: ${e.message}');
    } catch (e) {
      CustomSnackbar.showError(
        context,
        'Error retrieving farmer details: $e',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

  // Forgot password function
  void _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email to reset your password.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );

      // Show success snackbar
      CustomSnackbar.showSuccess(context, 'Password reset email sent!');

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Password reset email sent!'),
      //     backgroundColor: Colors.green,
      //   ),
      // );
    } on FirebaseAuthException catch (e) {
      // Show error snackbar
      CustomSnackbar.showError(
        context,
        'Failed to send reset email: ${e.message}',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Failed to send reset email: ${e.message}'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Register function
void _register() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      // Create user with Firebase
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

      // Generate a unique farmer ID (using the Firebase UID)
      final farmerId = userCredential.user!.uid;

      // Store basic farmer details in Firestore (onboarding not completed yet)
      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(farmerId)
          .set({
            'farmerId': farmerId,
            'fullName': _fullNameController.text,
            'email': _emailController.text,
            'role': 'farmer',
            'username': _userNameController.text,
            'onboardingCompleted': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Save basic user data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('farmerId', farmerId);
      await prefs.setString('fullName', _fullNameController.text);
      await prefs.setString('userName', _userNameController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('role', 'farmer');
      await prefs.setBool('onboardingCompleted', false);

      // Show success snackbar first
      CustomSnackbar.showSuccess(context, 'Registration successful! Welcome to Vantra!');

      // Add a small delay to let the user see the success message
      await Future.delayed(Duration(milliseconds: 1500));

      // Use a post-frame callback to navigate after the current build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingWrapper(
              farmerId: farmerId,
              email: _emailController.text,
              fullName: _fullNameController.text,
              userName: _userNameController.text,
            ),
          ),
        );
      });

    } on FirebaseAuthException catch (e) {
      // Show error snackbar
      CustomSnackbar.showError(context, 'Registration failed: ${e.message}');
    } catch (e) {
      // Show error snackbar for Firestore errors
      CustomSnackbar.showError(context, 'Error saving farmer details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

  // Sign up function
  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Call the register function
        _register();
        // CustomSnackbar.showSuccess(context, 'Registration successful!');
      } catch (e) {
        // Show error snackbar
        CustomSnackbar.showError(context, 'Registration failed: $e');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Sign up failed: ${e.toString()}'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Navigate to forgot password or sign up screen
  void _navigateTo(String content) {
    setState(() {
      _currentCardContent = content;
      widget.onHeightChange(0.75); // Move card to 3/4 of the screen
    });
  }

  // Go back to login form
  void _goBackToLogin() {
    setState(() {
      _currentCardContent = 'login';
      widget.onHeightChange(0.6); // Move card back to halfway
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back Button (only for forgot password and sign up)
            if (_currentCardContent != 'login')
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: customGreen),
                  onPressed: _goBackToLogin,
                ),
              ),

            // Title
            Text(
              _currentCardContent == 'login'
                  ? 'Welcome Back'
                  : _currentCardContent == 'forgotPassword'
                  ? 'Forgot Password'
                  : 'Sign Up',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: customGreen,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            // Subtitle
            Text(
              _currentCardContent == 'login'
                  ? 'Login into your account'
                  : _currentCardContent == 'forgotPassword'
                  ? 'Enter your email to reset your password'
                  : 'Create a new account',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Full Name Field (only for sign up)
            if (_currentCardContent == 'signUp')
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.person, color: customGreen),
                  filled: true,
                  fillColor: lightGreen,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: customGreen),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
            if (_currentCardContent == 'signUp') SizedBox(height: 10),

            // Add this after the full name field in the sign-up form
            if (_currentCardContent == 'signUp')
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.person_outline, color: customGreen),
                  filled: true,
                  fillColor: lightGreen,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: customGreen),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please choose a username';
                  }
                  return null;
                },
                onChanged: (value) {
                  // You can store the username in a controller if needed
                },
              ),
            if (_currentCardContent == 'signUp') SizedBox(height: 10),

            // Email Input Field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.email, color: customGreen),
                filled: true,
                fillColor: lightGreen,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: customGreen),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            SizedBox(height: 10),

            // Password Input Field (only for login and sign up)
            if (_currentCardContent != 'forgotPassword')
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.lock, color: customGreen),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: customGreen,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: lightGreen,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: customGreen),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            SizedBox(height: 10),

            // Remember Me and Forgot Password (only for login)
            if (_currentCardContent == 'login')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: customGreen,
                      ),
                      Text('Remember Me', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _navigateTo('forgotPassword'),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: customGreen),
                    ),
                  ),
                ],
              ),
            Spacer(),

            // Login/Sign Up/Forgot Password Button
            // In your build method, replace the current loading indicator with:
              _isLoading
                  ? Column(
                      children: [
                        CircularProgressIndicator(
                          color: customGreen,
                          strokeWidth: 2,
                        ),
                        SizedBox(height: 10),
                        Text(
                          _currentCardContent == 'signUp' 
                              ? 'Creating your account...' 
                              : 'Logging in...',
                          style: TextStyle(
                            color: customGreen,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {
                        if (_currentCardContent == 'login') {
                          _login();
                        } else if (_currentCardContent == 'forgotPassword') {
                          _forgotPassword();
                        } else if (_currentCardContent == 'signUp') {
                          _signUp();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        backgroundColor: customGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _currentCardContent == 'login'
                            ? 'Login'
                            : _currentCardContent == 'forgotPassword'
                                ? 'Reset Password'
                                : 'Sign Up',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            SizedBox(
              height: 10,
            ), // Space between button and "Don't have an account?"
            // "Don't have an account? Sign Up" (only for login)
            if (_currentCardContent == 'login')
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.grey), // Gray text
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => _navigateTo('signUp'),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: customGreen, // Custom green color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // "Or continue with" section (only for sign up)
            if (_currentCardContent == 'signUp')
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'or continue with',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: Image.asset('assets/icons/facebook.png'),
                          onPressed: () {
                            CustomSnackbar.showError(
                              context,
                              'Facebook sign up not implemented yet.',
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: Image.asset('assets/icons/google.png'),
                          onPressed: () {
                            CustomSnackbar.showError(
                              context,
                              'Google sign up not implemented yet.',
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: Image.asset('assets/icons/apple.png'),
                          onPressed: () {
                            CustomSnackbar.showError(
                              context,
                              'Apple sign up not implemented yet.',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 20),

            // "Already have an account? Log In" (only for sign up)
            if (_currentCardContent == 'signUp')
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.grey), // Gray text
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => _goBackToLogin(),
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            color: customGreen, // Custom green color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}