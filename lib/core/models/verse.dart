class Verse {
  final int numberInSurah;
  final String text; // Arabic text
  final String? audioUrl; // URL for verse audio
  final String? translationText; // English translation
  final String? transliterationText; // English transliteration
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;

  Verse({
    required this.numberInSurah,
    required this.text,
    this.audioUrl,
    this.translationText,
    this.transliterationText,
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
  }) {
    // Example mapping (adjust keys based on the actual API response structure, e.g., alquran.cloud)
    return Verse(
      numberInSurah: json['numberInSurah'] as int? ?? 0,
      text: json['text'] as String? ?? '', // Arabic text
      audioUrl:
          audioUrlOverride ??
          json['audio'] as String?, // Use override if provided, else check json
      translationText:
          translationTextOverride ??
          json['translation'] as String?, // Example key
      transliterationText:
          transliterationTextOverride ??
          json['transliteration'] as String?, // Example key
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
