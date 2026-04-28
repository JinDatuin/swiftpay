import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/wallet_provider.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  
  UserModel? _foundUser;
  bool _isSearching = false;
  bool _isProcessing = false;

  void _searchUser() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() => _isSearching = true);
    final user = await _firestoreService.searchUser(_searchController.text);
    setState(() {
      _foundUser = user;
      _isSearching = false;
    });

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
      }
    }
  }

  void _handleTransfer() async {
    if (_foundUser == null) return;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    if (walletProvider.user!.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insufficient balance")),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await walletProvider.transferMoney(
        receiverId: _foundUser!.uid,
        amount: amount,
      );
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Transfer failed: $e")),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Transfer Successful!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "You have sent \$${_amountController.text} to ${_foundUser!.fullName}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to Wallet
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A59FF),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Done", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    final userBalance = Provider.of<WalletProvider>(context).user?.balance ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("Transfer Money", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section
            const Text(
              "Send to",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Phone number or User ID",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _searchUser(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    // UI Only: Show a placeholder for QR Scanner
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("QR Scanner opening... (UI Only)")),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A59FF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Found User Section
            if (_isSearching)
              const Center(child: CircularProgressIndicator())
            else if (_foundUser != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(_foundUser!.profileImageUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _foundUser!.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            _foundUser!.phoneNumber,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _foundUser = null),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Amount Section
            const Text(
              "Amount",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "0.00",
                prefixText: r"$ ",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                "Available Balance: ${currencyFormat.format(userBalance)}",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 48),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_foundUser != null && !_isProcessing) ? _handleTransfer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A59FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Send Now",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
