import 'package:flutter/material.dart';

class FarmActivities extends StatelessWidget {
  const FarmActivities({super.key});

  Widget _buildActivityCard(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.notifications_none, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Icon(Icons.agriculture, color: Color(0xFF41754E)),
                SizedBox(width: 8),
                Text(
                  'Vanilla Farm Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF41754E),
                  ),
                ),
              ],
            ),
          ),
          
          // Vanilla Specific Activities
          _buildActivityCard(
            'Shade Management',
            'Check and maintain 50-60% shade coverage',
            Icons.shield,
            Colors.green,
          ),
          SizedBox(height: 8),
          _buildActivityCard(
            'Vine Training',
            'Train new growth on support trees',
            Icons.arrow_upward,
            Colors.blue,
          ),
          SizedBox(height: 8),
          _buildActivityCard(
            'Pollination Watch',
            'Monitor flowering for hand pollination',
            Icons.nature,
            Colors.purple,
          ),
          SizedBox(height: 8),
          _buildActivityCard(
            'Mulching',
            'Refresh organic mulch around base',
            Icons.grass,
            Colors.brown,
          ),
          SizedBox(height: 8),
          _buildActivityCard(
            'Pest Inspection',
            'Check for mites and fungal issues',
            Icons.bug_report,
            Colors.orange,
          ),
          SizedBox(height: 8),
          _buildActivityCard(
            'Irrigation Check',
            'Ensure consistent soil moisture',
            Icons.water_drop,
            Colors.blue,
          ),
        ],
      ),
    );
  }
}