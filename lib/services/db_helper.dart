import 'package:sqflite/sqflite.dart';

class DbHelper {
  static DbHelper? _dbHelper;
  static Database? _database;

  DbHelper._createObject();

  // Create DB, Table, and Column
  factory DbHelper() {
    _dbHelper ??= DbHelper._createObject();
    return _dbHelper!;
  }
}
