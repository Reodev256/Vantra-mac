import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class Transaction {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmLocation;
  final String farmField;
  final String cropType;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalValue;
  final String quality;
  final DateTime transactionDate;
  final TransactionStatus status;
  final String trackingCode;
  final String qrCodeData;
  final EUDRStatus eudrStatus;
  final Map<String, dynamic> traceabilityData;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmLocation,
    required this.farmField,
    required this.cropType,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalValue,
    required this.quality,
    required this.transactionDate,
    required this.status,
    required this.trackingCode,
    required this.qrCodeData,
    required this.eudrStatus,
    required this.traceabilityData,
    required this.createdAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> data) {
    return Transaction(
      id: data['id'] ?? '',
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? '',
      farmLocation: data['farmLocation'] ?? '',
      farmField: data['farmField'] ?? '',
      cropType: data['cropType'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'kg',
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      totalValue: (data['totalValue'] ?? 0).toDouble(),
      quality: data['quality'] ?? 'Standard',
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${data['status']}',
        orElse: () => TransactionStatus.ongoing,
      ),
      trackingCode: data['trackingCode'] ?? '',
      qrCodeData: data['qrCodeData'] ?? '',
      eudrStatus: EUDRStatus.values.firstWhere(
        (e) => e.toString() == 'EUDRStatus.${data['eudrStatus']}',
        orElse: () => EUDRStatus.pending,
      ),
      traceabilityData: Map<String, dynamic>.from(data['traceabilityData'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmLocation': farmLocation,
      'farmField': farmField,
      'cropType': cropType,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalValue': totalValue,
      'quality': quality,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'status': status.toString().split('.').last,
      'trackingCode': trackingCode,
      'qrCodeData': qrCodeData,
      'eudrStatus': eudrStatus.toString().split('.').last,
      'traceabilityData': traceabilityData,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum TransactionStatus {
  ongoing,
  completed,
  cancelled,
  pendingVerification
}

enum EUDRStatus {
  compliant,
  nonCompliant,
  pending,
  verified
}

class FarmerFarmData {
  final String farmerId;
  final String location;
  final String farmSize;
  final List<String> mainCrops;
  final String experience;
  final String farmType;
  final List<String> farmFields;

  FarmerFarmData({
    required this.farmerId,
    required this.location,
    required this.farmSize,
    required this.mainCrops,
    required this.experience,
    required this.farmType,
    required this.farmFields,
  });

  factory FarmerFarmData.fromMap(Map<String, dynamic> data) {
    return FarmerFarmData(
      farmerId: data['farmerId'] ?? '',
      location: data['location'] ?? '',
      farmSize: data['farmSize'] ?? '',
      mainCrops: List<String>.from(data['mainCrops'] ?? []),
      experience: data['experience'] ?? '',
      farmType: data['farmType'] ?? '',
      farmFields: List<String>.from(data['farmFields'] ?? ['Main Field']),
    );
  }
}