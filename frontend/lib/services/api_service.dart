import 'dart:convert';

import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? kApiBaseUrl;

  final String baseUrl;

  Future<Map<String, dynamic>> generatePlan(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/plans/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> adjustPlan(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/plans/adjust'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> parseVoiceCommand(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/voice/parse'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
