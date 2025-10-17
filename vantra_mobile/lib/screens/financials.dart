import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FinancialsScreen extends StatefulWidget {
  const FinancialsScreen({super.key});

  @override
  State<FinancialsScreen> createState() => _FinancialsScreenState();
}

class _FinancialsScreenState extends State<FinancialsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _selectedPeriod = 'All Time';
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _netProfit = 0.0;
  double _profitMargin = 0.0;
  
  List<TransactionData> _recentTransactions = [];
  List<ExpenseData> _recentExpenses = [];
  List<ProductMovement> _productMovements = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Read transactions data and sum up total values for income
      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .doc(user.uid)
          .collection('farmer_transactions')
          .orderBy('createdAt', descending: true)
          .get();

      double income = 0.0;
      for (final doc in transactionsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        income += (data['totalValue'] ?? 0).toDouble();
      }

      // Read tasks data and sum up total amount for expenses
      final tasksSnapshot = await _firestore
          .collection('tasks_data')
          .doc(user.uid)
          .collection('task_submissions')
          .orderBy('date', descending: true)
          .get();

      double expenses = 0.0;
      for (final doc in tasksSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final financialData = data['financial_data'] as Map<String, dynamic>? ?? {};
        expenses += (financialData['total_cost'] ?? 0).toDouble();
      }

      // Load recent data for display
      _loadRecentData(transactionsSnapshot.docs, tasksSnapshot.docs);
      
      // Load product movements
      _loadProductMovements(transactionsSnapshot.docs);

      setState(() {
        _totalIncome = income;
        _totalExpenses = expenses;
        _netProfit = income - expenses;
        _profitMargin = income > 0 ? (_netProfit / income) * 100 : 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadRecentData(List<QueryDocumentSnapshot> transactionDocs, List<QueryDocumentSnapshot> expenseDocs) {
    // Recent transactions (last 5)
    _recentTransactions = transactionDocs.take(5).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return TransactionData(
        id: doc.id,
        cropType: data['cropType'] ?? 'Unknown Crop',
        amount: (data['totalValue'] ?? 0).toDouble(),
        date: (data['createdAt'] as Timestamp).toDate(),
        quantity: (data['quantity'] ?? 0).toDouble(),
        status: data['status'] ?? 'completed',
      );
    }).toList();

    // Recent expenses (last 5)
    _recentExpenses = expenseDocs.take(5).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final financialData = data['financial_data'] as Map<String, dynamic>? ?? {};
      return ExpenseData(
        id: doc.id,
        taskName: data['task_name'] ?? 'Unknown Task',
        amount: (financialData['total_cost'] ?? 0).toDouble(),
        date: (data['date'] as Timestamp).toDate(),
        category: data['task_category'] ?? 'General',
      );
    }).toList();
  }

  void _loadProductMovements(List<QueryDocumentSnapshot> transactionDocs) {
    _productMovements = transactionDocs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ProductMovement(
        id: doc.id,
        productName: data['cropType'] ?? 'Unknown Product',
        quantity: (data['quantity'] ?? 0).toDouble(),
        status: data['status'] ?? 'pending',
        date: (data['createdAt'] as Timestamp).toDate(),
        value: (data['totalValue'] ?? 0).toDouble(),
      );
    }).toList();
  }

  Widget _buildFinancialSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Financial Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF41754E),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPeriod = newValue;
                      });
                      _loadFinancialData();
                    }
                  },
                  items: ['All Time', 'Monthly', 'Yearly'].map((String period) {
                    return DropdownMenuItem<String>(
                      value: period,
                      child: Text(period),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Financial Metrics
            Row(
              children: [
                // Income
                Expanded(
                  child: _buildMetricCard(
                    'Income',
                    _totalIncome,
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 12),
                // Expenses
                Expanded(
                  child: _buildMetricCard(
                    'Expenses',
                    _totalExpenses,
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Profit Metrics
            Row(
              children: [
                // Net Profit
                Expanded(
                  child: _buildMetricCard(
                    'Net Profit',
                    _netProfit,
                    _netProfit >= 0 ? Colors.blue : Colors.orange,
                    _netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                  ),
                ),
                const SizedBox(width: 12),
                // Profit Margin
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.percent,
                              color: _profitMargin >= 0 ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Margin',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_profitMargin.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _profitMargin >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'USh ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF41754E),
              ),
            ),
            const SizedBox(height: 16),
            
            // Recent Income
            _buildActivitySection('Recent Income', _recentTransactions, true),
            const SizedBox(height: 20),
            
            // Recent Expenses
            _buildActivitySection('Recent Expenses', _recentExpenses, false),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(String title, List<dynamic> items, bool isIncome) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'No ${title.toLowerCase()} found',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...items.map((item) => _buildActivityItem(item, isIncome)),
      ],
    );
  }

  Widget _buildActivityItem(dynamic item, bool isIncome) {
    final isTransaction = item is TransactionData;
    final name = isTransaction ? item.cropType : item.taskName;
    final amount = item.amount;
    final date = item.date;
    final details = isTransaction ? '${item.quantity} kg' : item.category;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncome ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: isIncome ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  details,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            'USh ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTracking() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Product Movement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF41754E),
                  ),
                ),
                const Spacer(),
                Icon(Icons.inventory_2, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_productMovements.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No product movements tracked',
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Column(
                children: _productMovements.take(5).map((movement) => _buildProductItem(movement)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(ProductMovement movement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(movement.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(movement.status),
              color: _getStatusColor(movement.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${movement.quantity} kg • USh ${movement.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${movement.status} • ${DateFormat('MMM dd').format(movement.date)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
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
      case 'ongoing':
        return Colors.orange;
      case 'pending':
      case 'pendingverification':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'ongoing':
        return Icons.autorenew;
      case 'pending':
      case 'pendingverification':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.inventory;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadFinancialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financials'),
        backgroundColor: const Color(0xFF41754E),
        foregroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: _refreshData,
        //   ),
        // ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFinancialSummary(),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                    const SizedBox(height: 16),
                    _buildProductTracking(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

// Data Models
class TransactionData {
  final String id;
  final String cropType;
  final double amount;
  final DateTime date;
  final double quantity;
  final String status;

  TransactionData({
    required this.id,
    required this.cropType,
    required this.amount,
    required this.date,
    required this.quantity,
    required this.status,
  });
}

class ExpenseData {
  final String id;
  final String taskName;
  final double amount;
  final DateTime date;
  final String category;

  ExpenseData({
    required this.id,
    required this.taskName,
    required this.amount,
    required this.date,
    required this.category,
  });
}

class ProductMovement {
  final String id;
  final String productName;
  final double quantity;
  final String status;
  final DateTime date;
  final double value;

  ProductMovement({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.date,
    required this.value,
  });
}