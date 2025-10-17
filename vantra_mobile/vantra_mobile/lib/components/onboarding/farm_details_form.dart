import 'package:flutter/material.dart';
import 'onboarding_data.dart';

// Farm Details Form
class FarmDetailsForm extends StatefulWidget {
  final OnboardingData onboardingData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const FarmDetailsForm({
    Key? key,
    required this.onboardingData,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  _FarmDetailsFormState createState() => _FarmDetailsFormState();
}

class _FarmDetailsFormState extends State<FarmDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _farmSizeController = TextEditingController();
  String? _selectedFarmType;

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
              'About your farm',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF41754E),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Tell us about your farming operation',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 40),

            TextFormField(
              decoration: InputDecoration(
                labelText: 'Farm Fields (comma separated)',
                hintText: 'e.g., North Field, South Field, Greenhouse',
                prefixIcon: Icon(Icons.map, color: Color(0xFF41754E)),
              ),
              onSaved: (value) {
                // Split by comma and trim each field
                final fields = value?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? ['Main Field'];
                // Save to onboarding data or directly to Firestore
              },
            ),
            SizedBox(height: 40),
            
            TextFormField(
              controller: _farmSizeController,
              decoration: InputDecoration(
                labelText: 'Farm Size',
                hintText: 'e.g., 10 acres',
                prefixIcon: Icon(Icons.agriculture, color: Color(0xFF41754E)),
                filled: true,
                fillColor: Color(0xFFDBE6DE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter farm size';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            
            DropdownButtonFormField<String>(
              value: _selectedFarmType,
              decoration: InputDecoration(
                labelText: 'Farm Type',
                prefixIcon: Icon(Icons.category, color: Color(0xFF41754E)),
                filled: true,
                fillColor: Color(0xFFDBE6DE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                'Commercial',
                'Subsistence',
                'Organic',
                'Mixed Farming',
                'Other'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFarmType = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select farm type';
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
                        widget.onboardingData.farmSize = _farmSizeController.text;
                        widget.onboardingData.farmType = _selectedFarmType;
                        widget.onNext();
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
                    child: Text('Continue'),
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