import 'dart:convert';

import 'package:http/http.dart' as http;

class GenerateChatService {
  static const String _apiUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String _model = 'glm-4-flash';
  static const String _apiKey = '3dd2b2c660c34596aebfe9573a40cd4d.FnGGDXHR5fhODv39';

  Future<String> chat({
    required String teacherName,
    required String danceType,
    required String backgroundIntro,
    required List<Map<String, String>> history,
    required String userMessage,
  }) async {
    final List<Map<String, String>> messages = <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content':
            'You are $teacherName, a dance teacher. Dance type: $danceType. '
                'Background: $backgroundIntro. Reply in English only. '
                'Keep responses friendly, practical, and short.',
      },
      ...history,
      <String, String>{'role': 'user', 'content': userMessage},
    ];

    final http.Response response = await http
        .post(
          Uri.parse(_apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode(<String, dynamic>{
            'model': _model,
            'messages': messages,
            'temperature': 0.7,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Generate chat request failed (${response.statusCode}).');
    }

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    final dynamic choices = data['choices'];
    if (choices is List && choices.isNotEmpty) {
      final dynamic message = (choices.first as Map<String, dynamic>)['message'];
      if (message is Map<String, dynamic>) {
        final dynamic content = message['content'];
        if (content is String && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
    }

    throw Exception('Generate chat returned an empty response.');
  }
}
