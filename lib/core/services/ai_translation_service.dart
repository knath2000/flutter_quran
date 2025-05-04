import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod for Provider

class AiTranslationService {
  GenerativeModel? _model;
  // No need for _isInitialized or _initializationError flags with lazy init

  AiTranslationService(); // Constructor does nothing now

  // Lazy initialization method
  GenerativeModel _getModel() {
    // If model already exists, return it
    if (_model != null) return _model!;

    // Otherwise, try to initialize it now using String.fromEnvironment
    // Retrieve the API key passed via --dart-define
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');

    if (apiKey.isEmpty) {
      print("ERROR: GEMINI_API_KEY environment variable is not set or empty.");
      // Provide a more informative error message for the user/developer
      throw Exception(
          "API Key for AI Translation is missing. Ensure it's set via --dart-define during build or in Vercel environment variables.");
    }

    try {
      // TODO: Add safety settings if needed
      // final safetySettings = [
      //   SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
      //   SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      // ];
      _model = GenerativeModel(
        model: 'gemini-1.5-flash', // Use stable flash model for testing
        apiKey: apiKey,
        // safetySettings: safetySettings, // Uncomment if using safety settings
      );
      print("AI Translation Service Initialized Lazily.");
      return _model!;
    } catch (e) {
      print("Error initializing GenerativeModel lazily: $e");
      throw Exception("Failed to initialize AI Model: $e");
    }
  }

  Future<String> fetchAiTranslation(int surahNumber, int verseNumber) async {
    // Get the model (initializes on first call)
    final model = _getModel();

    final prompt =
        'Give me, an educated 21 year old male living in the United States, a short but clear and understandable modern English translation, in your own words, for Quran $surahNumber:$verseNumber. Only respond with the translation and no other text';

    print("Sending prompt to Gemini: \"$prompt\"");

    try {
      final content = [Content.text(prompt)];
      // Configure generation settings if needed (e.g., temperature)
      // final generationConfig = GenerationConfig(
      //   temperature: 0.7,
      // );
      final response = await model.generateContent(
        // Use the local 'model' variable
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
  // Constructor is now empty, initialization is lazy
  return AiTranslationService();
});
