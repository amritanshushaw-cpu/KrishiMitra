import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class SecureDatabaseService {
  static const _databaseName = "KrishiMitraSecure.db";
  static const _databaseVersion = 1;
  static const _encryptionKey = "KRISHIMITRA_HACKATHON_SECURE_KEY";

  static const tableAuth = 'auth_users';
  static const tableLogs = 'farm_logs';

  SecureDatabaseService._privateConstructor();
  static final SecureDatabaseService instance = SecureDatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      password: _encryptionKey,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableAuth (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        temperature REAL,
        humidity REAL,
        rain_detected INTEGER,
        pump_status TEXT,
        ai_diagnosis TEXT,
        advisory_output TEXT
      )
    ''');
  }

  Future<bool> registerUser(String username, String password) async {
    Database db = await instance.database;
    try {
      await db.insert(tableAuth, {'username': username, 'password': password});
      return true;
    } catch (e) {
      return false; 
    }
  }

  Future<bool> loginUser(String username, String password) async {
    Database db = await instance.database;
    List<Map> result = await db.query(tableAuth,
        where: 'username = ? AND password = ?',
        whereArgs: [username, password]);
    return result.isNotEmpty;
  }

  Future<void> logFarmEvent(Map<String, dynamic> data) async {
    Database db = await instance.database;
    await db.insert(tableLogs, data);
  }
}
