import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenAIService {
  // Replace with your OpenAI API key
  final String _apiKey = 'YOUR_OPENAI_API_KEY';

  Future<String> generateResponse(String userMessage) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    // Define system-level instructions for a medical context
    final systemMessage = {
      'role': 'system',
      'content': 'You are a medical professional. Respond with evidence-based information and always consider medical guidelines in your answers. Provide concise, reliable, and accurate medical information.'
    };

    // User's medical query
    final userMessageData = {
      'role': 'user',
      'content': userMessage,
    };

    // Full body for the API request
    final body = json.encode({
      'model': 'gpt-3.5-turbo',  // You can use 'gpt-4' for better quality
      'messages': [systemMessage, userMessageData],
      'temperature': 0.3,  // Lower temperature for more focused responses
      'max_tokens': 300,   // Limit the length of the response
    });

    try {
      // Make the API request
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Successful API response
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        // Print the status code and response body for debugging
        print('Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return 'Error: Unable to get response from API.';
      }
    } catch (error) {
      // Catch network or other errors
      print('Request failed: $error');
      return 'Error: Unable to make the request. Please check your network connection.';
    }
  }
}
