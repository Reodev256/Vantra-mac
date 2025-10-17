import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  _CreateTransactionScreenState createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();
  
  // Form controllers
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  
  // Form values
  String? _selectedFarmField;
  String? _selectedCropType;
  String? _selectedQuality;
  
  // Farmer data
  List<String> _farmFields = [];
  List<String> _availableCrops = [];
  String _farmLocation = '';
  bool _isLoading = false;
  bool _dataLoaded = false;

  final List<String> _qualityOptions = [
    'Grade A - Premium',
    'Grade B - Standard',
    'Grade C - Commercial',
    'Organic Certified',
    'Fair Trade'
  ];

  @override
  void initState() {
    super.initState();
    _loadFarmerData();
  }

  Future<void> _loadFarmerData() async {
    try {
      final farmData = await _transactionService.getFarmerFarmData();
      
      setState(() {
        _farmFields = farmData.farmFields;
        _availableCrops = farmData.mainCrops;
        _farmLocation = farmData.location;
        _selectedFarmField = _farmFields.isNotEmpty ? _farmFields.first : null;
        _selectedCropType = _availableCrops.isNotEmpty ? _availableCrops.first : null;
        _selectedQuality = _qualityOptions.first;
        _dataLoaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading farm data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final transaction = await _transactionService.createTransaction(
          farmField: _selectedFarmField!,
          cropType: _selectedCropType!,
          quantity: double.parse(_quantityController.text),
          unitPrice: double.parse(_unitPriceController.text),
          quality: _selectedQuality!,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.pop(context);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  double get _calculatedTotal {
    try {
      final quantity = double.tryParse(_quantityController.text) ?? 0;
      final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
      return quantity * unitPrice;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Transaction'),
        backgroundColor: const Color(0xFF41754E),
      ),
      body: !_dataLoaded
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Farm Location (auto-filled)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF41754E)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Farm Location',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _farmLocation,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Farm Field Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedFarmField,
                        decoration: InputDecoration(
                          labelText: 'Farm Field',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.agriculture),
                        ),
                        items: _farmFields.map((String field) {
                          return DropdownMenuItem<String>(
                            value: field,
                            child: Text(field),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFarmField = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a farm field';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Crop Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCropType,
                        decoration: InputDecoration(
                          labelText: 'Crop Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.spa),
                        ),
                        items: _availableCrops.map((String crop) {
                          return DropdownMenuItem<String>(
                            value: crop,
                            child: Text(crop),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCropType = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a crop type';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Quantity Input
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity (kg)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.scale),
                          suffixText: 'kg',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          final quantity = double.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Please enter a valid quantity';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
                      ),
                      SizedBox(height: 20),

                      // Unit Price Input
                      TextFormField(
                        controller: _unitPriceController,
                        decoration: InputDecoration(
                          labelText: 'Unit Price (USh per kg)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                          prefixText: 'USh ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter unit price';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
                      ),
                      SizedBox(height: 20),

                      // Quality Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedQuality,
                        decoration: InputDecoration(
                          labelText: 'Quality Grade',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.assignment_turned_in),
                        ),
                        items: _qualityOptions.map((String quality) {
                          return DropdownMenuItem<String>(
                            value: quality,
                            child: Text(quality),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedQuality = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select quality grade';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),

                      // Total Calculation
                      Card(
                        color: Color(0xFFE8F5E8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Value:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'USh ${_calculatedTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF41754E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // Create Button
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _createTransaction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF41754E),
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Create Transaction',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }
}