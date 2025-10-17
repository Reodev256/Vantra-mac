import 'package:flutter/material.dart';
import 'task_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, TextEditingController> _numberControllers = {};
  final Map<String, TextEditingController> _costControllers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for all inputs
    for (var item in widget.task.items) {
      if (item.type == InputType.textInput) {
        _textControllers[item.label] = TextEditingController();
      } else if (item.type == InputType.numberInput) {
        _numberControllers[item.label] = TextEditingController();
      }
    }
    // Initialize cost controllers for financial tracking
    _costControllers['labor_cost'] = TextEditingController();
    _costControllers['material_cost'] = TextEditingController();
    _costControllers['equipment_cost'] = TextEditingController();
  }

  // Enhanced data saving with financial tracking - STORED IN tasks_data COLLECTION
  Future<void> _submitData() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final now = DateTime.now();
      final farmerId = user.uid;
      final taskName = widget.task.title.toLowerCase().replaceAll('\n', '_').replaceAll(' ', '_');

      // Calculate financial metrics
      final laborCost = double.tryParse(_costControllers['labor_cost']?.text ?? '0') ?? 0;
      final materialCost = double.tryParse(_costControllers['material_cost']?.text ?? '0') ?? 0;
      final equipmentCost = double.tryParse(_costControllers['equipment_cost']?.text ?? '0') ?? 0;
      final totalCost = laborCost + materialCost + equipmentCost;

      // Calculate time investment (estimate based on task type)
      final timeEstimate = _calculateTimeEstimate();

      // Main task document reference - STORED IN tasks_data COLLECTION
      final taskDocRef = _firestore
          .collection('tasks_data') // Separate collection for task data
          .doc(farmerId) // Separate by farmer ID within tasks_data
          .collection('task_submissions')
          .doc(); // Individual submission document

      // Create a batch write to handle multiple operations
      final batch = _firestore.batch();

      // Save all form data with financial information
      final taskData = {
        'farmer_id': farmerId, // Ensures data separation
        'task_name': widget.task.title,
        'task_category': widget.task.category,
        'date': now,
        'submitted_at': FieldValue.serverTimestamp(),
        
        // Financial data for cost analysis
        'financial_data': {
          'labor_cost': laborCost,
          'material_cost': materialCost,
          'equipment_cost': equipmentCost,
          'total_cost': totalCost,
          'time_estimate_hours': timeEstimate,
          'cost_per_unit': _calculateCostPerUnit(totalCost),
          'currency': 'UGX',
        },
        
        // Activity data
        'activity_data': _formData,
        
        // Task metadata for filtering
        'task_type': taskName,
        'month': '${now.year}-${now.month}',
        'year': now.year,
      };

      // Set the main task document in tasks_data collection
      batch.set(taskDocRef, taskData);

      // Also update financial aggregates for quick reporting - STORED IN tasks_data COLLECTION
      final financialAggregateRef = _firestore
          .collection('tasks_data')
          .doc(farmerId)
          .collection('financial_aggregates')
          .doc('task_costs');

      batch.set(financialAggregateRef, {
        'farmer_id': farmerId,
        'last_updated': FieldValue.serverTimestamp(),
        'total_task_records': FieldValue.increment(1),
        'total_labor_cost': FieldValue.increment(laborCost),
        'total_material_cost': FieldValue.increment(materialCost),
        'total_equipment_cost': FieldValue.increment(equipmentCost),
        'overall_total_cost': FieldValue.increment(totalCost),
        'recent_activities': FieldValue.arrayUnion([{
          'task_name': widget.task.title,
          'category': widget.task.category,
          'total_cost': totalCost,
          'date': now,
          'task_type': taskName,
        }])
      }, SetOptions(merge: true));

      // Update monthly aggregates for financial reporting
      final monthlyAggregateRef = _firestore
          .collection('tasks_data')
          .doc(farmerId)
          .collection('monthly_aggregates')
          .doc('${now.year}-${now.month}');

      batch.set(monthlyAggregateRef, {
        'farmer_id': farmerId,
        'month': '${now.year}-${now.month}',
        'year': now.year,
        'month_number': now.month,
        'last_updated': FieldValue.serverTimestamp(),
        'total_monthly_cost': FieldValue.increment(totalCost),
        'labor_cost_monthly': FieldValue.increment(laborCost),
        'material_cost_monthly': FieldValue.increment(materialCost),
        'equipment_cost_monthly': FieldValue.increment(equipmentCost),
        'tasks_completed': FieldValue.increment(1),
        'task_categories': FieldValue.arrayUnion([widget.task.category]),
      }, SetOptions(merge: true));

      // Commit all writes as a batch
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.task.title} data saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Estimate time based on task category
  double _calculateTimeEstimate() {
    switch (widget.task.category) {
      case 'Vanilla Care':
        return 2.0; // hours
      case 'Soil Care':
        return 1.5;
      case 'Irrigation':
        return 1.0;
      case 'Harvest':
        return 4.0;
      case 'Processing':
        return 3.0;
      default:
        return 1.0;
    }
  }

  // Calculate cost per unit for pricing analysis
  double _calculateCostPerUnit(double totalCost) {
    // This would be more sophisticated based on actual outputs
    // For now, simple calculation based on common metrics
    if (_formData.containsKey('Vines Trained')) {
      final vines = _formData['Vines Trained'] ?? 1;
      return totalCost / (vines > 0 ? vines : 1);
    }
    if (_formData.containsKey('Area Weeded')) {
      final area = _formData['Area Weeded'] ?? 1;
      return totalCost / (area > 0 ? area : 1);
    }
    if (_formData.containsKey('Cuttings Planted')) {
      final cuttings = _formData['Cuttings Planted'] ?? 1;
      return totalCost / (cuttings > 0 ? cuttings : 1);
    }
    return totalCost;
  }

  @override
  void dispose() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    for (var controller in _numberControllers.values) {
      controller.dispose();
    }
    for (var controller in _costControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildInputItem(TaskItem item) {
    switch (item.type) {
      case InputType.checkbox:
        return CheckboxListTile(
          title: Text(item.label),
          value: _formData[item.label] ?? false,
          onChanged: (bool? value) {
            setState(() {
              _formData[item.label] = value;
            });
          },
        );

      case InputType.weeklyCheckboxes:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.label, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: item.options!.map((week) {
                return Column(
                  children: [
                    Text(week),
                    Checkbox(
                      value: _formData['${item.label}_$week'] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          _formData['${item.label}_$week'] = value;
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );

      case InputType.textInput:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: _textControllers[item.label],
            decoration: InputDecoration(
              labelText: item.label,
              hintText: item.hintText,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _formData[item.label] = value;
            },
          ),
        );

      case InputType.numberInput:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _numberControllers[item.label],
                      decoration: InputDecoration(
                        hintText: item.hintText,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _formData[item.label] = double.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  if (item.unit != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(item.unit!),
                    ),
                ],
              ),
            ],
          ),
        );

      default:
        return Container();
    }
  }

  Widget _buildCostInput(String label, String controllerKey, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _costControllers[controllerKey],
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: OutlineInputBorder(),
                    prefixText: 'UGX ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('UGX'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title.replaceAll('\n', ' ')),
        backgroundColor: Color(0xFF41754E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Description
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Color(0xFF41754E),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Steps
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Steps to Follow',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Color(0xFF41754E),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.task.steps.map((step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Color(0xFF41754E)),
                              SizedBox(width: 8),
                              Expanded(child: Text(step)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input Items
            Text(
              'Record Your Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Color(0xFF41754E),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...widget.task.items.map((item) => _buildInputItem(item)),

            // Cost Tracking Section
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.blue[700]),
                        SizedBox(width: 8),
                        Text(
                          'Cost Tracking (Financial Analysis)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Track costs to understand your investment and price your vanilla better',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    _buildCostInput('Labor Cost', 'labor_cost', 'e.g., 15000'),
                    _buildCostInput('Material Cost', 'material_cost', 'e.g., 5000'),
                    _buildCostInput('Equipment Cost', 'equipment_cost', 'e.g., 2000'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF41754E),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Data for Financial Tracking',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}