import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute("""
      CREATE TABLE saved_phrases (
        id TEXT PRIMARY KEY,
        source_text TEXT NOT NULL,
        target_text TEXT NOT NULL,
        source_lang TEXT NOT NULL,
        target_lang TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        tags TEXT,
        review_count INTEGER DEFAULT 0,
        last_reviewed_at INTEGER
      )
    """);

    await db.execute("""
      CREATE TABLE transcripts (
        id TEXT PRIMARY KEY,
        source_lang TEXT NOT NULL,
        target_lang TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        title TEXT,
        translations TEXT
      )
    """);

    await db.execute("""
      CREATE TABLE flashcards (
        id TEXT PRIMARY KEY,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        source_lang TEXT NOT NULL,
        target_lang TEXT NOT NULL,
        ease_factor INTEGER DEFAULT 250,
        repetitions INTEGER DEFAULT 0,
        interval INTEGER DEFAULT 0,
        next_review INTEGER,
        created_at INTEGER
      )
    """);

    // Indices for faster queries
    await db.execute("CREATE INDEX idx_phrases_langs ON saved_phrases(source_lang, target_lang)");
    await db.execute("CREATE INDEX idx_phrases_created ON saved_phrases(created_at DESC)");
    await db.execute("CREATE INDEX idx_flashcards_review ON flashcards(next_review)");
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
