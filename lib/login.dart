import 'package:chatdemo/chat.dart';
import 'package:chatdemo/chatlist.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Function to handle sign-in
  Future<void> signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Chatlist()),
      );
    } catch (e) {
      print(e); // Show error message if login fails
      // You can also show a dialog or a snackbar with the error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'chat app',
                  style: TextStyle(color: Colors.black),
                ),
                const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.blue),
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 20),
                // Password TextField
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                // Login Button
                ElevatedButton(
                  onPressed: signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 89, 137, 219),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                // Forgot Password Text
                GestureDetector(
                  onTap: () {
                    // Handle Forgot Password action
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        // Navigate to sign-up screen
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
