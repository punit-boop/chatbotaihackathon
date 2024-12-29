import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();

  String? _userName; // Store logged-in user's name
  String? _userId; // Store logged-in user's UID

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  // Fetch the logged-in user's UID and name from Firestore
  Future<void> _fetchCurrentUser() async {
    final user = _auth.currentUser; // Get the currently logged-in user
    if (user != null) {
      _userId = user.uid; // Store UID

      // Fetch user's name from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'] as String?;
        });
      }
    }
  }

  // Function to post a message to Firestore
  Future<void> _postMessage() async {
    final String message = _controller.text.trim(); // Get the input message

    // Check if the message is empty or user data is missing
    if (message.isEmpty || _userId == null || _userName == null) return;

    try {
      // Add message to Firestore
      await _firestore.collection('community_messages').add({
        'uid': _userId, // UID of the sender
        'name': _userName, // Name of the sender
        'message': message, // Message text
        'timestamp': FieldValue.serverTimestamp(), // Time of posting
      });
      _controller.clear(); // Clear the text field after posting
    } catch (e) {
      print('Error posting message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/bkg3.png', // Replace with your background image path
              fit: BoxFit.cover,
            ),
          ),
          // Community Interface
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Messages List
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('community_messages')
                            .orderBy('timestamp', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text('No messages yet! Be the first to post.',
                                  style: TextStyle(
                                    fontFamily: 'Kristen',
                                    fontSize: 16,
                                  )),
                            );
                          }

                          final messages = snapshot.data!.docs;

                          return ListView.builder(
                            padding: const EdgeInsets.only(
                              top: 10,
                              left: 10,
                              right: 10,
                              bottom: 80, // Add padding for navigation bar space
                            ),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index].data() as Map<String, dynamic>;
                              final name = message['name'] ?? 'Anonymous';
                              final text = message['message'] ?? '';
                              final timestamp = message['timestamp'] as Timestamp?;
                              final time = timestamp?.toDate() ?? DateTime.now();

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Color(0xFFC8786D),
                                      child: Icon(Icons.person, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontFamily: 'Kristen',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.brown,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            text,
                                            style: const TextStyle(
                                              fontFamily: 'Kristen',
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Input and Actions
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'Write a message...',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Kristen',
                                  color: Colors.grey,
                                ),
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.brown.withOpacity(0.8),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send, color: Color(0xFFC8786D)),
                            onPressed: _postMessage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
