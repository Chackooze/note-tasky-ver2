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

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
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
            const Text("Signup",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 50,
            ),
            CustomTextField(
              hint: "Enter Name",
              label: "Name",
              controller: _name,
            ),
            const SizedBox(height: 20),
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
                    label: "Signup",
                    onPressed: _signup,
                  ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Already have an account? "),
              InkWell(
                onTap: () => goToLogin(context),
                child: const Text("Login", style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer()
          ],
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
    // Validate input
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

    setState(() {
      _isLoading = true;
    });

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