import 'package:flutter/material.dart';
import 'package:vantra_mobile/services/api.dart';

class TransporterHomeScreen extends StatefulWidget {
  const TransporterHomeScreen({super.key});

  @override
  _TransporterHomeScreenState createState() => _TransporterHomeScreenState();
}

class _TransporterHomeScreenState extends State<TransporterHomeScreen> {
  List<dynamic> batches = [];
  bool _isLoading = true;
  final _locationController = TextEditingController();
  final _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBatches();
  }

  void _fetchBatches() async {
    try {
      final data = await ApiService.getBatches();
      setState(() {
        batches = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch batches: $e')));
    }
  }

  void _updateBatchLocation(int batchId) async {
    if (_locationController.text.isEmpty || _statusController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.updateBatchLocation(
        batchId,
        _locationController.text,
        _statusController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Batch location updated successfully')),
      );
      _fetchBatches(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update batch location: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transporter Home')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: batches.length,
                itemBuilder: (context, index) {
                  final batch = batches[index];
                  return ListTile(
                    title: Text('Batch ID: ${batch['batch_id']}'),
                    subtitle: Text(
                      'Location: ${batch['location']}, Status: ${batch['status']}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Update Location and Status'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: _locationController,
                                      decoration: InputDecoration(
                                        labelText: 'Location',
                                      ),
                                    ),
                                    TextField(
                                      controller: _statusController,
                                      decoration: InputDecoration(
                                        labelText: 'Status',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _updateBatchLocation(batch['id']);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Update'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
