import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vantra_mobile/widgets/login_form.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/banana.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // White Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white, // Fully opaque white at the top
                  Colors.white, // Fully opaque white until quarter way down
                  Colors.white.withAlpha(0), // Fully transparent at the bottom
                ],
                stops: [
                  0.0,
                  0.25,
                  0.6,
                ], // Define where the gradient starts and ends
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content
          Column(
            children: [
              // Logo and Text at the Top
              SizedBox(height: 40), // Add some padding from the top
              Image.asset(
                'assets/images/logo.png', // Replace with your logo path
                width: 150,
                height: 150,
              ),
              SizedBox(height: 0),
              Text(
                'W e l c o m e',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                  color:
                      Colors
                          .black, // Set text color to contrast with the white gradient
                ),
              ),

              // Spacer to push the button to the bottom
              Spacer(),

              // Get Started Button at the Bottom
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        200,
                        200,
                        200,
                      ), // Thin grey border
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50), // Button elevation
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 8,
                        sigmaY: 8,
                      ), // Blurry background
                      child: ElevatedButton(
                        onPressed: () {
                          // Trigger the card animation
                          _showLoginCard(context);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            50,
                          ), // Full width and fixed height
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.white.withAlpha(
                            70,
                          ), // Translucent white background
                          elevation: 0, // Remove default elevation
                        ),
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ), // White text
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLoginCard(BuildContext context) {
    // Create an animation controller
    final AnimationController controller = AnimationController(
      duration: Duration(milliseconds: 800), // Increased animation duration
      vsync: Navigator.of(context), // Use the navigator as the vsync
    );

    // Create a Tween for the vertical position
    final Animation<Offset> offsetAnimation = Tween<Offset>(
      begin: Offset(0, 1), // Start from the bottom
      end: Offset.zero, // Move to the top
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut, // Smooth animation curve
      ),
    );

    // Start the animation
    controller.forward();

    // Track the card height
    double cardHeight =
        MediaQuery.of(context).size.height * 0.6; // Initial height

    // Show the bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the sheet to take up more space
      backgroundColor: Colors.transparent, // Make the background transparent
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SlideTransition(
              position: offsetAnimation, // Use the custom animation
              child: ClipPath(
                clipper:
                    cardHeight > MediaQuery.of(context).size.height * 0.6
                        ? SlantedCardClipper()
                        : null, // No slant for the smaller card
                child: Container(
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        cardHeight > MediaQuery.of(context).size.height * 0.6
                            ? null // No border radius for the bigger card
                            : BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                  ),
                  child: LoginForm(
                    onHeightChange: (newHeight) {
                      // Update the height of the card
                      setState(() {
                        cardHeight =
                            MediaQuery.of(context).size.height * newHeight;
                      });
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SlantedCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from the bottom-left
    path.moveTo(0, size.height);

    // Draw the bottom-left to top-left with a rounded curve
    path.lineTo(0, 20); // Move to the start of the slant
    path.quadraticBezierTo(0, 0, 20, 0); // Rounded curve at the top-left

    // Draw the slant with a rounded curve at the top-right
    path.lineTo(size.width - 20, 0); // Move to the end of the slant
    path.quadraticBezierTo(
      size.width,
      0,
      size.width,
      20,
    ); // Rounded curve at the top-right

    // Draw the top-right to bottom-right
    path.lineTo(size.width, size.height);

    // Close the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
