class AyahModel {
  final int number; // Global verse index (e.g. 1 to 6236)
  final int numberInSurah; // Verse index within the Surah (e.g. 1 to 286)
  final String text; // Arabic script
  final String urduTranslation; // Translated Urdu script
  final int juz;
  final int surahNumber;
  final String surahName;

  AyahModel({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.urduTranslation,
    required this.juz,
    required this.surahNumber,
    required this.surahName,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json, String translationText, {int? surahNumber, String? surahName}) {
    int sNum = surahNumber ?? 1;
    String sName = surahName ?? 'Al-Faatiha';

    if (json['surah'] != null) {
      final surahJson = json['surah'];
      if (surahJson is Map<String, dynamic>) {
        sNum = surahJson['number'] as int? ?? sNum;
        sName = surahJson['englishName'] as String? ?? sName;
      }
    }

    return AyahModel(
      number: json['number'] as int,
      numberInSurah: json['numberInSurah'] as int,
      text: json['text'] as String,
      urduTranslation: translationText,
      juz: json['juz'] as int,
      surahNumber: sNum,
      surahName: sName,
    );
  }

  factory AyahModel.fromStorageJson(Map<String, dynamic> json) {
    return AyahModel(
      number: json['number'] as int,
      numberInSurah: json['numberInSurah'] as int,
      text: json['text'] as String,
      urduTranslation: json['urduTranslation'] as String,
      juz: json['juz'] as int,
      surahNumber: json['surahNumber'] as int,
      surahName: json['surahName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'numberInSurah': numberInSurah,
      'text': text,
      'urduTranslation': urduTranslation,
      'juz': juz,
      'surahNumber': surahNumber,
      'surahName': surahName,
    };
  }
}
