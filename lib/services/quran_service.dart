import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'database_service.dart';

class QuranService {
  static final QuranService _instance = QuranService._internal();
  final DatabaseService _databaseService = DatabaseService();

  factory QuranService() {
    return _instance;
  }

  QuranService._internal();

  /// Kur'an verilerini JSON dosyasından yükle ve veritabanına kaydet
  Future<void> loadQuranWordsFromAssets() async {
    try {
      // JSON dosyasını yükle
      final String jsonString = await rootBundle.loadString('assets/data/quran_words.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      // Her kelimeyi veritabanına ekle
      for (var wordData in jsonData) {
        final word = QuranicWord.fromJson(wordData);
        await _databaseService.insertWord(word);
      }

      print('✅ \${jsonData.length} Kur\'an kelimesi başarıyla yüklendi!');
    } catch (e) {
      print('❌ Kur\'an verileri yükleme hatası: \$e');
    }
  }

  /// En sık geçen X adet kelimeyi getir
  Future<List<QuranicWord>> getTopFrequentWords(int limit) async {
    return await _databaseService.getTopWords(limit);
  }

  /// Bir kelimeyi getir
  Future<QuranicWord?> getWord(int wordId) async {
    return await _databaseService.getWord(wordId);
  }

  /// Tüm kelimeleri getir
  Future<List<QuranicWord>> getAllWords() async {
    return await _databaseService.getAllWords();
  }

  /// Bir kelimenin öğrenme durumunu getir
  Future<LearnedWord?> getLearnedWordStatus(int wordId) async {
    return await _databaseService.getLearnedWord(wordId);
  }

  /// Kelime öğrenme kaydını oluştur
  Future<void> recordWordLearning(int wordId) async {
    final existingRecord = await _databaseService.getLearnedWord(wordId);

    if (existingRecord == null) {
      // İlk kez öğreniliyor
      final newRecord = LearnedWord(
        id: 0,
        wordId: wordId,
        correctAnswers: 0,
        totalAttempts: 0,
        accuracy: 0.0,
        level: 1,
        firstLearned: DateTime.now(),
        lastReviewed: DateTime.now(),
        reviewCount: 0,
      );
      await _databaseService.insertLearnedWord(newRecord);
    }
  }

  /// Kelime cevabını kaydet (doğru/yanlış)
  Future<void> recordWordAnswer(int wordId, bool isCorrect) async {
    var learnedWord = await _databaseService.getLearnedWord(wordId);

    if (learnedWord == null) {
      // Henüz öğrenilmemişse oluştur
      learnedWord = LearnedWord(
        id: 0,
        wordId: wordId,
        correctAnswers: isCorrect ? 1 : 0,
        totalAttempts: 1,
        accuracy: isCorrect ? 100.0 : 0.0,
        level: 1,
        firstLearned: DateTime.now(),
        lastReviewed: DateTime.now(),
        reviewCount: 1,
      );
      await _databaseService.insertLearnedWord(learnedWord);
    } else {
      // Mevcut kaydı güncelle
      final updatedWord = learnedWord.recordAttempt(isCorrect);
      await _databaseService.updateLearnedWord(updatedWord);

      // Doğruluk %80'den yüksekse seviyeyi yükselt
      if (updatedWord.calculateAccuracy() >= 80 && updatedWord.level < 5) {
        final leveledUp = updatedWord.levelUp();
        await _databaseService.updateLearnedWord(leveledUp);
      }
    }
  }

  /// Gözden geçirilmesi gereken kelimeleri getir (SRS)
  Future<List<LearnedWord>> getReviewDueWords() async {
    return await _databaseService.getReviewDueWords();
  }

  /// Tüm öğrenilen kelimeleri getir
  Future<List<LearnedWord>> getAllLearnedWords() async {
    return await _databaseService.getAllLearnedWords();
  }

  /// Öğrenme istatistiklerini hesapla
  Future<Map<String, dynamic>> getLearningStatistics() async {
    final learnedWords = await _databaseService.getAllLearnedWords();

    int totalWords = learnedWords.length;
    int masteredWords = learnedWords.where((w) => w.level == 5).length;
    double avgAccuracy = learnedWords.isEmpty
        ? 0.0
        : learnedWords.map((w) => w.accuracy).reduce((a, b) => a + b) / learnedWords.length;

    return {
      'total_learned': totalWords,
      'mastered': masteredWords,
      'average_accuracy': avgAccuracy.toStringAsFixed(2),
      'due_for_review': (await getReviewDueWords()).length,
    };
  }
}
