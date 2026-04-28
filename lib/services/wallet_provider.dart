import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class WalletProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _user;
  List<TransactionModel> _transactions = [];

  UserModel? get user => _user;
  List<TransactionModel> get transactions => _transactions;

  WalletProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _firestoreService.streamUser(firebaseUser.uid).listen((userData) {
          _user = userData;
          notifyListeners();
        });

        _firestoreService.streamTransactions(firebaseUser.uid).listen((transactionData) {
          _transactions = transactionData;
          notifyListeners();
        });
      } else {
        _user = null;
        _transactions = [];
        notifyListeners();
      }
    });
  }

  Future<void> loadMoney(double amount) async {
    if (_user == null) return;
    await _firestoreService.updateBalance(
      _user!.uid,
      amount,
      'credit',
      'Wallet Top-up',
    );
  }

  Future<void> sendMoney(double amount, String description) async {
    if (_user == null || _user!.balance < amount) return;
    await _firestoreService.updateBalance(
      _user!.uid,
      amount,
      'debit',
      description,
    );
  }

  Future<void> transferMoney({
    required String receiverId,
    required double amount,
    String description = "P2P Transfer",
  }) async {
    if (_user == null) return;
    await _firestoreService.performTransfer(
      senderId: _user!.uid,
      receiverId: receiverId,
      amount: amount,
      description: description,
    );
  }
}
