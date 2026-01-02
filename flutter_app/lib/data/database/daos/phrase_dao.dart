import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../../models/saved_phrase.dart';
import '../database.dart';

class PhraseDao {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<SavedPhrase>> getAllPhrases() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_phrases',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  Future<SavedPhrase?> getPhraseById(String id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_phrases',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<List<SavedPhrase>> searchPhrases(String query) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_phrases',
      where: 'source_text LIKE ? OR target_text LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  Future<List<SavedPhrase>> getPhrasesByLanguagePair(
    String sourceLang,
    String targetLang,
  ) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_phrases',
      where: 'source_lang = ? AND target_lang = ?',
      whereArgs: [sourceLang, targetLang],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  Future<void> insertPhrase(SavedPhrase phrase) async {
    final db = await _db.database;
    await db.insert(
      'saved_phrases',
      _toMap(phrase),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePhrase(SavedPhrase phrase) async {
    final db = await _db.database;
    await db.update(
      'saved_phrases',
      _toMap(phrase),
      where: 'id = ?',
      whereArgs: [phrase.id],
    );
  }

  Future<void> deletePhrase(String id) async {
    final db = await _db.database;
    await db.delete(
      'saved_phrases',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toMap(SavedPhrase phrase) {
    return {
      'id': phrase.id,
      'source_text': phrase.sourceText,
      'target_text': phrase.targetText,
      'source_lang': phrase.sourceLang,
      'target_lang': phrase.targetLang,
      'created_at': phrase.createdAt.millisecondsSinceEpoch,
      'tags': jsonEncode(phrase.tags),
      'review_count': phrase.reviewCount,
      'last_reviewed_at': phrase.lastReviewedAt?.millisecondsSinceEpoch,
    };
  }

  SavedPhrase _fromMap(Map<String, dynamic> map) {
    return SavedPhrase(
      id: map['id'],
      sourceText: map['source_text'],
      targetText: map['target_text'],
      sourceLang: map['source_lang'],
      targetLang: map['target_lang'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      tags: List<String>.from(jsonDecode(map['tags'] ?? '[]')),
      reviewCount: map['review_count'] ?? 0,
      lastReviewedAt: map['last_reviewed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_reviewed_at'])
          : null,
    );
  }
}
