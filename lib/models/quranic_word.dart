// Models klasöründeki temel veri modelleri
part of 'models.dart';

enum Difficulty { easy, medium, hard }
enum QuestionType { vocabulary, multipleChoice, matching, typing, listening, reading }

/// Kur'an'ın en sık geçen kelimeleri modeli
class QuranicWord {
  final int id;
  final String arabic;
  final String turkishMeaning;
  final String root;
  final String pronunciation;
  final int occurrenceCount; // Kur'an'da kaç defa geçtiği
  final int frequency; // Sıklık skoru (1-100)
  final List<String> surahs; // Hangi surelerde geçtiği
  final String example; // Örnek ayet
  final String exampleTranslation;
  final DateTime createdAt;

  QuranicWord({
    required this.id,
    required this.arabic,
    required this.turkishMeaning,
    required this.root,
    required this.pronunciation,
    required this.occurrenceCount,
    required this.frequency,
    required this.surahs,
    required this.example,
    required this.exampleTranslation,
    required this.createdAt,
  });

  /// JSON'dan QuranicWord'e dönüştürme
  factory QuranicWord.fromJson(Map<String, dynamic> json) {
    return QuranicWord(
      id: json['id'] ?? 0,
      arabic: json['arabic'] ?? '',
      turkishMeaning: json['turkish'] ?? '',
      root: json['root'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      occurrenceCount: json['occurrence_count'] ?? 0,
      frequency: json['frequency'] ?? 0,
      surahs: List<String>.from(json['surahs'] ?? []),
      example: json['example'] ?? '',
      exampleTranslation: json['example_translation'] ?? '',
      createdAt: DateTime.now(),
    );
  }

  /// QuranicWord'ü JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic': arabic,
      'turkish': turkishMeaning,
      'root': root,
      'pronunciation': pronunciation,
      'occurrence_count': occurrenceCount,
      'frequency': frequency,
      'surahs': surahs,
      'example': example,
      'example_translation': exampleTranslation,
    };
  }
}