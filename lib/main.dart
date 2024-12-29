import 'package:chatbotai/chat_screen.dart';
import 'package:chatbotai/content_page.dart';
import 'package:chatbotai/login_page.dart';
import 'package:chatbotai/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    runApp(ErrorApp(errorMessage: 'Firebase initialization failed: $e'));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat BOT AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(), // Set LoginPage as the initial page
    );
  }
}

// Error screen for Firebase initialization failure
class ErrorApp extends StatelessWidget {
  final String errorMessage;

  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
