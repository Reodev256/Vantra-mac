import 'package:flutter/material.dart';
import 'package:vantra_mobile/services/api.dart';

class ProcessorHomeScreen extends StatefulWidget {
  const ProcessorHomeScreen({super.key});

  @override
  _ProcessorHomeScreenState createState() => _ProcessorHomeScreenState();
}

class _ProcessorHomeScreenState extends State<ProcessorHomeScreen> {
  List<dynamic> batches = [];
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Processor Home')),
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
                      'Weight: ${batch['weight']}, Quality: ${batch['quality']}, Location: ${batch['location']}',
                    ),
                  );
                },
              ),
    );
  }
}
