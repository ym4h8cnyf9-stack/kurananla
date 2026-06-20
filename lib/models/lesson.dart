// Models klasöründeki temel veri modelleri
part of 'models.dart';

/// Bir ders (lesson) modeli - Duolingo tarzı
class Lesson {
  final int id;
  final String title;
  final String description;
  final int levelRequired; // Gerekli level
  final List<Question> questions; // Soruları
  final int xpReward; // Tamamlama XP'si
  final Difficulty difficulty;
  final int estimatedTime; // Dakika cinsinden
  final bool isCompleted; // Tamamlanmış mı?
  final DateTime createdAt;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.levelRequired,
    required this.questions,
    required this.xpReward,
    required this.difficulty,
    required this.estimatedTime,
    required this.isCompleted,
    required this.createdAt,
  });

  /// JSON'dan Lesson'a dönüştürme
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      levelRequired: json['level_required'] ?? 1,
      questions: (json['questions'] as List?)
          ?.map((q) => Question.fromJson(q))
          .toList() ?? [],
      xpReward: json['xp_reward'] ?? 50,
      difficulty: Difficulty.values[json['difficulty'] ?? 0],
      estimatedTime: json['estimated_time'] ?? 5,
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.now(),
    );
  }

  /// Lesson'ı JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level_required': levelRequired,
      'questions': questions.map((q) => q.toJson()).toList(),
      'xp_reward': xpReward,
      'difficulty': difficulty.index,
      'estimated_time': estimatedTime,
      'is_completed': isCompleted,
    };
  }
}