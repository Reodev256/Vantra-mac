import 'package:flutter/material.dart';
import '../components/onboarding/onboarding_wrapper.dart';

class OnboardingScreens {
  static Widget getOnboardingWrapper({
    required String farmerId,
    required String email,
    required String fullName,
    required String userName,
  }) {
    return OnboardingWrapper(
      farmerId: farmerId,
      email: email,
      fullName: fullName,
      userName: userName,
    );
  }
}