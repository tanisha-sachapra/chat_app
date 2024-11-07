import 'dart:developer';

import 'package:chatdemo/chat.dart';
import 'package:chatdemo/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Chatlist extends StatefulWidget {
  const Chatlist({super.key});

  @override
  State<Chatlist> createState() => _ChatlistState();
}

class _ChatlistState extends State<Chatlist> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to get the list of users excluding the currently logged-in user
  Stream<QuerySnapshot<Map<String, dynamic>>> _getUserList() {
    return _firestore
        .collection('users')
        .where('email', isNotEqualTo: _auth.currentUser?.email)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 236, 236),
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Icon(Icons.arrow_back)),
        centerTitle: true,
        title: const Text("Users"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 5),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getUserList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users available"));
                }

                final users = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userName = user['email'] ?? 'Unknown User';
                    final userEmail = user['email'] ?? 'No Email';
                    final userProfilePic = user['profilePicture'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        color: Colors.white,
                        child: ListTile(
                          leading: userProfilePic != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(userProfilePic),
                                )
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text('${userName.split('@')[0]}'),
                          subtitle: Text(userEmail),
                          onTap: () {
                            log('user email :$userEmail');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatWithUserEmail: userName,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
