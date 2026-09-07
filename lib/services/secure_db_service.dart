import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SecureDatabaseService {
  static const _databaseName = "KrishiMitraSecure.db";
  static const _databaseVersion = 1;
  static const _encryptionKey = "KRISHIMITRA_HACKATHON_SECURE_KEY";

  static const tableAuth = 'auth_users';
  static const tableLogs = 'farm_logs';

  static const String _prefsKeyUsers = 'krishimitra_secure_auth_users';
  static const String _prefsKeyLogs = 'krishimitra_secure_farm_logs';

  SecureDatabaseService._privateConstructor();
  static final SecureDatabaseService instance = SecureDatabaseService._privateConstructor();

  static Database? _database;
  static bool _fallbackToPrefs = false;

  /// Retrieves the encrypted SQLite database on native platforms, or returns null on Web/unsupported environments.
  Future<Database?> get database async {
    if (kIsWeb || _fallbackToPrefs) return null;
    if (_database != null) return _database;
    try {
      _database = await _initDatabase();
      return _database;
    } catch (e) {
      debugPrint("SecureDatabaseService: SQLite init failed ($e), falling back to SharedPreferences storage.");
      _fallbackToPrefs = true;
      return null;
    }
  }

  Future<Database?> _initDatabase() async {
    if (kIsWeb) return null;

    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        password: _encryptionKey,
        onCreate: _onCreate,
        onOpen: (db) async {
          try {
            final columns = await db.rawQuery("PRAGMA table_info($tableAuth)");
            final hasName = columns.any((col) => col['name'] == 'name');
            if (!hasName) {
              await db.execute("ALTER TABLE $tableAuth ADD COLUMN name TEXT");
            }
          } catch (_) {}
        },
      );
    } catch (e) {
      debugPrint("SecureDatabaseService._initDatabase error: $e");
      _fallbackToPrefs = true;
      return null;
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableAuth (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT
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

    // Pre-seed default demo users
    await db.insert(tableAuth, {
      'username': 'farmer',
      'password': 'password123',
      'name': 'Kisan Bandhu',
    });
    await db.insert(tableAuth, {
      'username': 'admin',
      'password': 'admin',
      'name': 'Farm Operator',
    });
  }

  // ==========================================
  // PUBLIC AUTHENTICATION & LOGGING APIS
  // ==========================================

  Future<bool> registerUser(String username, String password, {String? name}) async {
    final cleanUser = username.trim();
    final cleanPass = password.trim();
    final displayName = (name != null && name.trim().isNotEmpty) ? name.trim() : cleanUser;

    if (cleanUser.isEmpty || cleanPass.isEmpty) return false;

    final db = await database;
    if (db != null) {
      try {
        await db.insert(tableAuth, {
          'username': cleanUser,
          'password': cleanPass,
          'name': displayName,
        });
        return true;
      } catch (e) {
        // Unique constraint violation or SQLite error
        return false;
      }
    }

    // Seamless fallback for Web and environments without native SQLite
    return await _registerUserInPrefs(cleanUser, cleanPass, displayName);
  }

  Future<bool> loginUser(String username, String password) async {
    final cleanUser = username.trim();
    final cleanPass = password.trim();

    if (cleanUser.isEmpty || cleanPass.isEmpty) return false;

    final db = await database;
    if (db != null) {
      try {
        final List<Map<String, dynamic>> result = await db.query(
          tableAuth,
          where: 'username = ? AND password = ?',
          whereArgs: [cleanUser, cleanPass],
        );
        if (result.isNotEmpty) return true;
      } catch (e) {
        debugPrint("SecureDatabaseService loginUser db error: $e");
      }
    }

    return await _loginUserInPrefs(cleanUser, cleanPass);
  }

  Future<String?> getUserName(String username) async {
    final cleanUser = username.trim();
    if (cleanUser.isEmpty) return null;

    final db = await database;
    if (db != null) {
      try {
        final List<Map<String, dynamic>> result = await db.query(
          tableAuth,
          columns: ['name'],
          where: 'username = ?',
          whereArgs: [cleanUser],
        );
        if (result.isNotEmpty && result.first['name'] != null) {
          return result.first['name'] as String;
        }
      } catch (_) {}
    }

    return await _getUserNameInPrefs(cleanUser);
  }

  Future<void> logFarmEvent(Map<String, dynamic> data) async {
    final db = await database;
    if (db != null) {
      try {
        await db.insert(tableLogs, data);
        return;
      } catch (e) {
        debugPrint("SecureDatabaseService logFarmEvent db error: $e");
      }
    }

    await _logFarmEventInPrefs(data);
  }

  // ==========================================
  // OFFLINE LOG EXPORT
  // ==========================================
  
  /// Exports farm logs to a tiny, shareable .txt file for the given number of days.
  Future<String?> exportLogsToText({int days = 7}) async {
    if (kIsWeb) return null; // File export not supported on pure Web without download logic
    
    try {
      final DateTime cutoff = DateTime.now().subtract(Duration(days: days));
      List<Map<String, dynamic>> exportData = [];

      final db = await database;
      if (db != null) {
        final List<Map<String, dynamic>> result = await db.query(tableLogs);
        exportData = result.where((row) {
          final timeStr = row['timestamp'] as String?;
          if (timeStr == null) return false;
          try {
            final dt = DateTime.parse(timeStr);
            return dt.isAfter(cutoff);
          } catch (_) {
            return false;
          }
        }).toList();
      } else {
        final prefs = await SharedPreferences.getInstance();
        final logsRaw = prefs.getString(_prefsKeyLogs);
        if (logsRaw != null && logsRaw.isNotEmpty) {
          final List<dynamic> logs = List<dynamic>.from(jsonDecode(logsRaw) as List);
          exportData = logs.map((e) => Map<String, dynamic>.from(e as Map)).where((row) {
            final timeStr = row['timestamp'] as String?;
            if (timeStr == null) return false;
            try {
              final dt = DateTime.parse(timeStr);
              return dt.isAfter(cutoff);
            } catch (_) {
              return false;
            }
          }).toList();
        }
      }

      if (exportData.isEmpty) {
        return "No logs found for the past \$days days.";
      }

      final StringBuffer sb = StringBuffer();
      sb.writeln("=== KrishiMitra Farm Logs ===");
      sb.writeln("Export period: Past \$days days");
      sb.writeln("Total records: \${exportData.length}");
      sb.writeln("-----------------------------");

      for (var row in exportData) {
        sb.writeln("Time: \${row['timestamp']}");
        sb.writeln("Temp: \${row['temperature']}C | Hum: \${row['humidity']}% | Rain: \${row['rain_detected'] == 1}");
        sb.writeln("Pump: \${row['pump_status']}");
        if (row['ai_diagnosis'] != null) {
          sb.writeln("AI Diagnosis: \${row['ai_diagnosis']}");
        }
        sb.writeln("---");
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('\${directory.path}/krishimitra_export.txt');
      await file.writeAsString(sb.toString());
      
      return file.path;
    } catch (e) {
      debugPrint("Export failed: \$e");
      return null;
    }
  }

  // ==========================================
  // CROSS-PLATFORM & WEB STORAGE ENGINE (SharedPreferences)
  // ==========================================

  Future<Map<String, dynamic>> _getUsersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKeyUsers);
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        return Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {}
    }

    // Default demo seeds for first launch
    final defaultUsers = {
      'farmer': {
        'username': 'farmer',
        'password': 'password123',
        'name': 'Kisan Bandhu',
      },
      'admin': {
        'username': 'admin',
        'password': 'admin',
        'name': 'Farm Operator',
      },
    };
    await prefs.setString(_prefsKeyUsers, jsonEncode(defaultUsers));
    return defaultUsers;
  }

  Future<bool> _registerUserInPrefs(String username, String password, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await _getUsersFromPrefs();

      if (users.containsKey(username)) {
        return false; // User already exists
      }

      users[username] = {
        'username': username,
        'password': password,
        'name': name,
      };

      await prefs.setString(_prefsKeyUsers, jsonEncode(users));
      return true;
    } catch (e) {
      debugPrint("SecureDatabaseService fallback register error: $e");
      return false;
    }
  }

  Future<bool> _loginUserInPrefs(String username, String password) async {
    try {
      final users = await _getUsersFromPrefs();
      if (!users.containsKey(username)) return false;

      final userRecord = users[username];
      if (userRecord is Map && userRecord['password'] == password) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("SecureDatabaseService fallback login error: $e");
      return false;
    }
  }

  Future<String?> _getUserNameInPrefs(String username) async {
    try {
      final users = await _getUsersFromPrefs();
      if (users.containsKey(username)) {
        final userRecord = users[username];
        if (userRecord is Map && userRecord['name'] != null) {
          return userRecord['name'] as String;
        }
      }
    } catch (e) {
      debugPrint("SecureDatabaseService fallback getUserName error: $e");
    }
    return null;
  }

  Future<void> _logFarmEventInPrefs(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsRaw = prefs.getString(_prefsKeyLogs);
      List<dynamic> logs = [];
      if (logsRaw != null && logsRaw.isNotEmpty) {
        try {
          logs = List<dynamic>.from(jsonDecode(logsRaw) as List);
        } catch (_) {}
      }
      logs.add(data);
      await prefs.setString(_prefsKeyLogs, jsonEncode(logs));
    } catch (e) {
      debugPrint("SecureDatabaseService fallback logFarmEvent error: $e");
    }
  }
}
