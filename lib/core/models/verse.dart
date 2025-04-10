import 'package:hive/hive.dart';

part 'verse.g.dart'; // Name of the generated file

@HiveType(typeId: 1) // Unique typeId for Verse (0 is used by UserProgress)
class Verse {
  // Removed introduction field
  @HiveField(0)
  final int numberInSurah;
  @HiveField(1)
  final String text;
  @HiveField(2)
  final String? audioUrl;
  @HiveField(3)
  final String? translationText;
  @HiveField(4)
  final String? transliterationText;
  @HiveField(5)
  final int juz;
  @HiveField(6)
  final int manzil;
  @HiveField(7)
  final int page;
  @HiveField(8)
  final int ruku;
  @HiveField(9)
  final int hizbQuarter;

  Verse({
    required this.numberInSurah,
    required this.text,
    this.audioUrl,
    this.translationText,
    this.transliterationText,
    // Removed introduction from constructor
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
  });

  // Factory constructor to create a Verse instance from JSON
  // This assumes the API might return related data (audio, translation) nested or separately.
  // Adjust the parsing logic based on the actual API response structure.
  factory Verse.fromJson(
    Map<String, dynamic> json, {
    String? audioUrlOverride, // Allow passing audio URL if fetched separately
    String?
        translationTextOverride, // Allow passing translation if fetched separately
    String?
        transliterationTextOverride, // Allow passing transliteration if fetched separately
    // Removed introductionOverride parameter
  }) {
    // Example mapping (adjust keys based on the actual API response structure, e.g., alquran.cloud)
    return Verse(
      numberInSurah: json['numberInSurah'] as int? ?? 0,
      text: json['text'] as String? ?? '', // Arabic text
      audioUrl: audioUrlOverride ??
          json['audio'] as String?, // Use override if provided, else check json
      translationText: translationTextOverride ??
          json['translation'] as String?, // Example key
      transliterationText: transliterationTextOverride ??
          json['transliteration'] as String?, // Example key
      // Removed introduction assignment from factory
      juz: json['juz'] as int? ?? 0,
      manzil: json['manzil'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      ruku: json['ruku'] as int? ?? 0,
      hizbQuarter: json['hizbQuarter'] as int? ?? 0,
    );
  }

  // Optional: toJson method if needed for local storage
  // Map<String, dynamic> toJson() => {
  //   'numberInSurah': numberInSurah,
  //   'text': text,
  //   'audioUrl': audioUrl,
  //   'translationText': translationText,
  //   'transliterationText': transliterationText,
  //   'juz': juz,
  //   'manzil': manzil,
  //   'page': page,
  //   'ruku': ruku,
  //   'hizbQuarter': hizbQuarter,
  // };
}
