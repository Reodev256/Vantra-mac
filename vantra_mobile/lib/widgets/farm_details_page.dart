import 'package:flutter/material.dart';

class FarmDetailsPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, dynamic> details;

  const FarmDetailsPage({
    super.key,
    required this.title,
    required this.icon,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'farm-icon-$title',
                child: Icon(icon, size: 80, color: const Color(0xFF41754E)),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Location', details['location'] ?? 'N/A'),
            _buildDetailRow('Size', details['size'] ?? 'N/A'),
            _buildDetailRow('Crop', details['crop'] ?? 'N/A'),
            _buildDetailRow('Status', details['status'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(value, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
