import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart' as models; // Use alias
import '../services/transaction_service.dart';
import 'create_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _transactionService = TransactionService();
  final List<models.TransactionStatus> _statusFilters = [
    models.TransactionStatus.ongoing,
    models.TransactionStatus.pendingVerification,
    models.TransactionStatus.completed,
    models.TransactionStatus.cancelled,
  ];
  models.TransactionStatus _currentFilter = models.TransactionStatus.ongoing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Transactions'),
        backgroundColor: const Color(0xFF41754E),
        actions: [
          // Filter dropdown
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<models.TransactionStatus>(
              value: _currentFilter,
              dropdownColor: Colors.white,
              onChanged: (models.TransactionStatus? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentFilter = newValue;
                  });
                }
              },
              items: _statusFilters.map((models.TransactionStatus status) {
                return DropdownMenuItem<models.TransactionStatus>(
                  value: status,
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: const Color(0xFF41754E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTransactionScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF41754E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<models.Transaction>>(
        stream: _transactionService.getFarmerTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];
          final filteredTransactions = transactions
              .where((transaction) => transaction.status == _currentFilter)
              .toList();

          if (filteredTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_getStatusText(_currentFilter).toLowerCase()} transactions',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_currentFilter == models.TransactionStatus.ongoing)
                    const SizedBox(height: 8),
                  if (_currentFilter == models.TransactionStatus.ongoing)
                    Text(
                      'Tap the + button to create a new transaction',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              return _buildTransactionCard(transaction);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(models.Transaction transaction) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with tracking code and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tracking: ${transaction.trackingCode}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(transaction.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Transaction details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.cropType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF41754E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.quantity} kg • ${transaction.farmField}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Quality: ${transaction.quality}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'USh ${transaction.totalValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'USh ${transaction.unitPrice}/kg',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Location and EUDR status
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    transaction.farmLocation,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getEUDRColor(transaction.eudrStatus),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getEUDRText(transaction.eudrStatus),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Date
            Text(
              'Created: ${_formatDate(transaction.createdAt)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(models.TransactionStatus status) {
    switch (status) {
      case models.TransactionStatus.ongoing:
        return 'Ongoing';
      case models.TransactionStatus.completed:
        return 'Completed';
      case models.TransactionStatus.cancelled:
        return 'Cancelled';
      case models.TransactionStatus.pendingVerification:
        return 'Pending Verification';
    }
  }

  Color _getStatusColor(models.TransactionStatus status) {
    switch (status) {
      case models.TransactionStatus.ongoing:
        return Colors.orange;
      case models.TransactionStatus.completed:
        return Colors.green;
      case models.TransactionStatus.cancelled:
        return Colors.red;
      case models.TransactionStatus.pendingVerification:
        return Colors.blue;
    }
  }

  String _getEUDRText(models.EUDRStatus status) {
    switch (status) {
      case models.EUDRStatus.compliant:
        return 'EUDR Compliant';
      case models.EUDRStatus.nonCompliant:
        return 'Non-Compliant';
      case models.EUDRStatus.pending:
        return 'EUDR Pending';
      case models.EUDRStatus.verified:
        return 'EUDR Verified';
    }
  }

  Color _getEUDRColor(models.EUDRStatus status) {
    switch (status) {
      case models.EUDRStatus.compliant:
      case models.EUDRStatus.verified:
        return Colors.green;
      case models.EUDRStatus.nonCompliant:
        return Colors.red;
      case models.EUDRStatus.pending:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}