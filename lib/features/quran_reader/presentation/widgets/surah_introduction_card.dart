import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:quran_flutter/core/models/surah_info.dart';

class SurahIntroductionCard extends HookWidget {
  final SurahInfo surahInfo;
  final String placeholderIntroduction =
      "This is a placeholder introduction for the Surah. It provides a brief overview of the themes and context. More details can be revealed by clicking the button below. This text will be replaced with actual data from an API or local source in a future implementation. We are currently focusing on the UI structure.";

  const SurahIntroductionCard({Key? key, required this.surahInfo})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false); // State to track expansion
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Use placeholder text for now
    final introductionText = surahInfo.introduction ?? placeholderIntroduction;
    final bool canExpand =
        introductionText.length >
        150; // Arbitrary length to decide if expansion is needed
    final String displayedText =
        (isExpanded.value || !canExpand)
            ? introductionText
            : '${introductionText.substring(0, 150)}...'; // Truncate if not expanded

    // Use a Container with BoxDecoration for background image
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        // color: colorScheme.surfaceVariant.withOpacity(0.7), // Remove color completely for debugging
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/images/dark_honeycomb_pattern.png'),
          repeat: ImageRepeat.repeat, // Tile the image
          opacity: 1.0, // Max opacity for debugging
        ),
        boxShadow: const [
          // Replicate Card elevation with BoxShadow
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias, // Clip the background image to rounded corners
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Surah: ${surahInfo.englishName}', // Title
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
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
                      'Continue reading to learn about the historical background and significance of ${surahInfo.englishName}...',
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
                            color: colorScheme.surfaceVariant.withOpacity(0.7),
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
    );
  }
}
