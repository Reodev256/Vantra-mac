import 'package:flutter/material.dart';

class AggregatorHomeScreen extends StatelessWidget {
  const AggregatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggregator Dashboard'),
        backgroundColor: const Color(0xFF41754E),
      ),
      body: const Center(
        child: Text('Aggregator Home Screen'),
      ),
    );
  }
}