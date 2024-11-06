import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  AuthProvider() {
    _user = _firebaseAuth.currentUser;
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  bool get isAuthenticated => _user != null;

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } catch (e) {
      print("Error in sign-in: $e");
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners();
  }
}
