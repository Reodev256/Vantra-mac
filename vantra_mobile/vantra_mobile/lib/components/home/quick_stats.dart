import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuickStats extends StatefulWidget {
  const QuickStats({super.key});

  @override
  State<QuickStats> createState() => _QuickStatsState();
}

class _QuickStatsState extends State<QuickStats> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _pendingTasks = 0;
  int _completedTasks = 0;
  int _activeCrops = 0;
  int _upcomingHarvests = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get tasks count
      final tasksSnapshot = await _firestore
          .collection('farmers')
          .doc(user.uid)
          .collection('tasks')
          .get();

      int pending = 0;
      int completed = 0;

      for (var doc in tasksSnapshot.docs) {
        final data = doc.data();
        if (data['completed'] == true) {
          completed++;
        } else {
          pending++;
        }
      }

      // Get farm data for crop count
      final farmSnapshot = await _firestore
          .collection('farmers')
          .doc(user.uid)
          .get();

      int activeCrops = 0;
      int upcomingHarvests = 0;

      if (farmSnapshot.exists) {
        final farmData = farmSnapshot.data()!;
        
        // Count active crops from mainCrops field
        if (farmData['mainCrops'] != null) {
          final crops = farmData['mainCrops'].toString().split(',');
          activeCrops = crops.length;
        }
        
        // Estimate upcoming harvests (this would come from your harvest scheduling)
        upcomingHarvests = activeCrops > 0 ? 1 : 0; // Placeholder logic
      }

      if (mounted) {
        setState(() {
          _pendingTasks = pending;
          _completedTasks = completed;
          _activeCrops = activeCrops;
          _upcomingHarvests = upcomingHarvests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(height: 8),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Color(0xFF41754E)),
                  SizedBox(width: 8),
                  Text(
                    'Quick Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF41754E),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, size: 20),
                    onPressed: _loadStats,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    'Pending Tasks',
                    _pendingTasks,
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                  SizedBox(width: 12),
                  _buildStatCard(
                    'Completed',
                    _completedTasks,
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard(
                    'Active Crops',
                    _activeCrops,
                    Icons.spa,
                    Color(0xFF41754E),
                  ),
                  SizedBox(width: 12),
                  _buildStatCard(
                    'Upcoming Harvest',
                    _upcomingHarvests,
                    Icons.agriculture,
                    Colors.brown,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}