import 'package:flutter/material.dart';

// Onboarding data model
class OnboardingData {
  String? fullName;
  String? location;
  String? farmSize;
  String? mainCrops;
  String? experience;
  String? farmType;

  OnboardingData({
    this.fullName,
    this.location,
    this.farmSize,
    this.mainCrops,
    this.experience,
    this.farmType,
  });
}