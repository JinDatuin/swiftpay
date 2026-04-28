import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save or Update User data
  Future<void> saveUser(UserModel user) async {
    await _db
        .collection('users')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  // Get User data
  Future<UserModel?> getUser(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Update Balance
  Future<void> updateBalance(
    String uid,
    double amount,
    String type,
    String description,
  ) async {
    final userRef = _db.collection('users').doc(uid);
    final transactionRef =
        _db.collection('users').doc(uid).collection('transactions').doc();

    await _db.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) return;

      double currentBalance =
          (userSnapshot.data()?['balance'] ?? 0.0).toDouble();
      double newBalance =
          type == 'credit' ? currentBalance + amount : currentBalance - amount;

      transaction.update(userRef, {'balance': newBalance});

      transaction.set(transactionRef, {
        'id': transactionRef.id,
        'amount': amount,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'description': description,
      });
    });
  }

  // Stream User Data (Real-time balance)
  Stream<UserModel?> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Stream Transactions
  Stream<List<TransactionModel>> streamTransactions(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Mask full name like: J****s Z****l
  String maskFullName(String fullName) {
    List<String> parts = fullName.trim().split(' ');

    return parts
        .map((word) {
          if (word.isEmpty) return "";

          if (word.length <= 2) {
            return word[0] + "*";
          }

          return word[0] + "*" * (word.length - 2) + word[word.length - 1];
        })
        .join(' ');
  }

  // Search User by Phone or UID
  Future<UserModel?> searchUser(String query) async {
    // Search by UID first
    var doc = await _db.collection('users').doc(query).get();

    if (doc.exists) {
      return _buildMaskedUser(doc.data()!);
    }

    // Search by Phone Number
    var snapshot =
        await _db
            .collection('users')
            .where('phoneNumber', isEqualTo: query)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      return _buildMaskedUser(snapshot.docs.first.data());
    }

    return null;
  }

  // Build user and apply masking safely
  UserModel _buildMaskedUser(Map<String, dynamic> data) {
    UserModel user = UserModel.fromMap(data);

    return UserModel(
      uid: user.uid,
      phoneNumber: user.phoneNumber,
      email: user.email,
      fullName: maskFullName(user.fullName), // 👈 masked name here
      // add other fields if you have them:
      // photoUrl: user.photoUrl,
      // etc...
    );
  }

  // Perform P2P Transfer
  Future<void> performTransfer({
    required String senderId,
    required String receiverId,
    required double amount,
    required String description,
  }) async {
    final senderRef = _db.collection('users').doc(senderId);
    final receiverRef = _db.collection('users').doc(receiverId);
    final senderTxRef = senderRef.collection('transactions').doc();
    final receiverTxRef = receiverRef.collection('transactions').doc();

    await _db.runTransaction((transaction) async {
      final senderSnap = await transaction.get(senderRef);
      final receiverSnap = await transaction.get(receiverRef);

      if (!senderSnap.exists || !receiverSnap.exists)
        throw Exception("User not found");

      double senderBalance = (senderSnap.data()?['balance'] ?? 0.0).toDouble();
      if (senderBalance < amount) throw Exception("Insufficient balance");

      double receiverBalance =
          (receiverSnap.data()?['balance'] ?? 0.0).toDouble();

      // Update balances
      transaction.update(senderRef, {'balance': senderBalance - amount});
      transaction.update(receiverRef, {'balance': receiverBalance + amount});

      // Log Sender Transaction (Debit)
      transaction.set(senderTxRef, {
        'id': senderTxRef.id,
        'amount': amount,
        'type': 'debit',
        'timestamp': FieldValue.serverTimestamp(),
        'description': "Transfer to ${receiverSnap.data()?['fullName']}",
        'category': 'Transfer',
      });

      // Log Receiver Transaction (Credit)
      transaction.set(receiverTxRef, {
        'id': receiverTxRef.id,
        'amount': amount,
        'type': 'credit',
        'timestamp': FieldValue.serverTimestamp(),
        'description': "Received from ${senderSnap.data()?['fullName']}",
        'category': 'Transfer',
      });
    });
  }
}
