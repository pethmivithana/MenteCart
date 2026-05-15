import 'package:flutter/material.dart';

/// Splash screen - displays loading state with engaging UI while auth is checked
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF4B44CC),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo emoji with animation feel
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const Text(
                      '🧠',
                      style: TextStyle(fontSize: 80),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // App name
              const Text(
                'MenteCart',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              // Tagline
              const Text(
                'Book Mental Wellness Services ✨',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 80),
              // Loading indicator with custom styling
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              // Loading text
              const Text(
                'Loading your wellness journey...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
