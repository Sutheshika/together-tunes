import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hero Section
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.headphones,
                          size: 80,
                          color: Colors.white,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .scale(delay: 200.ms, duration: 600.ms),

                      const SizedBox(height: 40),

                      // Welcome Text
                      const Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 600.ms)
                          .slideY(begin: 0.2, delay: 600.ms),

                      const Text(
                        'Together Tunes',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 800.ms)
                          .slideY(begin: 0.3, delay: 800.ms),

                      const SizedBox(height: 40),

                      // Features
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sync, color: AppTheme.primaryColor, size: 20),
                          SizedBox(width: 8),
                          Text('Perfect Sync', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                          SizedBox(width: 20),
                          Icon(Icons.chat, color: AppTheme.primaryColor, size: 20),
                          SizedBox(width: 8),
                          Text('Live Chat', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                        ],
                      ).animate().fadeIn(delay: 1000.ms),
                    ],
                  ),
                ),

                // Buttons Section
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: 'Login',
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ));
                          },
                        ),
                      ).animate().fadeIn(delay: 1600.ms),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: 'Create Account',
                          isSecondary: true,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ));
                          },
                        ),
                      ).animate().fadeIn(delay: 1800.ms),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}