import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

// --- Configuration ---
const String inputCsvPath =
    '../../quran-expo/assets/wbw.csv'; // Relative path from user feedback
const String outputJsonPath =
    'assets/data/quran_arabic_text.json'; // Relative to project root
const int suraCol = 1; // Column index for Surah number (0-based)
const int verseCol = 2; // Column index for Verse number
const int wordCol = 5; // Column index for the Arabic Word segment
const int wordNumCol = 3; // Column index for Word number within the verse
// Add punctuation column index if needed
// const int punctuationCol = 10;
// ---

Future<void> main() async {
  print('Starting Quran CSV pre-processing...');
  print('Input CSV: $inputCsvPath');
  print('Output JSON: $outputJsonPath');

  final inputFile = File(inputCsvPath);
  if (!await inputFile.exists()) {
    print('Error: Input CSV file not found at $inputCsvPath');
    exit(1);
  }

  try {
    // Read CSV content
    final csvString = await inputFile.readAsString();

    // Parse CSV - skip header row
    final List<List<dynamic>> rows = const CsvToListConverter()
        .convert(csvString, shouldParseNumbers: false)
        .sublist(1);

    // Process rows into nested map structure
    // { "surahNum": { "verseNum": "fullVerseText", ... }, ... }
    final Map<String, Map<String, String>> quranTextMap = {};
    final Map<String, Map<String, Map<int, String>>> tempVerseMap =
        {}; // Temp map to order words

    print('Processing ${rows.length} rows...');

    for (final row in rows) {
      if (row.length > wordCol &&
          row.length > verseCol &&
          row.length > suraCol &&
          row.length > wordNumCol) {
        final surahNumStr = row[suraCol].toString();
        final verseNumStr = row[verseCol].toString();
        final wordNum = int.tryParse(row[wordNumCol].toString());
        final wordSegment = row[wordCol].toString();
        // final punctuation = row.length > punctuationCol ? row[punctuationCol]?.toString() : null; // Optional

        if (wordNum != null && wordSegment.isNotEmpty) {
          // Initialize inner maps if they don't exist
          tempVerseMap.putIfAbsent(surahNumStr, () => {});
          tempVerseMap[surahNumStr]!.putIfAbsent(verseNumStr, () => {});

          // Store word segment by its number
          tempVerseMap[surahNumStr]![verseNumStr]![wordNum] = wordSegment;
          // Handle punctuation if needed:
          // if (punctuation != null && punctuation.isNotEmpty && punctuation != '.') {
          //    tempVerseMap[surahNumStr]![verseNumStr]![wordNum] = wordSegment + punctuation;
          // } else {
          //    tempVerseMap[surahNumStr]![verseNumStr]![wordNum] = wordSegment;
          // }
        }
      } else {
        print('Warning: Skipping row with insufficient columns: $row');
      }
    }

    print('Reconstructing verses...');
    // Reconstruct full verses from ordered word segments
    tempVerseMap.forEach((surahNumStr, verses) {
      quranTextMap[surahNumStr] = {};
      verses.forEach((verseNumStr, words) {
        // Sort words by word number and join
        final sortedWordKeys = words.keys.toList()..sort();
        final fullVerseText = sortedWordKeys
            .map((key) => words[key]!)
            .join(' ');
        quranTextMap[surahNumStr]![verseNumStr] = fullVerseText;
      });
    });

    // Ensure output directory exists
    final outputDir = Directory(File(outputJsonPath).parent.path);
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
      print('Created output directory: ${outputDir.path}');
    }

    // Write JSON output
    final outputFile = File(outputJsonPath);
    final jsonEncoder = JsonEncoder.withIndent('  '); // Pretty print
    await outputFile.writeAsString(jsonEncoder.convert(quranTextMap));

    print('Successfully processed CSV and wrote JSON to $outputJsonPath');
  } catch (e, s) {
    print('Error during CSV processing: $e');
    print('Stack trace: $s');
    exit(1);
  }
}
