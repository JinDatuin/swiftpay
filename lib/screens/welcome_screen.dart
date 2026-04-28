import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _showForm(BuildContext context, Widget form) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => form,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE589FF), // Soft Pink/Purple
              Color(0xFF8E66FF), // Vibrant Purple
              Color(0xFF7A59FF), // Deep Purple
            ],
          ),
        ),
        child: Stack(
          children: [
            // Subtle wavy lines (using a CustomPainter for the background effect)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: WavyLinesPainter()),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo Container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.speed,
                        size: 70,
                        color: const Color(0xFF8E66FF),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Name
                  const Text(
                    "SwiftPay",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Buttons and Login text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => _showForm(context, const RegisterScreen(isModal: true)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7A59FF),
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _showForm(context, const LoginScreen(isModal: true)),
                          child: Text(
                            "I already have an account",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to mimic the wavy lines pattern from the reference image
class WavyLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    for (var i = 0; i < 40; i++) {
      final path = Path();
      path.moveTo(0, size.height * (i / 30) - 100);
      path.quadraticBezierTo(
        size.width / 2,
        size.height * (i / 30) + 100,
        size.width,
        size.height * (i / 30) - 100,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
