import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatbotai/content_page.dart';
import 'package:chatbotai/signup_page.dart'; // Import SignupPage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false; // Loading state

  // Method to handle login
  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      _isLoading = true; // Start loading
      _errorMessage = ''; // Clear previous errors
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Navigate to content page after successful login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ContentPage()),
              (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      // Show Snackbar for error message
      if (_errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.deepPurple, // Matches the theme
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.fixed,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
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
              'assets/backgrounds/bkg2.png', // Replace with your background image path
              fit: BoxFit.cover,
            ),
          ),
          // Login Form
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // Semi-transparent background
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Login to your account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kristen',
                        color: Color(0xFF505050),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.brown),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.brown),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFFC8786D),
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                            : const Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Kristen',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Create Account Link
                    Column(
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Color(0xFF505050),
                            fontFamily: 'Kristen',
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Color(0xFFC8786D),
                              fontFamily: 'Kristen',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
