import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantra_mobile/widgets/template.dart';
import 'package:vantra_mobile/widgets/custom_snackbar.dart';
import 'onboarding_data.dart';
import 'farmer_details_form.dart';
import 'farm_details_form.dart';
import 'crops_details_form.dart';

// Main onboarding wrapper that manages the flow
class OnboardingWrapper extends StatefulWidget {
  final String farmerId;
  final String email;
  final String fullName;
  final String userName;

  const OnboardingWrapper({
    Key? key,
    required this.farmerId,
    required this.email,
    required this.fullName,
    required this.userName,
  }) : super(key: key);

  @override
  _OnboardingWrapperState createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final OnboardingData _onboardingData = OnboardingData();
  int _currentPageIndex = 0;

  final List<Widget> _onboardingPages = [];

  @override
  void initState() {
    super.initState();
    _onboardingData.fullName = widget.fullName;
    _onboardingPages.addAll([
      FarmerDetailsForm(
        onboardingData: _onboardingData,
        onNext: _goToNextPage,
      ),
      FarmDetailsForm(
        onboardingData: _onboardingData,
        onNext: _goToNextPage,
        onBack: _goToPreviousPage,
      ),
      CropsDetailsForm(
        onboardingData: _onboardingData,
        onComplete: _completeOnboarding,
        onBack: _goToPreviousPage,
      ),
    ]);
  }

  void _goToNextPage() {
    if (_currentPageIndex < _onboardingPages.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
    }
  }

  void _completeOnboarding() async {
    try {
      // Save onboarding data to Firestore
      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.farmerId)
          .update({
        'onboardingCompleted': true,
        'fullName': _onboardingData.fullName,
        'location': _onboardingData.location,
        'farmSize': _onboardingData.farmSize,
        'mainCrops': _onboardingData.mainCrops,
        'experience': _onboardingData.experience,
        'farmType': _onboardingData.farmType,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
      });

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingCompleted', true);

      // Use post-frame callback for navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Template()),
        );
      });

    } catch (e) {
      CustomSnackbar.showError(context, 'Error completing onboarding: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _onboardingPages[_currentPageIndex],
    );
  }
}