import '../../domain/repositories/abstract/poem_repository.dart';
// ignore: unused_import
import 'dart:convert';
// ignore: unused_import
import 'package:http/http.dart' as http;

class PoemRepositoryImpl implements PoemRepository {
  PoemRepositoryImpl();

  @override
  Future<String> getPoems(String productName) async {
    var apiKey = 'AIzaSyAkax4PVm7pPvNKdx_L_RTwWk60e-o0SeY';
    const haikuCount = 5;

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta2/models/chat-bison-001:generateMessage?key=$apiKey');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "prompt": {
        "context": "You are an awesome haiku writer.",
        "examples": [
          {
            "input": {"content": "Write a haiku about Google Photos."},
            "output": {
              "content":
                  "Google Photos, my friend\nA journey of a lifetime\nCaptured in pixels"
            }
          }
        ],
        "messages": [
          {"content": "Write a cool haiku for $productName"}
        ]
      },
      "candidate_count": haikuCount,
      "temperature": 1,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        String haikus = 'Here are $haikuCount haikus about $productName:\n\n';
        for (var i = 0; i < haikuCount; i++) {
          haikus += '${i + 1}.\n';
          haikus += decodedResponse['candidates'][i]['content'] + '\n\n';
        }
        return haikus;
      } else {
        return 'Request failed with status: ${response.statusCode}.\n\n${response.body}';
      }
    } catch (error) {
      throw Exception('Error sending POST request: $error');
    }
  }
}
