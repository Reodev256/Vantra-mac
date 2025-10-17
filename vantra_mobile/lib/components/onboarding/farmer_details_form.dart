import 'package:flutter/material.dart';
import 'onboarding_data.dart';

// Farmer Details Form
class FarmerDetailsForm extends StatefulWidget {
  final OnboardingData onboardingData;
  final VoidCallback onNext;

  const FarmerDetailsForm({
    Key? key,
    required this.onboardingData,
    required this.onNext,
  }) : super(key: key);

  @override
  _FarmerDetailsFormState createState() => _FarmerDetailsFormState();
}

class _FarmerDetailsFormState extends State<FarmerDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Text(
              'Tell us about yourself',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF41754E),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Help us personalize your experience',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 40),
            
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'Enter your farm location',
                prefixIcon: Icon(Icons.location_on, color: Color(0xFF41754E)),
                filled: true,
                fillColor: Color(0xFFDBE6DE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your location';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            
            TextFormField(
              controller: _experienceController,
              decoration: InputDecoration(
                labelText: 'Farming Experience',
                hintText: 'e.g., 5 years',
                prefixIcon: Icon(Icons.work, color: Color(0xFF41754E)),
                filled: true,
                fillColor: Color(0xFFDBE6DE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your experience';
                }
                return null;
              },
            ),
            SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onboardingData.location = _locationController.text;
                  widget.onboardingData.experience = _experienceController.text;
                  widget.onNext();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF41754E),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}