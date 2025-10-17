import 'package:flutter/material.dart';
import 'package:vantra_mobile/services/api.dart';

class AggregatorHomeScreen extends StatefulWidget {
  const AggregatorHomeScreen({super.key});

  @override
  _AggregatorHomeScreenState createState() => _AggregatorHomeScreenState();
}

class _AggregatorHomeScreenState extends State<AggregatorHomeScreen> {
  List<dynamic> batches = [];
  bool _isLoading = true;
  final _qualityController = TextEditingController();

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

  void _updateBatchQuality(int batchId) async {
    if (_qualityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter quality')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.updateBatchQuality(batchId, _qualityController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Batch quality updated successfully')),
      );
      _fetchBatches(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update batch quality: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aggregator Home')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: batches.length,
                itemBuilder: (context, index) {
                  final batch = batches[index];
                  return ListTile(
                    title: Text('Batch ID: ${batch['batch_id']}'),
                    subtitle: Text('Quality: ${batch['quality']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Update Quality'),
                                content: TextField(
                                  controller: _qualityController,
                                  decoration: InputDecoration(
                                    labelText: 'Quality',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _updateBatchQuality(batch['id']);
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
