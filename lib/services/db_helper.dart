import 'dart:io';

import 'package:flutter_taptime/models/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static DbHelper? _dbHelper;
  static Database? _database;

  String dbName = "notely.db";
  String tableName = "notely";

  DbHelper._createObject();

  // Create DB, Table, and Column
  factory DbHelper() {
    _dbHelper ??= DbHelper._createObject();
    return _dbHelper!;
  }

  // Init DB
  Future<Database> initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}$dbName';
    var database = openDatabase(path, version: 1, onCreate: _createDb);
    return database;
  }

  // Create DB
  void _createDb(Database db, int version) async {
    db.execute('''
      CREATE TABLE $tableName(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id VARCHAR(50) NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      ''');
  }

  // Check Database
  Future<Database> get database async {
    _database ??= await initDb();
    return _database!;
  }

  // Get All Data
  Future<List<Map<String, dynamic>>> select() async {
    Database db = await database;
    var mapList = await db.query(tableName, orderBy: 'created_at');
    return mapList;
  }

  // Create
  Future<int> create(NoteModel noteModel) async {
    Database db = await database;
    int count = await db.insert(tableName, noteModel.toMap());
    return count;
  }

  // Update
  Future<int> update(NoteModel noteModel) async {
    Database db = await database;
    int count = await db.update(tableName, noteModel.toMap(),
        where: 'id=?', whereArgs: [noteModel.id]);
    return count;
  }

  // Delete
  Future<int> delete(int id) async {
    Database db = await database;
    int count = await db.delete(tableName, where: 'id=?', whereArgs: [id]);
    return count;
  }

  Future<List<NoteModel>> getAllData() async {
    var noteMapList = await select();
    int count = noteMapList.length;
    List<NoteModel> noteList = [];
    for (int i = 0; i < count; i++) {
      noteList.add(NoteModel.fromMap(noteMapList[i]));
    }
    return noteList;
  }
}
