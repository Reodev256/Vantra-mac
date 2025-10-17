import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<TaskData> _allTasks = [];
  List<TaskData> _filteredTasks = [];
  String _currentFilter = 'All';
  String _currentMonth = '';
  bool _isLoading = true;
  bool _showAllMonths = false;

  final List<String> _filters = ['All', 'Pending', 'Completed', 'Missed'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
  }

  Future<void> _loadTasks() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('tasks_data')
          .doc(user.uid)
          .collection('task_submissions')
          .orderBy('date', descending: true)
          .get();

      final tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        return TaskData(
          id: doc.id,
          taskName: data['task_name'] ?? 'Unknown Task',
          taskCategory: data['task_category'] ?? 'General',
          date: (data['date'] as Timestamp).toDate(),
          submittedAt: (data['submitted_at'] as Timestamp).toDate(),
          status: _determineStatus(data['date'] as Timestamp),
          financialData: data['financial_data'] ?? {},
          activityData: data['activity_data'] ?? {},
          taskType: data['task_type'] ?? '',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _allTasks = tasks;
          _filteredTasks = tasks;
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

  String _determineStatus(Timestamp taskDate) {
    final now = DateTime.now();
    final taskDateTime = taskDate.toDate();
    
    // If task date is in the future, it's pending
    if (taskDateTime.isAfter(now)) return 'Pending';
    
    // If task date is in the past and no submission data, it's missed
    // For now, we'll assume all tasks in our list are submitted
    // You might need to adjust this logic based on your actual data structure
    return 'Completed';
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      if (filter == 'All') {
        _filteredTasks = _allTasks;
      } else {
        _filteredTasks = _allTasks.where((task) => task.status == filter).toList();
      }
    });
  }

  List<String> _getUniqueMonths() {
    final months = _filteredTasks.map((task) {
      return DateFormat('yyyy-MM').format(task.date);
    }).toSet().toList();
    
    months.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
    return months;
  }

  List<TaskData> _getTasksForMonth(String month) {
    return _filteredTasks.where((task) {
      return DateFormat('yyyy-MM').format(task.date) == month;
    }).toList();
  }

  String _formatMonth(String monthStr) {
    final parts = monthStr.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final date = DateTime(year, month);
    return DateFormat('MMMM yyyy').format(date);
  }

  Widget _buildTaskCard(TaskData task) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showTaskDetails(task),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.taskName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Category and date
              Row(
                children: [
                  Icon(Icons.category, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    task.taskCategory,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(task.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Quick financial info if available
              if (task.financialData['total_cost'] != null)
                Text(
                  'Total Cost: UGX ${task.financialData['total_cost'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF41754E),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(TaskData task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.taskName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF41754E),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Basic Information
                  _buildDetailRow('Category', task.taskCategory),
                  _buildDetailRow('Status', task.status),
                  _buildDetailRow('Task Date', DateFormat('MMM dd, yyyy').format(task.date)),
                  _buildDetailRow('Submitted On', DateFormat('MMM dd, yyyy - HH:mm').format(task.submittedAt)),
                  _buildDetailRow('Task Type', task.taskType),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Financial Information
                  const Text(
                    'Financial Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF41754E),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Use a simple if-else without spread operator
                  task.financialData.isNotEmpty
                      ? Column(
                          children: [
                            _buildDetailRow('Labor Cost', 'UGX ${(task.financialData['labor_cost'] ?? 0).toStringAsFixed(2)}'),
                            _buildDetailRow('Material Cost', 'UGX ${(task.financialData['material_cost'] ?? 0).toStringAsFixed(2)}'),
                            _buildDetailRow('Equipment Cost', 'UGX ${(task.financialData['equipment_cost'] ?? 0).toStringAsFixed(2)}'),
                            _buildDetailRow('Total Cost', 'UGX ${(task.financialData['total_cost'] ?? 0).toStringAsFixed(2)}'),
                            _buildDetailRow('Time Estimate', '${(task.financialData['time_estimate_hours'] ?? 0)} hours'),
                            if (task.financialData['cost_per_unit'] != null)
                              _buildDetailRow('Cost Per Unit', 'UGX ${task.financialData['cost_per_unit'].toStringAsFixed(2)}'),
                          ],
                        )
                      : _buildDetailRow('Financial Data', 'Not available'),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Activity Data
                  const Text(
                    'Activity Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF41754E),
                    ),
                  ),
                  const SizedBox(height: 8),

                  task.activityData.isNotEmpty
                      ? Column(
                          children: [
                            for (final entry in task.activityData.entries)
                              _buildDetailRow(entry.key, entry.value.toString()),
                          ],
                        )
                      : _buildDetailRow('Activity Data', 'No additional activity data'),
                  
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF41754E),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uniqueMonths = _getUniqueMonths();
    final monthsToShow = _showAllMonths ? uniqueMonths : 
        (uniqueMonths.isNotEmpty ? [uniqueMonths.first] : []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: const Color(0xFF41754E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Chips
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    children: _filters.map((filter) {
                      return FilterChip(
                        label: Text(filter),
                        selected: _currentFilter == filter,
                        onSelected: (selected) => _applyFilter(filter),
                        selectedColor: const Color(0xFF41754E),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _currentFilter == filter ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Show All Months Toggle
                if (uniqueMonths.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _showAllMonths ? 'Showing all months' : 'Showing ${_formatMonth(monthsToShow.first)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllMonths = !_showAllMonths;
                            });
                          },
                          child: Text(
                            _showAllMonths ? 'Show Current Only' : 'Show All Months',
                            style: const TextStyle(
                              color: Color(0xFF41754E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Tasks List
                Expanded(
                  child: uniqueMonths.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.task, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No tasks found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: monthsToShow.length,
                          itemBuilder: (context, monthIndex) {
                            final month = monthsToShow[monthIndex];
                            final monthTasks = _getTasksForMonth(month);
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Month Header
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    _formatMonth(month),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF41754E),
                                    ),
                                  ),
                                ),
                                
                                // Tasks for this month
                                ...monthTasks.map((task) => _buildTaskCard(task)),
                                
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class TaskData {
  final String id;
  final String taskName;
  final String taskCategory;
  final DateTime date;
  final DateTime submittedAt;
  final String status;
  final Map<String, dynamic> financialData;
  final Map<String, dynamic> activityData;
  final String taskType;

  TaskData({
    required this.id,
    required this.taskName,
    required this.taskCategory,
    required this.date,
    required this.submittedAt,
    required this.status,
    required this.financialData,
    required this.activityData,
    required this.taskType,
  });
}