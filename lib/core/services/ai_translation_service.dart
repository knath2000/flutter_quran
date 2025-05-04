import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod for Provider

class AiTranslationService {
  GenerativeModel? _model;
  bool _isInitialized = false;
  String? _initializationError;

  AiTranslationService() {
    _initialize();
  }

  void _initialize() {
    if (_isInitialized) return;

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        // TODO: Add safety settings if needed
        // final safetySettings = [
        //   SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        //   SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        // ];
        _model = GenerativeModel(
          model: 'gemini-2.5-flash-preview-04-17', // Updated model name
          apiKey: apiKey,
          // safetySettings: safetySettings, // Uncomment if using safety settings
        );
        _isInitialized = true;
        print("AI Translation Service Initialized Successfully.");
      } catch (e) {
        _initializationError = "Error initializing GenerativeModel: $e";
        print("ERROR: $_initializationError");
      }
    } else {
      _initializationError = "GEMINI_API_KEY not found or empty in .env file.";
      print("ERROR: $_initializationError");
    }
  }

  Future<String> fetchAiTranslation(int surahNumber, int verseNumber) async {
    if (!_isInitialized || _model == null) {
      throw Exception(
          "AI Model not initialized. Check API Key and logs. Error: $_initializationError");
    }

    final prompt =
        'Give me, an educated 21 year old male living in the United States, a short but clear and understandable modern English translation, in your own words, for Quran $surahNumber:$verseNumber. Only respond with the translation and no other text';

    print("Sending prompt to Gemini: \"$prompt\"");

    try {
      final content = [Content.text(prompt)];
      // Configure generation settings if needed (e.g., temperature)
      // final generationConfig = GenerationConfig(
      //   temperature: 0.7,
      // );
      final response = await _model!.generateContent(
        content,
        // generationConfig: generationConfig, // Uncomment if using config
      );

      print("Gemini Response Received.");
      // Basic check if response text is not null or empty
      if (response.text != null && response.text!.trim().isNotEmpty) {
        print("Gemini Translation: ${response.text!.trim()}");
        return response.text!.trim();
      } else {
        print("Error: Received empty response from AI.");
        throw Exception("Received empty response from AI.");
      }
    } catch (e) {
      print("Error fetching AI translation for $surahNumber:$verseNumber: $e");
      // Consider more specific error handling based on API error types if needed
      throw Exception("Failed to get AI translation: ${e.toString()}");
    }
  }
}

// Provider for the service
final aiTranslationServiceProvider = Provider<AiTranslationService>((ref) {
  // The service initializes itself in the constructor
  return AiTranslationService();
});
