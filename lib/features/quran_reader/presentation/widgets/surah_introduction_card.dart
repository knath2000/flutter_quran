import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

class SurahIntroductionCard extends HookWidget {
  final AsyncValue<String?> introductionAsync; // Accept AsyncValue
  final String surahName; // Accept Surah name directly
  final String placeholderIntroduction =
      "This is a placeholder introduction for the Surah. It provides a brief overview of the themes and context. More details can be revealed by clicking the button below. This text will be replaced with actual data from an API or local source in a future implementation. We are currently focusing on the UI structure.";

  const SurahIntroductionCard({
    Key? key,
    required this.introductionAsync,
    required this.surahName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false); // State to track expansion
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Handle AsyncValue for introduction
    return introductionAsync.when(
      data: (introductionText) {
        // Use placeholder if data is null or empty
        final effectiveIntroduction =
            (introductionText == null || introductionText.isEmpty)
                ? placeholderIntroduction
                : introductionText;
        final bool canExpand = effectiveIntroduction.length > 150;
        final String displayedText =
            (isExpanded.value || !canExpand)
                ? effectiveIntroduction
                : '${effectiveIntroduction.substring(0, 150)}...';

        // Revert back to Card, remove background image properties
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          elevation: 2,
          color: colorScheme.surfaceVariant.withOpacity(
            0.5,
          ), // Restore original semi-transparent color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias, // Keep clipping
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center column content
              children: [
                Text(
                  'Featured Surah: $surahName', // Use passed surahName
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center, // Center title
                ),
                const SizedBox(height: 8),
                // Stack to allow overlaying fade and prompt
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // The main text content
                    Text(
                      displayedText,
                      // Limit max lines when not expanded to help with fade calculation
                      maxLines: !isExpanded.value && canExpand ? 4 : null,
                      overflow: TextOverflow.clip, // Clip instead of ellipsis
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.85),
                      ),
                      textAlign: TextAlign.center, // Center intro text
                    ),
                    // Conditional Fade and "Continue Reading" overlay
                    if (!isExpanded.value && canExpand) ...[
                      // Gradient Fade using ShaderMask
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.6, 1.0], // Start fade later
                              colors: [
                                colorScheme.surfaceVariant.withOpacity(
                                  0.0,
                                ), // Transparent at top
                                colorScheme.surfaceVariant.withOpacity(
                                  0.9,
                                ), // Semi-transparent middle
                                colorScheme.surfaceVariant.withOpacity(
                                  1.0,
                                ), // Opaque at bottom matching card
                              ],
                            ),
                          ),
                        ),
                      ),
                      // "Continue Reading" Text Overlay
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 4.0,
                        ), // Position slightly above bottom
                        child: Text(
                          'Continue reading to learn about the historical background and significance of $surahName...',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary.withOpacity(
                              0.9,
                            ), // Use primary color, slightly transparent
                            fontWeight: FontWeight.bold,
                            shadows: [
                              // Add subtle shadow for readability
                              Shadow(
                                blurRadius: 4.0,
                                color: colorScheme.surfaceVariant.withOpacity(
                                  0.7,
                                ),
                                offset: const Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (canExpand) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        isExpanded.value = !isExpanded.value; // Toggle state
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        isExpanded.value ? 'Show Less' : 'View Full Content',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ); // End Card
      }, // End data builder
      loading:
          () => const Padding(
            // Show loading indicator within card-like structure
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stackTrace) => Card(
            // Show error message within card
            margin: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            color: colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading introduction for $surahName.',
                style: TextStyle(color: colorScheme.onErrorContainer),
                textAlign: TextAlign.center,
              ),
            ),
          ),
    ); // End introductionAsync.when
  }
}
