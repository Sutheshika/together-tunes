import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import '../../config/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔌 Connecting to: ${ApiConfig.loginUrl}');
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // TODO: Store token and user data
        print('Login successful: ${data['user']['username']}');
        // Navigate to main app
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['message'] ?? 'Login failed'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Network error: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Connection Error'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cannot connect to backend server.'),
                  const SizedBox(height: 16),
                  const Text('Current URL:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SelectableText(
                    ApiConfig.loginUrl,
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  const Text('📋 FIX STEPS:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent)),
                  const SizedBox(height: 8),
                  const Text('1️⃣ Get your PC IP address:'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const SelectableText(
                      'ipconfig',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Look for "IPv4 Address" (e.g., 192.168.1.100)'),
                  const SizedBox(height: 16),
                  const Text('2️⃣ Edit lib/config/api_config.dart'),
                  const SizedBox(height: 8),
                  const Text('Change this line:'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const SelectableText(
                      'static const String baseUrl = \'http://localhost:3001\';',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('To:'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const SelectableText(
                      'static const String baseUrl = \'http://192.168.1.100:3001\';',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('3️⃣ Rebuild the app:'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const SelectableText(
                      'flutter clean && flutter pub get && flutter run',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
                  padding: EdgeInsets.zero,
                ).animate().fadeIn().slideX(begin: -0.2),

                const SizedBox(height: 40),

                // Header
                Text(
                  'Welcome\nBack!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    height: 1.2,
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                const SizedBox(height: 16),

                Text(
                  'Sign in to continue your musical journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                const SizedBox(height: 60),

                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: 'Enter your email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.3),

                      const SizedBox(height: 24),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                          hintText: 'Enter your password',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _login(),
                      ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.3),

                      const SizedBox(height: 16),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Forgot password feature coming soon!'),
                              ),
                            );
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ).animate().fadeIn(delay: 1000.ms),

                      const SizedBox(height: 40),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: _isLoading ? 'Signing in...' : 'Sign In',
                          onPressed: _isLoading ? () {} : () => _login(),
                          isLoading: _isLoading,
                        ),
                      ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3),

                      const SizedBox(height: 32),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppTheme.textSecondary.withOpacity(0.3))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                          Expanded(child: Divider(color: AppTheme.textSecondary.withOpacity(0.3))),
                        ],
                      ).animate().fadeIn(delay: 1400.ms),

                      const SizedBox(height: 32),

                      // Social Login Buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Google sign-in coming soon!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.g_mobiledata, size: 24),
                              label: const Text('Continue with Google'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                                foregroundColor: AppTheme.textPrimary,
                              ),
                            ),
                          ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Apple sign-in coming soon!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.apple, size: 20),
                              label: const Text('Continue with Apple'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                                foregroundColor: AppTheme.textPrimary,
                              ),
                            ),
                          ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.3),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/register');
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
}