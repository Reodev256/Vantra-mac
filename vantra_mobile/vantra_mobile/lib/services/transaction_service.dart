import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart' as models; // Use alias

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generate unique tracking code
  String _generateTrackingCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'VTR${timestamp}${random}'.substring(0, 15);
  }

  // Generate QR code data
  String _generateQRCodeData(models.Transaction transaction) {
    return '''
VANTRACODE
Tracking: ${transaction.trackingCode}
Farmer: ${transaction.farmerName}
Crop: ${transaction.cropType}
Quantity: ${transaction.quantity} ${transaction.unit}
Location: ${transaction.farmLocation}
Date: ${transaction.transactionDate.toIso8601String()}
EUDR: ${transaction.eudrStatus.toString().split('.').last}
    ''';
  }

  // Get farmer's farm data from onboarding
  Future<models.FarmerFarmData> getFarmerFarmData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final doc = await _firestore.collection('farmers').doc(user.uid).get();
    if (!doc.exists) throw Exception('Farmer data not found');

    final data = doc.data()!;
    return models.FarmerFarmData(
      farmerId: user.uid,
      location: data['location'] ?? '',
      farmSize: data['farmSize'] ?? '',
      mainCrops: List<String>.from(data['mainCrops']?.split(',') ?? []),
      experience: data['experience'] ?? '',
      farmType: data['farmType'] ?? '',
      farmFields: List<String>.from(data['farmFields'] ?? ['Main Field']),
    );
  }

  // Create new transaction
  Future<models.Transaction> createTransaction({
    required String farmField,
    required String cropType,
    required double quantity,
    required double unitPrice,
    required String quality,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Get farmer data
    final farmData = await getFarmerFarmData();
    
    // Generate tracking data
    final trackingCode = _generateTrackingCode();
    
    // Create transaction
    final transaction = models.Transaction(
      id: _firestore.collection('transactions').doc().id,
      farmerId: user.uid,
      farmerName: farmData.location.split(',').first, // Use location as name for now
      farmLocation: farmData.location,
      farmField: farmField,
      cropType: cropType,
      quantity: quantity,
      unit: 'kg',
      unitPrice: unitPrice,
      totalValue: quantity * unitPrice,
      quality: quality,
      transactionDate: DateTime.now(),
      status: models.TransactionStatus.ongoing,
      trackingCode: trackingCode,
      qrCodeData: '',
      eudrStatus: models.EUDRStatus.pending,
      traceabilityData: {
        'farmSize': farmData.farmSize,
        'farmType': farmData.farmType,
        'farmerExperience': farmData.experience,
        'geoLocation': farmData.location,
        'harvestDate': DateTime.now().toIso8601String(),
      },
      createdAt: DateTime.now(),
    );

    // Generate QR code data
    final qrData = _generateQRCodeData(transaction);
    
    // Create updated transaction with QR data
    final updatedTransaction = models.Transaction(
      id: transaction.id,
      farmerId: transaction.farmerId,
      farmerName: transaction.farmerName,
      farmLocation: transaction.farmLocation,
      farmField: transaction.farmField,
      cropType: transaction.cropType,
      quantity: transaction.quantity,
      unit: transaction.unit,
      unitPrice: transaction.unitPrice,
      totalValue: transaction.totalValue,
      quality: transaction.quality,
      transactionDate: transaction.transactionDate,
      status: transaction.status,
      trackingCode: transaction.trackingCode,
      qrCodeData: qrData,
      eudrStatus: transaction.eudrStatus,
      traceabilityData: transaction.traceabilityData,
      createdAt: transaction.createdAt,
    );

    // Save to Firestore
    await _firestore
        .collection('transactions')
        .doc(updatedTransaction.id)
        .set(updatedTransaction.toMap());

    return updatedTransaction;
  }

  // Get all transactions for current farmer
  Stream<List<models.Transaction>> getFarmerTransactions() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('transactions')
        .where('farmerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => models.Transaction.fromMap(doc.data()))
            .toList());
  }

  // Update transaction status
  Future<void> updateTransactionStatus(String transactionId, models.TransactionStatus status) async {
    await _firestore
        .collection('transactions')
        .doc(transactionId)
        .update({'status': status.toString().split('.').last});
  }

  // Update EUDR status
  Future<void> updateEUDRStatus(String transactionId, models.EUDRStatus status) async {
    await _firestore
        .collection('transactions')
        .doc(transactionId)
        .update({'eudrStatus': status.toString().split('.').last});
  }
}