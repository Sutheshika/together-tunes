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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Hero Section
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.headphones,
                            size: 60,
                            color: Colors.white,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .scale(delay: 200.ms, duration: 600.ms),

                        const SizedBox(height: 30),

                        // Welcome Text
                        const Text(
                          'Welcome to',
                          style: TextStyle(
                            fontSize: 20,
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
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 800.ms)
                            .slideY(begin: 0.3, delay: 800.ms),

                        const SizedBox(height: 20),

                        // Features List
                        _buildFeatureItem(
                          icon: Icons.sync,
                          title: 'Perfect Sync',
                          subtitle: 'Listen in real-time with friends',
                          delay: 1000,
                        ),
                        
                        _buildFeatureItem(
                          icon: Icons.chat,
                          title: 'Live Chat',
                          subtitle: 'Share your thoughts while listening',
                          delay: 1200,
                        ),
                        
                        _buildFeatureItem(
                          icon: Icons.playlist_play,
                          title: 'Shared Playlists',
                          subtitle: 'Create music collections together',
                          delay: 1400,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Buttons Section
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: 'Login',
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, _) =>
                                    const LoginScreen(),
                                transitionDuration: const Duration(milliseconds: 300),
                                transitionsBuilder: (context, animation, _, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.3),

                      const SizedBox(height: 16),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: 'Create Account',
                          isSecondary: true,
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, _) =>
                                    const RegisterScreen(),
                                transitionDuration: const Duration(milliseconds: 300),
                                transitionsBuilder: (context, animation, _, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3),

                      const SizedBox(height: 40),

                      // Terms & Privacy
                      Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary.withOpacity(0.7),
                        ),
                      ).animate().fadeIn(delay: 2000.ms),
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

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: -0.3);
  }
}