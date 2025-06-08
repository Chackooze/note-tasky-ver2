import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  
  // Add getter for uid
  String get uid => _auth.currentUser?.uid ?? '';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      print('Attempting to register with email: $email');
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      
      if (user != null) {
        // Update display name
        await user.updateDisplayName(displayName);
        
        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        print('User created successfully: ${user.uid}');
      }
      
      return user;
    } catch (e) {
      print("Error creating user: $e");
      log("Something went wrong: $e");
      rethrow; // Re-throw to handle in UI
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      print("Error logging in: $e");
      log("Something went wrong: $e");
      rethrow; // Re-throw to handle in UI
    }
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
      log("Something went wrong: $e");
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
    return null;
  }
}