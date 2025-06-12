import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:note_tasky_ver2/auth/auth_service.dart';
import 'package:note_tasky_ver2/auth/login_screen.dart';
import 'package:note_tasky_ver2/home_screen.dart';
import 'package:note_tasky_ver2/widget/button.dart';
import 'package:note_tasky_ver2/widget/textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _name.dispose();
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
                  const SizedBox(height: 60),
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
                    "Create your account",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Signup Card
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
                          "Get Started",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create your account",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Name Field
                        CustomTextField(
                          hint: "Enter your name",
                          label: "Name",
                          controller: _name,
                          prefixIcon: Icons.person,
                          keyboardType: TextInputType.text,
                          obscureText: false,
                        ),
                        const SizedBox(height: 20),

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

                        // Password Requirements
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password must be at least 6 characters",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Signup Button
                        _isLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(
                                label: "Sign Up",
                                onPressed: _signup,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 24),

                        // Login Prompt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            InkWell(
                              onTap: () => goToLogin(context),
                              child: Text(
                                "Login",
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

  goToLogin(BuildContext context) => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );

  goToHome(BuildContext context) => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );

  _signup() async {
    if (_name.text.trim().isEmpty) {
      _showError("Please enter your name");
      return;
    }

    if (_email.text.trim().isEmpty) {
      _showError("Please enter your email");
      return;
    }

    if (_password.text.trim().isEmpty) {
      _showError("Please enter your password");
      return;
    }

    if (_password.text.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _auth.createUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
        _name.text.trim(),
      );

      if (user != null) {
        log("User Created Successfully");
        goToHome(context);
      }
    } catch (e) {
      _showError("Failed to create account: ${e.toString()}");
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
