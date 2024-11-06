import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInDemo extends StatefulWidget {
  @override
  _GoogleSignInDemoState createState() => _GoogleSignInDemoState();
}

class _GoogleSignInDemoState extends State<GoogleSignInDemo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      setState(() {
        _user = userCredential.user;
      });
    } catch (e) {
      print("Error signing in with Google: $e");
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign-In Demo'),
      ),
      body: Center(
        child: _user == null
            ? ElevatedButton(
                onPressed: _signInWithGoogle,
                child: Text('Sign in with Google'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Signed in as: ${_user!.displayName}'),
                  SizedBox(height: 16),
                  CircleAvatar(
                    backgroundImage: NetworkImage(_user!.photoURL ?? ''),
                    radius: 40,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: Text('Sign Out'),
                  ),
                ],
              ),
      ),
    );
  }
}
