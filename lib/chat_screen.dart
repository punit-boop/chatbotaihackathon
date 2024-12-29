import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [
    {
      "role": "bot",
      "message": "Hello! How can I assist you today?",
    }
  ];
  late stt.SpeechToText _speech;
  bool _isListening = false;

  final String _apiKey = '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';
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<String> _generateResponse(String userMessage) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = json.encode({
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'user', 'content': userMessage},
      ],
      'max_tokens': 150,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      return 'Error: Unable to get response from API.';
    }
  }

  void _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "message": userMessage});
      _controller.clear();
    });

    String botResponse = await _generateResponse(userMessage);

    setState(() {
      messages.add({"role": "bot", "message": botResponse});
    });
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      bool available = await _speech.initialize(onStatus: (status) {
        if (status == "notListening") {
          setState(() {
            _isListening = false;
          });
        }
      });
      if (available) {
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
        );
        setState(() {
          _isListening = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech recognition is not available.')),
        );
      }
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
              'assets/backgrounds/bkg1.png', // Replace with your background image path
              fit: BoxFit.cover,
            ),
          ),
          // Chat Interface
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8), // Padding from top for heading
                  const Text(
                    'Chat with AI',
                    style: TextStyle(
                      fontFamily: 'Kristen',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16), // Padding between heading and card
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.95,
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
                          // Chat Messages
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(
                                top: 10,
                                left: 10,
                                right: 10,
                                bottom: 10, // Adjusted padding to avoid overflow
                              ),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return Align(
                                  alignment: message['role'] == "user"
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: message['role'] == "user"
                                          ? const Color(0xFFC8786D).withOpacity(0.8)
                                          : const Color(0xFF90CAF9).withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      message['message'] ?? "",
                                      style: const TextStyle(
                                        fontFamily: 'Kristen',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
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
                                      hintText: 'Type your message...',
                                      hintStyle: const TextStyle(
                                        fontFamily: 'Kristen',
                                        color: Colors.grey,
                                      ),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.brown, width: 2.0),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    _isListening ? Icons.mic_off : Icons.mic,
                                    color: _isListening ? Colors.red : const Color(0xFFC8786D),
                                  ),
                                  onPressed: _toggleListening,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send, color: Color(0xFFC8786D)),
                                  onPressed: _sendMessage,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
