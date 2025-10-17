import 'package:flutter/material.dart';

class QuickStats extends StatefulWidget {
  const QuickStats({super.key});

  @override
  State<QuickStats> createState() => _QuickStatsState();
}

class _QuickStatsState extends State<QuickStats> {
  // Using your placeholder values directly
  int _pendingTasks = 5;
  int _completedTasks = 4;
  int _vinesReadyForHarvest = 37;
  double _expectedYield = 89.7;
  bool _isLoading = false; // Set to false since we're using placeholders

  @override
  void initState() {
    super.initState();
    // No need to load from Firestore when using placeholders
  }

  // Simplified loadStats method that just uses placeholders
  Future<void> _loadStats() async {
    // This can be empty or used to refresh placeholder values if needed
    setState(() {
      // You can update placeholder values here if needed
      _pendingTasks = 5;
      _completedTasks = 4;
      _vinesReadyForHarvest = 37;
      _expectedYield = 89.7;
    });
  }

  Widget _buildStatItem(String value, String description, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // No loading state needed since we're using placeholders
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            _pendingTasks.toString(),
            'Pending\nTasks',
            Colors.orange[700]!,
          ),
          _buildStatItem(
            _completedTasks.toString(),
            'Completed\nTasks',
            Colors.green[700]!,
          ),
          _buildStatItem(
            _vinesReadyForHarvest.toString(),
            'Vines Ready\nFor Harvest',
            const Color(0xFF41754E),
          ),
          _buildStatItem(
            '${_expectedYield.toStringAsFixed(1)}kg',
            'Expected\nYield',
            Colors.brown[700]!,
          ),
        ],
      ),
    );
  }
}