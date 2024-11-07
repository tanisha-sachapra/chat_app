import 'dart:developer';
import 'package:chatdemo/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUserEmail;

  const ChatScreen({super.key, required this.chatWithUserEmail});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final LoginScreen loginScreen = LoginScreen();
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to send a message
  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore.collection('messages').add({
        'text': _messageController.text,
        'sender': _auth.currentUser?.email,
        'receiver': widget.chatWithUserEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser?.email;
    final chatWithUserEmail = widget.chatWithUserEmail;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text('${widget.chatWithUserEmail.split('@')[0]}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await loginScreen.SignOut(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('sender', isEqualTo: currentUser)
                  .where('receiver', isEqualTo: chatWithUserEmail)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final senderMessages = snapshot.data!.docs;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .where('sender', isEqualTo: chatWithUserEmail)
                      .where('receiver', isEqualTo: currentUser)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshotReceiver) {
                    if (!snapshotReceiver.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshotReceiver.hasError) {
                      return Center(
                          child: Text('Error: ${snapshotReceiver.error}'));
                    }

                    final receiverMessages = snapshotReceiver.data!.docs;
                    log('Receiver Messages: ${receiverMessages.length}');

                    final combinedMessages = [
                      ...senderMessages,
                      ...receiverMessages
                    ];

                    combinedMessages.sort((a, b) {
                      final aTimestamp =
                          a['timestamp'] as Timestamp? ?? Timestamp.now();
                      final bTimestamp =
                          b['timestamp'] as Timestamp? ?? Timestamp.now();
                      return bTimestamp.compareTo(aTimestamp);
                    });

                    if (combinedMessages.isEmpty) {
                      return const Center(
                        child: Text(
                          "No messages yet. Start chatting!",
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    return ListView.builder(
                      reverse: true,
                      itemCount: combinedMessages.length,
                      itemBuilder: (context, index) {
                        final message = combinedMessages[index];
                        final isCurrentUser = message['sender'] == currentUser;

                        return Align(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.blueAccent.withOpacity(0.8)
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: isCurrentUser
                                    ? const Radius.circular(12)
                                    : const Radius.circular(0),
                                bottomRight: isCurrentUser
                                    ? const Radius.circular(0)
                                    : const Radius.circular(12),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 1,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                message['sender'] == currentUser
                                    ? Text(
                                        'You',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isCurrentUser
                                              ? Colors.white
                                              : Colors.black54,
                                        ),
                                      )
                                    : Text(
                                        // Make sure to return a Text widget in both cases
                                        chatWithUserEmail.split('@')[0],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors
                                              .grey, // or any other style you want for non-current users
                                        ),
                                      ),
                                const SizedBox(height: 5),
                                Text(
                                  message['text'],
                                  style: TextStyle(
                                    color: isCurrentUser
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: _sendMessage,
                  color: Colors.blueAccent,
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
