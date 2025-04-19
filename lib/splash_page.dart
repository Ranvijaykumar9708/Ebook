import 'package:e_book_reader/screens/auth_pages/login_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _iconAnimationController;
  late AnimationController _textAnimationController;
  late Animation<double> _iconAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controllers
    _iconAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _textAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Set up the animations
    _iconAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _iconAnimationController, curve: Curves.easeInOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeInOut),
    );

    // Start the animations
    _iconAnimationController.forward();
    _textAnimationController.forward();

    // Navigate to the next page after a delay
    _navigateToNextPage();
  }

  // Function to navigate to the LoginPage after 8 seconds
  void _navigateToNextPage() {
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()), // Ensure LoginPage is properly defined
      );
    });
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC), // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon with scaling effect
            ScaleTransition(
              scale: _iconAnimation,
              child: const Icon(
                Icons.menu_book_rounded,
                size: 130,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            // Animated Text with fade-in effect
            FadeTransition(
              opacity: _textAnimation,
              child: const Text(
                "Welcome to eBook Reader",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _textAnimation,
              child: const Text(
                "Your gateway to a world of knowledge",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
