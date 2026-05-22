import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Replace with your key from https://aistudio.google.com/app/apikey
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  static const String _model = 'gemini-1.5-flash';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

  static const String _systemPrompt = '''
You are vBlaFarm AI assistant for Block 3A indoor vertical farm.
Farm data:
- Rack A: Spinach, Mature, 3 days to harvest, Temp 22.1°C, Humidity 68%, pH 6.2, EC 1.6
- Rack B: Romaine Lettuce, Seedling, 3 days to harvest, Temp 24.8°C, Humidity 75%, pH 6.8, EC 2.1
  - Level 3 Plant 02: Nitrogen Deficiency (78% health, 91% confidence) - increase nutrients 10%
  - Level 3 Plant 04: Possible Disease (45% health, 87% confidence) - isolate immediately  
  - Level 5: All plants healthy
- Rack C: Butterhead Lettuce, Vegetative, 8 days to harvest, Temp 23.4°C, Humidity 71%, pH 6.5, EC 1.9
Keep responses SHORT (2-4 sentences), conversational, WhatsApp style.
Always give specific actionable advice. Never say you don't have access to the farm.
''';

  static bool get isConfigured =>
      _apiKey != 'YOUR_GEMINI_API_KEY' && _apiKey.isNotEmpty;

  static Future<String?> chat(
    String userMessage, {
    List<Map<String, String>>? history,
  }) async {
    if (!isConfigured) return null;
    try {
      final contents = <Map<String, dynamic>>[];

      if (history != null) {
        for (final msg in history) {
          contents.add({
            'role': msg['role'] == 'bot' ? 'model' : 'user',
            'parts': [
              {'text': msg['text']},
            ],
          });
        }
      }
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userMessage},
        ],
      });

      final body = jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': _systemPrompt},
          ],
        },
        'contents': contents,
        'generationConfig': {'maxOutputTokens': 200, 'temperature': 0.7},
      });

      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String?;
      }
    } catch (_) {}
    return null;
  }
}
