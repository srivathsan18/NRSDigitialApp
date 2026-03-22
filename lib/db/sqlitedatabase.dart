import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Sqlitedatabase {
  static const String tableName = 'hsn';
  static const String dbName = 'NRSDigital.db';
  
  static Database? _database;

  /// Get the database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    
    // 2. Create the full path to the database file
    final String path = join(documentsDirectory.path, dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  /// Create database tables
  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hsncode TEXT UNIQUE NOT NULL,
        taxrate INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  /// Insert a new HSN code
  static Future<int> create<T>(String table, Map<String,dynamic> item) async {
    try {
      final db = await database;
      return await db.insert(
        table,
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

  /// Get all HSN codes
  static Future <List<Map<String,dynamic>>> get(String table) async {
    try {
      final db = await database;
      final result = await db.query(
        table
      );
       final json = result.toList();
      return json;
    } catch (e) {
      throw Exception('Failed to fetch HSN codes: $e');
    }
  }

  /// Get a specific HSN code by ID
  static Future<Object?> getById(String table,int id) async {
    try {
      final db = await database;
      final result = await db.query(
        table,
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

  /// Get HSN code by HSN code value
  static Future<Object?> exist(String hsncode) async {
    try {
      final db = await database;
      final result = await db.query(
        tableName,
        where: 'hsncode = ?',
        whereArgs: [hsncode],
      );

      if (result.isEmpty) return null;

      final json = result.first;
      return json;
    } catch (e) {
      throw Exception('Failed to fetch HSN code: $e');
    }
  }

  /// Update an existing HSN code
  static Future<int> update(String table, int id, Map<String,dynamic> item) async {
    try {
      final db = await database;

      return await db.update(
        table,
        item,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to update HSN: $e');
    }
  }

  /// Delete an HSN code
  static Future<int> delete(int id) async {
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

  /// Search HSN codes by code (partial match)
  // static Future<List<HSN>> search(String query) async {
  //   try {
  //     final db = await database;
  //     final result = await db.query(
  //       tableName,
  //       where: 'hsncode LIKE ?',
  //       whereArgs: ['%$query%'],
  //       orderBy: 'created_at DESC',
  //     );

  //     return result.map((json) {
  //       return HSN(
  //         id: json['id'] as int?,
  //         hsncode: json['hsncode'] as String,
  //         taxrate: json['taxrate'] as int,
  //       );
  //     }).toList();
  //   } catch (e) {
  //     throw Exception('Failed to search HSN codes: $e');
  //   }
  // }

  /// Get count of HSN codes
  static Future<int> getCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get HSN count: $e');
    }
  }

  /// Close the database
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
