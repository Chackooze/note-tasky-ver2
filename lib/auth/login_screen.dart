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

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text("Login",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              isPassword: true,
              controller: _password,
            ),
            const SizedBox(height: 30),
            _isLoading 
                ? const CircularProgressIndicator()
                : CustomButton(
                    label: "Login",
                    onPressed: _login,
                  ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don't have an account? "),
              InkWell(
                onTap: () => goToSignup(context),
                child:
                    const Text("Signup", style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer()
          ],
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
    // Validate input
    if (_email.text.trim().isEmpty) {
      _showError("Please enter your email");
      return;
    }
    
    if (_password.text.trim().isEmpty) {
      _showError("Please enter your password");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _auth.loginUserWithEmailAndPassword(
        _email.text.trim(), 
        _password.text.trim()
      );

      if (user != null) {
        log("User Logged In");
        goToHome(context);
      }
    } catch (e) {
      _showError("Failed to login: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}