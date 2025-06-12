import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:note_tasky_ver2/auth/auth_service.dart';
import 'package:note_tasky_ver2/auth/signup_screen.dart';
import 'package:note_tasky_ver2/home_screen.dart';
import 'package:note_tasky_ver2/widget/button.dart';
import 'package:note_tasky_ver2/widget/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  // App Logo/Title
                  const Text(
                    "NoteTasky",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your productivity companion",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Login to continue",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Email Field
                        CustomTextField(
                          hint: "Enter your email",
                          label: "Email",
                          controller: _email,
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          obscureText: false,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        CustomTextField(
                          hint: "Enter your password",
                          label: "Password",
                          isPassword: true,
                          obscureText: _obscurePassword,
                          controller: _password,
                          prefixIcon: Icons.lock,
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 10),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Add forgot password functionality
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.purple[400]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login Button
                        _isLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(
                                label: "Login",
                                onPressed: _login,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 24),

                        // Signup Prompt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            InkWell(
                              onTap: () => goToSignup(context),
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.purple[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const SignupScreen()),
  );

  goToHome(BuildContext context) => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );

  _login() async {
    if (_email.text.trim().isEmpty) {
      _showError("Please enter your email");
      return;
    }

    if (_password.text.trim().isEmpty) {
      _showError("Please enter your password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _auth.loginUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        log("User Logged In");
        goToHome(context);
      }
    } catch (e) {
      _showError("Failed to login: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
