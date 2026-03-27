import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class Sqlitedatabase {
  static const String dbName = 'NRSDigital.db';
  
static Database? _database;
  
  // This "Completer" acts as a lock/gate
  static Completer<Database>? _completer;

  static Future<Database> get database async {
    // 1. If it's already open, return it immediately (Fastest path)
    if (_database != null) return _database!;

    // 2. If someone ELSE is already initializing it, wait for them
    if (_completer != null) return _completer!.future;

    // 3. If we are the first ones here, start the process
    _completer = Completer<Database>();
    
    try {
      _database = await _initDatabase();
      _completer!.complete(_database); // Tell everyone waiting we are done!
      return _database!;
    } catch (e) {
      _completer = null; // Reset so we can try again if it failed
      rethrow;
    }
  }


static Future<Database> _initDatabase() async {
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    
    // 2. Create the full path to the database file
    final String path = join(documentsDirectory.path, dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase
      );
  }

  static Future<void> _createDatabase(Database db, int version) async {


    await db.execute('''
      CREATE TABLE IF NOT EXISTS HSN (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hsncode TEXT UNIQUE NOT NULL,
        taxrate INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  

     await db.execute('''
    CREATE TABLE Product(
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    hsnId INTEGER NOT NULL,
    sku VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    qty INTEGER NOT NULL,
    FOREIGN KEY (hsnId) REFERENCES HSN(id)
)
 ''');

  }

  static Future<int> create<T>(String tableName, Map<String,dynamic> item) async {
    try {
      final db = await database;
      return await db.insert(
        tableName,
        item,
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
       if (e.toString().contains('UNIQUE constraint failed')) {
      throw Exception('HSN code already exists!');
       }
      throw Exception('Failed to insert HSN: $e');
    }
  }

  static Future <List<Map<String,dynamic>>> get(String tableName) async {
    try {
      final db = await database;
      final result = await db.query(
        tableName
      );
       final json = result.toList();
      return json;
    } catch (e) {
      throw Exception('Failed to fetch HSN codes: $e');
    }
  }

  static Future<Object?> getById(String tableName,int id) async {
    try {
      final db = await database;
      final result = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) return null;

      final json = result.first;
      
      return json;
    } catch (e) {
      throw Exception('Failed to fetch HSN code: $e');
    }
  }


  static Future<int> update(String tableName, int id, Map<String,dynamic> item) async {
    try {
      final db = await database;

      return await db.update(
        tableName,
        item,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to update HSN: $e');
    }
  }

  static Future<int> delete(String tableName, int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete HSN: $e');
    }
  }

  // static Future<int> getCount() async {
  //   try {
  //     final db = await database;
  //     final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
  //     return Sqflite.firstIntValue(result) ?? 0;
  //   } catch (e) {
  //     throw Exception('Failed to get HSN count: $e');
  //   }
  // }

  /// Close the database
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
