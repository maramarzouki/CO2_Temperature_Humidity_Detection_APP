import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_auth.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print("Creating tables...");
        await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY,
          username TEXT NOT NULL,
          password TEXT NOT NULL,
          topic TEXT,
          threshold REAL NOT NULL DEFAULT 5000
        )
        ''');
        await db.execute('''
        CREATE TABLE subscriptions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          topic TEXT,
          FOREIGN KEY(user_id) REFERENCES users(id)
        )
        ''');
      },
    );
  }

  // Register user with hashed password
  Future<int> registerUser(User user) async {
    final db = await database;
    final hashedPassword = md5.convert(utf8.encode(user.password)).toString();
    user.password = hashedPassword;
    return await db.insert('users', user.toMap());
  }

  // Login user by validating username and password
  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final hashedPassword = md5.convert(utf8.encode(password)).toString();
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Add these methods to the DatabaseHelper class

// Save a subscription for a user
  Future<void> saveSubscription(int userId, String topic) async {
    final db = await database;
    await db.insert(
      'subscriptions',
      {'user_id': userId, 'topic': topic},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

// Retrieve subscriptions for a user
  Future<List<String>> getSubscriptions(int userId) async {
    final db = await database;
    final result = await db.query(
      'subscriptions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((row) => row['topic'] as String).toList();
  }

// Delete a subscription for a user
  Future<void> deleteSubscription(int userId, String topic) async {
    final db = await database;
    await db.delete(
      'subscriptions',
      where: 'user_id = ? AND topic = ?',
      whereArgs: [userId, topic],
    );
  }

  Future<void> updateThreshold(int userId, double newThreshold) async {
    final db = await database;
    await db.update(
      'Users',
      {'threshold': newThreshold},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<double?> getUserThreshold(int userId) async {
    final db = await database;
    final result = await db.query(
      'Users',
      columns: ['threshold'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first['threshold'] as double : null;
  }

  // Delete user by ID
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'subscriptions',
      where: 'user_id = ?',
      whereArgs: [id],
    );
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete and recreate tables (for resetting data)
  Future<void> deleteTable() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS subscriptions');
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute(
      '''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY,
        username TEXT,
        password TEXT,
        topic TEXT,
        threshold REAL NOT NULL DEFAULT 5000
      )
      ''',
    );
    await db.execute(
      '''
      CREATE TABLE subscriptions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        topic TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
      ''',
    );
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_auth.db');
    await deleteDatabase(path);
    print("Database deleted.");
  }
}


// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// // import 'package:sqflite/sqflite.dart';
// import '../models/user.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   static Database? _database;

//   DatabaseHelper._internal();

//   factory DatabaseHelper() => _instance;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     return openDatabase(
//       join(dbPath, 'user_auth.db'),
//       onCreate: (db, version) {
//         return db.execute(
//           'CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, password TEXT)',
//         );
//       },
//       version: 1,
//     );
//   }

//   Future<int> registerUser(User user) async {
//     final db = await database;
//     final hashedPassword = md5.convert(utf8.encode(user.password)).toString();
//     user.password = hashedPassword;
//     return await db.insert('users', user.toMap());
//   }

//   Future<User?> loginUser(String username, String password) async {
//     final db = await database;
//     final hashedPassword = md5.convert(utf8.encode(password)).toString();
//     final result = await db.query(
//       'users',
//       where: 'username = ? AND password = ?',
//       whereArgs: [username, hashedPassword],
//     );

//     if (result.isNotEmpty) {
//       return User.fromMap(result.first);
//     }
//     return null;
//   }

//   Future<void> deleteUser(int id) async {
//     final db = await database;
//     await db.delete(
//       'users',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<void> deleteTable() async {
//     final db = await database;
//     await db.execute('DROP TABLE IF EXISTS users');
//     await db.execute(
//       '''
//       CREATE TABLE users(
//         id INTEGER PRIMARY KEY, 
//         username TEXT, 
//         password TEXT,
//         topic TEXT
//       )
//       ''',
//     );
//   }
// }
