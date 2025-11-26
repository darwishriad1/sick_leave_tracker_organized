import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sick_leave.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sick_leave_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE sick_leaves(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        soldierName TEXT,
        militaryNumber TEXT,
        startDate TEXT,
        endDate TEXT,
        reason TEXT,
        notes TEXT
      )
      ''',
    );
  }

  // Insert a SickLeave into the database
  Future<int> insertLeave(SickLeave leave) async {
    final db = await database;
    return await db.insert(
      'sick_leaves',
      leave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all SickLeaves from the database
  Future<List<SickLeave>> getLeaves() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sick_leaves',
      orderBy: 'startDate DESC', // Order by start date descending
    );

    return List.generate(maps.length, (i) {
      return SickLeave.fromMap(maps[i]);
    });
  }

  // Update a SickLeave in the database
  Future<int> updateLeave(SickLeave leave) async {
    final db = await database;
    return await db.update(
      'sick_leaves',
      leave.toMap(),
      where: 'id = ?',
      whereArgs: [leave.id],
    );
  }

  // Delete a SickLeave from the database
  Future<int> deleteLeave(int id) async {
    final db = await database;
    return await db.delete(
      'sick_leaves',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search/Filter SickLeaves
  Future<List<SickLeave>> searchLeaves(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sick_leaves',
      where: 'soldierName LIKE ? OR militaryNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'startDate DESC',
    );

    return List.generate(maps.length, (i) {
      return SickLeave.fromMap(maps[i]);
    });
  }
}
