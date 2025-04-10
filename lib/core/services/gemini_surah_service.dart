import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_generative_ai/src/content.dart'; // Import for Content class
import 'dart:async';

class GeminiSurahService {
  final String apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
  ); // Fetch from environment
  late final GenerativeModel _model;

  GeminiSurahService() {
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }

  Future<String> generateSurahIntroduction(int surahNumber) async {
    final prompt =
        'Provide a brief introduction to Surah $surahNumber from the Quran.';
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'No introduction available.';
  }
}
