import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final String title;

  const DetailsScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'More details about $title',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
