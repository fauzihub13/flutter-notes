import 'dart:io';

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
  void _createDb(Database db, int version) async{
    db.execute(
      '''
      CREATE TABLE $tableName(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id VARCHAR(50) NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      '''
    );
  }

  // Check Database
  Future<Database> get database async{
    _database ??= await initDb();
    return _database!;
  }

  // Get All Data
  Future<List<Map<String, dynamic>>> select() async {
    Database db = await database;
    var mapList = await db.query(tableName, orderBy: 'created_at');
    return mapList;
  } 



}
