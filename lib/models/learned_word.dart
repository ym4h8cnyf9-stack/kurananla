// Models klasöründeki temel veri modelleri
part of 'models.dart';

/// Öğrenilen kelimelerin durumunu takip etme modeli (SRS - Spaced Repetition System)
class LearnedWord {
  final int id;
  final int wordId; // QuranicWord id'si
  final int correctAnswers; // Doğru cevap sayısı
  final int totalAttempts; // Toplam deneme sayısı
  final double accuracy; // Doğruluk yüzdesi
  final int level; // Kelime seviyesi (1-5)
  final DateTime firstLearned;
  final DateTime lastReviewed;
  final int reviewCount; // Kaç defa gözden geçirildi

  LearnedWord({
    required this.id,
    required this.wordId,
    required this.correctAnswers,
    required this.totalAttempts,
    required this.accuracy,
    required this.level,
    required this.firstLearned,
    required this.lastReviewed,
    required this.reviewCount,
  });

  /// JSON'dan LearnedWord'e dönüştürme
  factory LearnedWord.fromJson(Map<String, dynamic> json) {
    return LearnedWord(
      id: json['id'] ?? 0,
      wordId: json['word_id'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      totalAttempts: json['total_attempts'] ?? 0,
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      level: json['level'] ?? 1,
      firstLearned: DateTime.parse(json['first_learned'] ?? DateTime.now().toString()),
      lastReviewed: DateTime.parse(json['last_reviewed'] ?? DateTime.now().toString()),
      reviewCount: json['review_count'] ?? 0,
    );
  }

  /// LearnedWord'ü JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word_id': wordId,
      'correct_answers': correctAnswers,
      'total_attempts': totalAttempts,
      'accuracy': accuracy,
      'level': level,
      'first_learned': firstLearned.toIso8601String(),
      'last_reviewed': lastReviewed.toIso8601String(),
      'review_count': reviewCount,
    };
  }

  /// Doğruluk hesapla
  double calculateAccuracy() {
    if (totalAttempts == 0) return 0.0;
    return (correctAnswers / totalAttempts) * 100;
  }

  /// Seviye yükselt (SRS - Spaced Repetition System)
  LearnedWord levelUp() {
    if (level < 5) {
      return LearnedWord(
        id: id,
        wordId: wordId,
        correctAnswers: correctAnswers,
        totalAttempts: totalAttempts,
        accuracy: accuracy,
        level: level + 1,
        firstLearned: firstLearned,
        lastReviewed: DateTime.now(),
        reviewCount: reviewCount + 1,
      );
    }
    return this;
  }

  /// Cevap kaydı (doğru/yanlış)
  LearnedWord recordAttempt(bool isCorrect) {
    return LearnedWord(
      id: id,
      wordId: wordId,
      correctAnswers: correctAnswers + (isCorrect ? 1 : 0),
      totalAttempts: totalAttempts + 1,
      accuracy: ((correctAnswers + (isCorrect ? 1 : 0)) / (totalAttempts + 1)) * 100,
      level: level,
      firstLearned: firstLearned,
      lastReviewed: DateTime.now(),
      reviewCount: reviewCount + 1,
    );
  }

  /// SRS'ye göre sonraki gözden geçirme zamanı hesapla
  DateTime getNextReviewDate() {
    switch (level) {
      case 1:
        return lastReviewed.add(const Duration(days: 1));
      case 2:
        return lastReviewed.add(const Duration(days: 3));
      case 3:
        return lastReviewed.add(const Duration(days: 7));
      case 4:
        return lastReviewed.add(const Duration(days: 14));
      case 5:
        return lastReviewed.add(const Duration(days: 30));
      default:
        return lastReviewed.add(const Duration(days: 1));
    }
  }
}
