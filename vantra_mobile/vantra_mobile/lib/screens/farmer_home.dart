import 'package:flutter/material.dart';
import 'package:vantra_mobile/services/api.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  _FarmerHomeScreenState createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final _taskTypeController = TextEditingController();
  final _dateController = TextEditingController();
  final _batchIdController = TextEditingController();
  final _weightController = TextEditingController();
  final _qualityController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  void _logTask() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.logTask(
        _taskTypeController.text,
        DateTime.parse(_dateController.text),
        1, // Replace with actual farmer ID
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task logged successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to log task: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _createBatch() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.createBatch(
        _batchIdController.text,
        double.parse(_weightController.text),
        _qualityController.text,
        _locationController.text,
        1, // Replace with actual farmer ID
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Batch created successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create batch: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Farmer Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskTypeController,
              decoration: InputDecoration(labelText: 'Task Type'),
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
            ElevatedButton(onPressed: _logTask, child: Text('Log Task')),
            SizedBox(height: 20),
            TextField(
              controller: _batchIdController,
              decoration: InputDecoration(labelText: 'Batch ID'),
            ),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: 'Weight'),
            ),
            TextField(
              controller: _qualityController,
              decoration: InputDecoration(labelText: 'Quality'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            ElevatedButton(
              onPressed: _createBatch,
              child: Text('Create Batch'),
            ),
          ],
        ),
      ),
    );
  }
}
