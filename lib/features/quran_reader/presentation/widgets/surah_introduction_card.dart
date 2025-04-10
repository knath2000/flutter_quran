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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      elevation: 2,
      color: colorScheme.surfaceVariant.withOpacity(
        0.5,
      ), // Semi-transparent dark card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            Text(
              displayedText, // Display truncated or full text
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.85),
              ),
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
