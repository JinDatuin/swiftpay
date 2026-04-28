import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isModal;
  const LoginScreen({super.key, this.isModal = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    var user = await _authService.signIn(email.text, password.text);

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login failed. Please check your credentials.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: widget.isModal ? 12 : 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isModal)
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Text(
              "Welcome Back",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A59FF),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Login to your account",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            SizedBox(height: 32),
            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: password,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 32),
            _isLoading
                ? CircularProgressIndicator(color: Color(0xFF7A59FF))
                : ElevatedButton(
                  onPressed: loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7A59FF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  child: Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    if (widget.isModal) Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(
                      color: Color(0xFF7A59FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (widget.isModal) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: content,
    );
  }
}
