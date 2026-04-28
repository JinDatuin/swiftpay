import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'credit' or 'debit'
  final DateTime timestamp;
  final String description;
  final String? category;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.timestamp,
    required this.description,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
      'category': category,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] ?? 'credit',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      category: map['category'],
    );
  }
}
