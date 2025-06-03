import 'dart:developer';

import 'package:notes_app/core/models/note_model.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tablename = 'notes';

  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }
    try {
      String path = '${await getDatabasesPath()}notes.db';
      _db = await openDatabase(
        path,
        version: _version,
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE $_tablename(id INTEGER PRIMARY KEY AUTOINCREMENT, title STRING, note TEXT, date STRING)",
          );
        },
      );
    } catch (e) {}
  }

  static Future<int> insert(Note note) async {
    return await _db!.insert(_tablename, note.toJson());
  }

  // static Future<int> find(String title) async {
  //   return await _db!.query(_tablename, where: 'title = ?',whereArgs: [title]);
  // }

  static Future<int> delete(Note note) async {
    return await _db!.delete(_tablename, where: 'id = ?', whereArgs: [note.id]);
  }

  static Future<List<Map<String, dynamic>>> query() async {
    return _db!.query(_tablename);
  }

  static Future<int> update(Note note) async {
    return await _db!.rawUpdate(
      "UPDATE notes SET title = ?, note = ? WHERE id = ? ",
      [note.title, note.text, note.id],
    );
  }

  static Future<List<Note>> sortNotes({bool sortByDate = true}) async {
    final orderField = sortByDate ? 'date' : 'title';
    final List<Map<String, dynamic>> result = await _db!.query(
      _tablename,
      orderBy: '$orderField DESC',
    );
    return result.map((e) => Note.fromMap(e)).toList();
  }

  static Future<List<Note>> searchNotesByTitle(String keyword) async {
    final List<Map<String, dynamic>> result = await _db!.query(
      _tablename,
      where: 'LOWER(title) LIKE ?',
      whereArgs: ['%${keyword.toLowerCase()}%'],
      orderBy: 'date DESC',
    );
    log(result.toString());
    return result.map((e) => Note.fromMap(e)).toList();
  }
}
