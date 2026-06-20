import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'database_service.dart';

class UserProgressService {
  static final UserProgressService _instance = UserProgressService._internal();
  final DatabaseService _databaseService = DatabaseService();

  factory UserProgressService() {
    return _instance;
  }

  UserProgressService._internal();

  /// Kullanıcı ilerleme kaydını başlat
  Future<UserProgress> initializeUserProgress() async {
    var existingProgress = await _databaseService.getUserProgress();

    if (existingProgress == null) {
      final newProgress = UserProgress(
        id: 1,
        totalXp: 0,
        level: 1,
        streakDays: 0,
        wordsLearned: 0,
        lessonsCompleted: 0,
        lastActivityDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _databaseService.insertUserProgress(newProgress);
      return newProgress;
    }

    return existingProgress;
  }

  /// Kullanıcı ilerleme al
  Future<UserProgress> getUserProgress() async {
    var progress = await _databaseService.getUserProgress();
    return progress ?? await initializeUserProgress();
  }

  /// XP ekle (doğru cevap, ders tamamlama, vb.)
  Future<UserProgress> addXp(int xpAmount) async {
    var progress = await getUserProgress();
    final updatedProgress = progress.addXp(xpAmount);
    await _databaseService.updateUserProgress(updatedProgress);
    return updatedProgress;
  }

  /// Kelime sayısını artır
  Future<UserProgress> addLearnedWord() async {
    var progress = await getUserProgress();
    final updatedProgress = UserProgress(
      id: progress.id,
      totalXp: progress.totalXp,
      level: progress.level,
      streakDays: progress.streakDays,
      wordsLearned: progress.wordsLearned + 1,
      lessonsCompleted: progress.lessonsCompleted,
      lastActivityDate: DateTime.now(),
      createdAt: progress.createdAt,
      updatedAt: DateTime.now(),
    );
    await _databaseService.updateUserProgress(updatedProgress);
    return updatedProgress;
  }

  /// Ders tamamlama
  Future<UserProgress> completeLesson(int xpReward) async {
    var progress = await getUserProgress();
    final updatedProgress = UserProgress(
      id: progress.id,
      totalXp: progress.totalXp + xpReward,
      level: ((progress.totalXp + xpReward) ~/ 500) + 1,
      streakDays: progress.streakDays,
      wordsLearned: progress.wordsLearned,
      lessonsCompleted: progress.lessonsCompleted + 1,
      lastActivityDate: DateTime.now(),
      createdAt: progress.createdAt,
      updatedAt: DateTime.now(),
    );
    await _databaseService.updateUserProgress(updatedProgress);
    return updatedProgress;
  }

  /// Gün zincirini güncelle
  Future<UserProgress> updateStreak() async {
    var progress = await getUserProgress();
    final updatedProgress = progress.updateStreak();
    await _databaseService.updateUserProgress(updatedProgress);
    return updatedProgress;
  }

  /// Kullanıcı istatistiklerini al
  Future<Map<String, dynamic>> getUserStats() async {
    final progress = await getUserProgress();
    
    return {
      'level': progress.level,
      'totalXp': progress.totalXp,
      'streakDays': progress.streakDays,
      'wordsLearned': progress.wordsLearned,
      'lessonsCompleted': progress.lessonsCompleted,
      'nextLevelXp': ((progress.level) * 500),
      'currentLevelProgress': (progress.totalXp % 500),
    };
  }

  /// G��nlük hedef kontrol et (1 ders = 1 gün)
  Future<bool> hasCompletedTodayGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastActivityString = prefs.getString('last_activity_date');

    if (lastActivityString == null) {
      return false;
    }

    final lastActivity = DateTime.parse(lastActivityString);
    return lastActivity.year == today.year &&
        lastActivity.month == today.month &&
        lastActivity.day == today.day;
  }

  /// Günlük hedefi tamamla
  Future<void> completeDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_activity_date', DateTime.now().toIso8601String());
    await updateStreak();
  }
}
