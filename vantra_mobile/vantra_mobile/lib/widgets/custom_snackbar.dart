import 'package:flutter/material.dart';

class CustomSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.green, Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.red, Icons.cancel);
  }

  static void _showSnackbar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    final overlay = Overlay.of(context);

    // Create an animation controller
    final animationController = AnimationController(
      vsync: overlay,
      duration: Duration(milliseconds: 300),
    );

    // Create a slide animation for the snackbar
    final slideAnimation = Tween<Offset>(
      begin: Offset(0, -1), // Start above the screen
      end: Offset(0, 0), // Slide down to the top
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    // Create an overlay entry
    final overlayEntry = OverlayEntry(
      builder:
          (context) => AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Positioned(
                top:
                    MediaQuery.of(context).padding.top +
                    10, // Move slightly downward
                left: 16,
                right: 16,
                child: SlideTransition(
                  position: slideAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: Colors.white, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );

    // Insert the overlay entry
    overlay.insert(overlayEntry);

    // Start the slide-down animation
    animationController.forward();

    // Wait for 3 seconds, then slide back up and remove the overlay
    Future.delayed(Duration(seconds: 3), () {
      animationController.reverse().then((_) {
        overlayEntry.remove();
      });
    });
  }
}
