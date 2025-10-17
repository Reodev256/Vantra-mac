import 'package:flutter/material.dart';
import 'onboarding_data.dart';

// Crops Details Form
class CropsDetailsForm extends StatefulWidget {
  final OnboardingData onboardingData;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const CropsDetailsForm({
    Key? key,
    required this.onboardingData,
    required this.onComplete,
    required this.onBack,
  }) : super(key: key);

  @override
  _CropsDetailsFormState createState() => _CropsDetailsFormState();
}

class _CropsDetailsFormState extends State<CropsDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _cropsController = TextEditingController();

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
              'Your crops',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF41754E),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'What do you grow?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 40),
            
            TextFormField(
              controller: _cropsController,
              decoration: InputDecoration(
                labelText: 'Main Crops',
                hintText: 'e.g., Maize, Beans, Vegetables',
                prefixIcon: Icon(Icons.spa, color: Color(0xFF41754E)),
                filled: true,
                fillColor: Color(0xFFDBE6DE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your main crops';
                }
                return null;
              },
            ),
            SizedBox(height: 40),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: Color(0xFF41754E)),
                    ),
                    child: Text('Back', style: TextStyle(color: Color(0xFF41754E))),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onboardingData.mainCrops = _cropsController.text;
                        widget.onComplete();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF41754E),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Complete Setup'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}