import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;

  factory LocalDatabase() => _instance;

  LocalDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'deliver_mee_offline.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_queue (
        id TEXT PRIMARY KEY,
        action TEXT,
        data TEXT,
        synced INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE cached_data (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<void> insertOfflineAction(String id, String action, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'offline_queue',
      {
        'id': id,
        'action': action,
        'data': jsonEncode(data),
        'synced': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedActions() async {
    final db = await database;
    return await db.query('offline_queue', where: 'synced = ?', whereArgs: [0]);
  }

  Future<void> markActionSynced(String id) async {
    final db = await database;
    await db.update(
      'offline_queue',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'cached_data',
      {
        'key': key,
        'value': jsonEncode(data),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCachedData(String key) async {
    final db = await database;
    final results = await db.query('cached_data', where: 'key = ?', whereArgs: [key]);
    if (results.isNotEmpty) {
      return jsonDecode(results.first['value'] as String) as Map<String, dynamic>;
    }
    return null;
  }
}
