import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod for Provider

class AiTranslationService {
  static bool _isOpenAiInitialized = false;

  AiTranslationService(); // Constructor remains simple

  // Initialization method for OpenAI SDK
  static void _initializeOpenAI() {
    if (_isOpenAiInitialized) return; // Initialize only once

    // Retrieve the API key passed via --dart-define
    // IMPORTANT: Remember to pass your key during build:
    // flutter run --dart-define=OPENROUTER_API_KEY=YOUR_KEY
    // Or set it as an environment variable in your CI/CD (e.g., Vercel)
    const apiKey = String.fromEnvironment('OPENROUTER_API_KEY');

    if (apiKey.isEmpty) {
      print(
          "ERROR: OPENROUTER_API_KEY environment variable is not set or empty.");
      // Provide a more informative error message for the user/developer
      throw Exception(
          "API Key for OpenRouter AI Translation is missing. Ensure it's set via --dart-define=OPENROUTER_API_KEY=YOUR_KEY during build or in Vercel environment variables.");
    }

    try {
      OpenAI.apiKey = apiKey;
      OpenAI.baseUrl = 'https://openrouter.ai/api/v1';
      // Optionally add other configurations like organization ID if needed
      // OpenAI.organization = "YOUR ORGANIZATION ID";
      _isOpenAiInitialized = true;
      print("OpenAI SDK Initialized for OpenRouter.");
    } catch (e) {
      print("Error initializing OpenAI SDK for OpenRouter: $e");
      throw Exception("Failed to initialize OpenAI SDK: $e");
    }
  }

  Future<String> fetchAiTranslation(int surahNumber, int verseNumber) async {
    _initializeOpenAI(); // Ensure SDK is initialized

    final prompt =
        'Give me, an educated 21 year old male living in the United States, a short but clear and understandable modern English translation, in your own words, for Quran $surahNumber:$verseNumber. Only respond with the translation and no other text';

    print(
        "Sending prompt to OpenRouter (Model: google/gemini-2.5-flash-preview): \"$prompt\"");

    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model:
            "google/gemini-2.5-flash-preview", // Specify the OpenRouter model
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
              ]),
        ],
        // Optional: Add temperature, maxTokens etc. if needed
        // temperature: 0.7,
        // maxTokens: 100,
      );

      print("OpenRouter Response Received.");

      // Extract the response content
      final messageContentList = chatCompletion.choices.first.message.content;

      // Check if the list is not null and not empty
      if (messageContentList != null && messageContentList.isNotEmpty) {
        // Access the text from the first content item, assuming it's text
        // Note: More robust parsing might check item.type if available/needed
        final textResponse = messageContentList.first.text?.trim();

        if (textResponse != null && textResponse.isNotEmpty) {
          print("OpenRouter Translation: $textResponse");
          return textResponse;
        }
      }

      // If we reach here, the response list was null/empty or the text content was null/empty
      print(
          "Error: Received null, empty, or invalid content list from OpenRouter AI.");
      throw Exception(
          "Received null, empty, or invalid content list from OpenRouter AI.");
    } on RequestFailedException catch (e) {
      // Catch specific OpenAI exceptions
      print(
          "Error fetching AI translation for $surahNumber:$verseNumber from OpenRouter: ${e.message} (Status Code: ${e.statusCode})");
      throw Exception(
          "Failed to get AI translation from OpenRouter: ${e.message}");
    } catch (e) {
      // Catch general errors
      print("Error fetching AI translation for $surahNumber:$verseNumber: $e");
      throw Exception("Failed to get AI translation: ${e.toString()}");
    }
  }
}

// Provider for the service - remains unchanged
final aiTranslationServiceProvider = Provider<AiTranslationService>((ref) {
  return AiTranslationService();
});
