// Models klasöründeki temel veri modelleri
part of 'models.dart';

/// Soru modeli
class Question {
  final int id;
  final QuestionType type; // Soru tipi
  final String question; // Soru metni
  final String? arabicQuestion; // Arapça soru (opsiyonel)
  final List<String> options; // Seçenekler
  final String correctAnswer; // Doğru cevap
  final int xpReward; // Doğru cevap için XP
  final String? explanation; // Açıklama
  final QuranicWord? relatedWord; // İlgili kelime

  Question({
    required this.id,
    required this.type,
    required this.question,
    this.arabicQuestion,
    required this.options,
    required this.correctAnswer,
    required this.xpReward,
    this.explanation,
    this.relatedWord,
  });

  /// JSON'dan Question'a dönüştürme
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      type: QuestionType.values[json['type'] ?? 0],
      question: json['question'] ?? '',
      arabicQuestion: json['arabic_question'],
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'] ?? '',
      xpReward: json['xp_reward'] ?? 10,
      explanation: json['explanation'],
      relatedWord: json['related_word'] != null 
          ? QuranicWord.fromJson(json['related_word']) 
          : null,
    );
  }

  /// Question'ı JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'question': question,
      'arabic_question': arabicQuestion,
      'options': options,
      'correct_answer': correctAnswer,
      'xp_reward': xpReward,
      'explanation': explanation,
      'related_word': relatedWord?.toJson(),
    };
  }

  /// Cevabı kontrol et
  bool checkAnswer(String userAnswer) {
    return userAnswer.toLowerCase().trim() == correctAnswer.toLowerCase().trim();
  }
}