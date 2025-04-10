class SurahInfo {
  final int number;
  final String name; // Arabic name
  final String englishName;
  final String englishNameTranslation;
  final String revelationType; // 'Meccan' or 'Medinan'
  final int numberOfAyahs;
  SurahInfo({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
  });

  // Factory constructor to create a SurahInfo instance from JSON
  factory SurahInfo.fromJson(Map<String, dynamic> json) {
    // Adjust keys based on the actual API response structure (e.g., alquran.cloud)
    return SurahInfo(
      number: json['number'] as int? ?? 0, // Provide default or handle null
      name: json['name'] as String? ?? '',
      englishName: json['englishName'] as String? ?? '',
      englishNameTranslation: json['englishNameTranslation'] as String? ?? '',
      revelationType: json['revelationType'] as String? ?? '',
      numberOfAyahs: json['numberOfAyahs'] as int? ?? 0,
    );
  }

  // Optional: toJson method if needed for local storage
  // Map<String, dynamic> toJson() => {
  //   'number': number,
  //   'name': name,
  //   'englishName': englishName,
  //   'englishNameTranslation': englishNameTranslation,
  //   'revelationType': revelationType,
  //   'numberOfAyahs': numberOfAyahs,
  // };
}
