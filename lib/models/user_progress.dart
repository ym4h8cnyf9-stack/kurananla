// Models klasöründeki temel veri modelleri
part of 'models.dart';

/// Kullanıcı ilerleme modeli
class UserProgress {
  final int id;
  final int totalXp; // Toplam deneyim puanı
  final int level; // Seviye
  final int streakDays; // Gün zinciri
  final int wordsLearned; // Öğrenilen kelime sayısı
  final int lessonsCompleted; // Tamamlanan ders sayısı
  final DateTime lastActivityDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProgress({
    required this.id,
    required this.totalXp,
    required this.level,
    required this.streakDays,
    required this.wordsLearned,
    required this.lessonsCompleted,
    required this.lastActivityDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan UserProgress'e dönüştürme
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] ?? 1,
      totalXp: json['total_xp'] ?? 0,
      level: json['level'] ?? 1,
      streakDays: json['streak_days'] ?? 0,
      wordsLearned: json['words_learned'] ?? 0,
      lessonsCompleted: json['lessons_completed'] ?? 0,
      lastActivityDate: DateTime.parse(json['last_activity_date'] ?? DateTime.now().toString()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
    );
  }

  /// UserProgress'i JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_xp': totalXp,
      'level': level,
      'streak_days': streakDays,
      'words_learned': wordsLearned,
      'lessons_completed': lessonsCompleted,
      'last_activity_date': lastActivityDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Yeni seviye hesapla
  int calculateLevel() {
    return (totalXp ~/ 500) + 1; // Her 500 XP'de bir seviye artsın
  }

  /// Gün zincirini güncelle
  UserProgress updateStreak() {
    final lastActivity = lastActivityDate;
    final today = DateTime.now();
    final difference = today.difference(lastActivity).inDays;

    int newStreak = streakDays;
    if (difference == 0) {
      // Aynı gün, zincir devam ediyor
      newStreak = streakDays;
    } else if (difference == 1) {
      // Bir gün sonra, zincir devam ediyor
      newStreak = streakDays + 1;
    } else {
      // Uzun süre sonra, zincir sıfırlanıyor
      newStreak = 0;
    }

    return UserProgress(
      id: id,
      totalXp: totalXp,
      level: calculateLevel(),
      streakDays: newStreak,
      wordsLearned: wordsLearned,
      lessonsCompleted: lessonsCompleted,
      lastActivityDate: today,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// XP ekle
  UserProgress addXp(int xpAmount) {
    return UserProgress(
      id: id,
      totalXp: totalXp + xpAmount,
      level: ((totalXp + xpAmount) ~/ 500) + 1,
      streakDays: streakDays,
      wordsLearned: wordsLearned,
      lessonsCompleted: lessonsCompleted,
      lastActivityDate: DateTime.now(),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}