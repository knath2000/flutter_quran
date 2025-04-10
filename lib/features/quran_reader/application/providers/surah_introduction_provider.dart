import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/core/services/surah_introduction_service.dart';

/// FutureProvider family to get the introduction text for a specific Surah.
///
/// Takes the surah number (int) as an argument.
/// Returns `String?` - the introduction text or null if not found/error.
final surahIntroductionProvider = FutureProvider.family<String?, int>((
  ref,
  surahNumber,
) async {
  // Watch the service provider
  final service = ref.watch(surahIntroductionServiceProvider);
  // Call the service method to get the data
  try {
    final introduction = await service.getIntroduction(surahNumber);
    if (introduction == null) {
      print('No introduction found for Surah $surahNumber');
    }
    return introduction;
  } catch (e) {
    print('Error fetching introduction for Surah $surahNumber in provider: $e');
    // Return null on error, UI can handle this
    return null;
  }
});
