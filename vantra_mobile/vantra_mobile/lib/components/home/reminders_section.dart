import 'package:flutter/material.dart';

class RemindersSection extends StatelessWidget {
  const RemindersSection({super.key});

  Widget _buildReminderCard(String title, String date, String type, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
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
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
                Icon(Icons.notifications_active, color: Color(0xFF41754E)),
                SizedBox(width: 8),
                Text(
                  'Important Reminders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF41754E),
                  ),
                ),
              ],
            ),
          ),
          
          // Certification & Administrative Reminders
          _buildReminderCard(
            'Organic Certification Renewal',
            'Due in 45 days',
            'CERTIFICATION',
            Colors.purple,
          ),
          SizedBox(height: 8),
          _buildReminderCard(
            'Equipment Service - Sprayers',
            'Next service in 2 weeks',
            'MAINTENANCE',
            Colors.orange,
          ),
          SizedBox(height: 8),
          _buildReminderCard(
            'Vanilla Market Price Review',
            'Update pricing monthly',
            'MARKET',
            Colors.blue,
          ),
          SizedBox(height: 8),
          _buildReminderCard(
            'Soil Testing Schedule',
            'Test every 6 months',
            'TESTING',
            Colors.brown,
          ),
          SizedBox(height: 8),
          _buildReminderCard(
            'Harvest Planning Meeting',
            'Schedule for next month',
            'PLANNING',
            Colors.green,
          ),
          SizedBox(height: 8),
          _buildReminderCard(
            'Export Documentation Update',
            'Review quarterly',
            'ADMIN',
            Colors.red,
          ),
        ],
      ),
    );
  }
}