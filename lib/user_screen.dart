import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userName = '';
  String joinedDate = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            userName = data?['name'] ?? 'Unknown User';
            final timestamp =
                data?['createdAt'] as Timestamp? ?? Timestamp.now();
            joinedDate = _formatDate(timestamp.toDate());
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _logout() async {
    bool confirm = await _showConfirmationDialog(
      title: "Confirm Logout",
      message: "Are you sure you want to logout?",
    );

    if (confirm) {
      try {
        await _auth.signOut();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignupPage()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _requestAccountDeletion() async {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Center(
            child: Text(
              "Request Account Deletion",
              style: TextStyle(
                fontFamily: 'Kristen',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: "Why do you want to delete your account?",
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Reason cannot be empty!")),
                  );
                  return;
                }

                // Show confirmation dialog
                bool confirm = await _showConfirmationDialog(
                  title: "Confirm Deletion Request",
                  message:
                      "Are you sure you want to request account deletion? This action cannot be undone.",
                );

                if (confirm) {
                  Navigator.of(dialogContext).pop(); // Close the main dialog
                  try {
                    final user = _auth.currentUser;
                    if (user != null) {
                      await _firestore
                          .collection('accountDeletionRequests')
                          .add({
                        'userId': user.uid,
                        'userName': userName,
                        'reason': reason,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Your request for account deletion has been submitted."),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
              child: const Text(
                "Submit",
                style: TextStyle(color: Color(0xFFC8786D)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendSuggestion() async {
    TextEditingController suggestionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Center(
            child: Text(
              "Send Suggestion",
              style: TextStyle(
                fontFamily: 'Kristen',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ),
          content: TextField(
            controller: suggestionController,
            decoration: const InputDecoration(
              hintText: "Enter your suggestion...",
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final suggestion = suggestionController.text.trim();
                if (suggestion.isEmpty) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Suggestion cannot be empty!")),
                  );
                  return;
                }

                // Show confirmation dialog
                bool confirm = await _showConfirmationDialog(
                  title: "Confirm Suggestion",
                  message: "Do you want to submit this suggestion?",
                );

                if (confirm) {
                  Navigator.of(dialogContext).pop();
                  try {
                    await _firestore.collection('suggestions').add({
                      'userId': _auth.currentUser?.uid ?? '',
                      'userName': userName,
                      'suggestion': suggestion,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Your suggestion has been sent. Thank you!"),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
              child: const Text(
                "Send",
                style: TextStyle(color: Color(0xFFC8786D)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmationDialog(
      {required String title, required String message}) async {
    return await showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Kristen',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
              content: Text(
                message,
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text("No", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text(
                    "Yes",
                    style: TextStyle(color: Color(0xFFC8786D)),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/backgrounds/bkg4.png',
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.8,
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFC8786D),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontFamily: 'Kristen',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Joined on: $joinedDate',
                            style: const TextStyle(
                              fontFamily: 'Kristen',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit,
                                      color: Colors.brown),
                                  title: const Text(
                                    "Send Suggestion",
                                    style: TextStyle(
                                      fontFamily: 'Kristen',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                  onTap: _sendSuggestion,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete,
                                      color: Colors.brown),
                                  title: const Text(
                                    "Request Account Deletion",
                                    style: TextStyle(
                                      fontFamily: 'Kristen',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                  onTap: _requestAccountDeletion,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.logout,
                                      color: Colors.brown),
                                  title: const Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontFamily: 'Kristen',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                  onTap: _logout,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
