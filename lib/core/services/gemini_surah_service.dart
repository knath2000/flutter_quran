import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_generative_ai/src/content.dart'; // Import for Content class
import 'dart:async';

class GeminiSurahService {
  final String apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
  ); // Fetch from environment
  late final GenerativeModel _model;

  GeminiSurahService() {
    // Update to use the specified experimental model
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp-01-21',
      apiKey: apiKey,
    );
  }

  Future<String> generateSurahIntroduction(int surahNumber) async {
    // Update prompt to specify word count
    final prompt =
        'Provide a brief introduction (around 150 words) to Surah $surahNumber from the Quran, covering its main themes and significance.';
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'No introduction available.';
  }
}
