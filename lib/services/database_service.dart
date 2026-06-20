import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'kurananla.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Kur'an kelimeleri tablosu
    await db.execute('''
      CREATE TABLE quranic_words (
        id INTEGER PRIMARY KEY,
        arabic TEXT NOT NULL,
        turkish TEXT NOT NULL,
        root TEXT,
        pronunciation TEXT,
        occurrence_count INTEGER,
        frequency INTEGER,
        surahs TEXT,
        example TEXT,
        example_translation TEXT,
        created_at TEXT
      )
    ''');

    // Kullanıcı ilerleme tablosu
    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY,
        total_xp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        streak_days INTEGER DEFAULT 0,
        words_learned INTEGER DEFAULT 0,
        lessons_completed INTEGER DEFAULT 0,
        last_activity_date TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Öğrenilen kelimeler tablosu (SRS)
    await db.execute('''
      CREATE TABLE learned_words (
        id INTEGER PRIMARY KEY,
        word_id INTEGER NOT NULL,
        correct_answers INTEGER DEFAULT 0,
        total_attempts INTEGER DEFAULT 0,
        accuracy REAL DEFAULT 0.0,
        level INTEGER DEFAULT 1,
        first_learned TEXT,
        last_reviewed TEXT,
        review_count INTEGER DEFAULT 0,
        FOREIGN KEY (word_id) REFERENCES quranic_words(id)
      )
    ''');

    // Dersler tablosu
    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        level_required INTEGER DEFAULT 1,
        xp_reward INTEGER DEFAULT 50,
        difficulty INTEGER DEFAULT 0,
        estimated_time INTEGER DEFAULT 5,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // Sorular tablosu
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER NOT NULL,
        type INTEGER DEFAULT 0,
        question TEXT NOT NULL,
        arabic_question TEXT,
        options TEXT,
        correct_answer TEXT,
        xp_reward INTEGER DEFAULT 10,
        explanation TEXT,
        related_word_id INTEGER,
        FOREIGN KEY (lesson_id) REFERENCES lessons(id),
        FOREIGN KEY (related_word_id) REFERENCES quranic_words(id)
      )
    ''');

    // Kullanıcı ders ilerleme tablosu
    await db.execute('''
      CREATE TABLE lesson_progress (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER NOT NULL,
        completed_questions INTEGER DEFAULT 0,
        total_questions INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        completed_at TEXT,
        FOREIGN KEY (lesson_id) REFERENCES lessons(id)
      )
    ''');
  }

  // ==================== QURANIC WORDS OPERATIONS ====================

  Future<int> insertWord(QuranicWord word) async {
    final db = await database;
    return await db.insert('quranic_words', {
      'id': word.id,
      'arabic': word.arabic,
      'turkish': word.turkishMeaning,
      'root': word.root,
      'pronunciation': word.pronunciation,
      'occurrence_count': word.occurrenceCount,
      'frequency': word.frequency,
      'surahs': word.surahs.join(','),
      'example': word.example,
      'example_translation': word.exampleTranslation,
      'created_at': word.createdAt.toIso8601String(),
    });
  }

  Future<QuranicWord?> getWord(int id) async {
    final db = await database;
    final maps = await db.query(
      'quranic_words',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _mapToQuranicWord(maps.first);
    }
    return null;
  }

  Future<List<QuranicWord>> getAllWords() async {
    final db = await database;
    final maps = await db.query('quranic_words', orderBy: 'frequency DESC');
    return List.generate(maps.length, (i) => _mapToQuranicWord(maps[i]));
  }

  Future<List<QuranicWord>> getTopWords(int limit) async {
    final db = await database;
    final maps = await db.query(
      'quranic_words',
      orderBy: 'frequency DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => _mapToQuranicWord(maps[i]));
  }

  QuranicWord _mapToQuranicWord(Map<String, dynamic> map) {
    return QuranicWord(
      id: map['id'],
      arabic: map['arabic'],
      turkishMeaning: map['turkish'],
      root: map['root'] ?? '',
      pronunciation: map['pronunciation'] ?? '',
      occurrenceCount: map['occurrence_count'] ?? 0,
      frequency: map['frequency'] ?? 0,
      surahs: (map['surahs'] as String?)?.split(',') ?? [],
      example: map['example'] ?? '',
      exampleTranslation: map['example_translation'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toString()),
    );
  }

  // ==================== USER PROGRESS OPERATIONS ====================

  Future<int> insertUserProgress(UserProgress progress) async {
    final db = await database;
    return await db.insert('user_progress', {
      'id': progress.id,
      'total_xp': progress.totalXp,
      'level': progress.level,
      'streak_days': progress.streakDays,
      'words_learned': progress.wordsLearned,
      'lessons_completed': progress.lessonsCompleted,
      'last_activity_date': progress.lastActivityDate.toIso8601String(),
      'created_at': progress.createdAt.toIso8601String(),
      'updated_at': progress.updatedAt.toIso8601String(),
    });
  }

  Future<UserProgress?> getUserProgress() async {
    final db = await database;
    final maps = await db.query('user_progress', limit: 1);
    if (maps.isNotEmpty) {
      return _mapToUserProgress(maps.first);
    }
    return null;
  }

  Future<int> updateUserProgress(UserProgress progress) async {
    final db = await database;
    return await db.update(
      'user_progress',
      {
        'total_xp': progress.totalXp,
        'level': progress.level,
        'streak_days': progress.streakDays,
        'words_learned': progress.wordsLearned,
        'lessons_completed': progress.lessonsCompleted,
        'last_activity_date': progress.lastActivityDate.toIso8601String(),
        'updated_at': progress.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [progress.id],
    );
  }

  UserProgress _mapToUserProgress(Map<String, dynamic> map) {
    return UserProgress(
      id: map['id'],
      totalXp: map['total_xp'] ?? 0,
      level: map['level'] ?? 1,
      streakDays: map['streak_days'] ?? 0,
      wordsLearned: map['words_learned'] ?? 0,
      lessonsCompleted: map['lessons_completed'] ?? 0,
      lastActivityDate: DateTime.parse(map['last_activity_date'] ?? DateTime.now().toString()),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toString()),
    );
  }

  // ==================== LEARNED WORDS OPERATIONS (SRS) ====================

  Future<int> insertLearnedWord(LearnedWord learnedWord) async {
    final db = await database;
    return await db.insert('learned_words', {
      'word_id': learnedWord.wordId,
      'correct_answers': learnedWord.correctAnswers,
      'total_attempts': learnedWord.totalAttempts,
      'accuracy': learnedWord.accuracy,
      'level': learnedWord.level,
      'first_learned': learnedWord.firstLearned.toIso8601String(),
      'last_reviewed': learnedWord.lastReviewed.toIso8601String(),
      'review_count': learnedWord.reviewCount,
    });
  }

  Future<LearnedWord?> getLearnedWord(int wordId) async {
    final db = await database;
    final maps = await db.query(
      'learned_words',
      where: 'word_id = ?',
      whereArgs: [wordId],
    );
    if (maps.isNotEmpty) {
      return _mapToLearnedWord(maps.first);
    }
    return null;
  }

  Future<List<LearnedWord>> getAllLearnedWords() async {
    final db = await database;
    final maps = await db.query('learned_words', orderBy: 'last_reviewed ASC');
    return List.generate(maps.length, (i) => _mapToLearnedWord(maps[i]));
  }

  Future<List<LearnedWord>> getReviewDueWords() async {
    final db = await database;
    final now = DateTime.now();
    final maps = await db.query(
      'learned_words',
      orderBy: 'last_reviewed ASC',
    );
    
    List<LearnedWord> allWords = List.generate(maps.length, (i) => _mapToLearnedWord(maps[i]));
    return allWords.where((word) {
      return word.getNextReviewDate().isBefore(now);
    }).toList();
  }

  Future<int> updateLearnedWord(LearnedWord learnedWord) async {
    final db = await database;
    return await db.update(
      'learned_words',
      {
        'correct_answers': learnedWord.correctAnswers,
        'total_attempts': learnedWord.totalAttempts,
        'accuracy': learnedWord.accuracy,
        'level': learnedWord.level,
        'last_reviewed': learnedWord.lastReviewed.toIso8601String(),
        'review_count': learnedWord.reviewCount,
      },
      where: 'word_id = ?',
      whereArgs: [learnedWord.wordId],
    );
  }

  LearnedWord _mapToLearnedWord(Map<String, dynamic> map) {
    return LearnedWord(
      id: map['id'],
      wordId: map['word_id'],
      correctAnswers: map['correct_answers'] ?? 0,
      totalAttempts: map['total_attempts'] ?? 0,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      level: map['level'] ?? 1,
      firstLearned: DateTime.parse(map['first_learned'] ?? DateTime.now().toString()),
      lastReviewed: DateTime.parse(map['last_reviewed'] ?? DateTime.now().toString()),
      reviewCount: map['review_count'] ?? 0,
    );
  }

  // ==================== LESSONS OPERATIONS ====================

  Future<int> insertLesson(Lesson lesson) async {
    final db = await database;
    return await db.insert('lessons', {
      'id': lesson.id,
      'title': lesson.title,
      'description': lesson.description,
      'level_required': lesson.levelRequired,
      'xp_reward': lesson.xpReward,
      'difficulty': lesson.difficulty.index,
      'estimated_time': lesson.estimatedTime,
      'is_completed': lesson.isCompleted ? 1 : 0,
      'created_at': lesson.createdAt.toIso8601String(),
    });
  }

  Future<Lesson?> getLesson(int id) async {
    final db = await database;
    final maps = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _mapToLesson(maps.first);
    }
    return null;
  }

  Future<List<Lesson>> getAllLessons() async {
    final db = await database;
    final maps = await db.query('lessons', orderBy: 'id ASC');
    return List.generate(maps.length, (i) => _mapToLesson(maps[i]));
  }

  Lesson _mapToLesson(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      levelRequired: map['level_required'] ?? 1,
      questions: [],
      xpReward: map['xp_reward'] ?? 50,
      difficulty: Difficulty.values[map['difficulty'] ?? 0],
      estimatedTime: map['estimated_time'] ?? 5,
      isCompleted: (map['is_completed'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toString()),
    );
  }

  // ==================== DATABASE OPERATIONS ====================

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('quranic_words');
    await db.delete('user_progress');
    await db.delete('learned_words');
    await db.delete('lessons');
    await db.delete('questions');
    await db.delete('lesson_progress');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
