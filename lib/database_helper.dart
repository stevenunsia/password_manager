import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'models/user.dart';
import 'models/password.dart'; // Import the Password model
import 'package:path/path.dart';
import 'package:logger/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final Logger _logger = Logger();

  DatabaseHelper._init() {
    // Initialize the database factory for non-mobile platforms
    if (isWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE users (
          userId INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          fullName TEXT NOT NULL,
          password TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE passwords (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          email TEXT NOT NULL,
          username TEXT NOT NULL,
          password TEXT NOT NULL
        )
      ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE passwords (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            email TEXT NOT NULL,
            username TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');
      }
    });
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    try {
      await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      _logger.i("Database insert successful");
    } catch (e) {
      _logger.e("Error inserting into database: $e");
    }
  }

  Future<User?> getUser(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      columns: ['userId', 'username', 'fullName', 'password'],
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User(
        userId: maps.first['userId'] as int?,
        username: maps.first['username'] as String,
        fullName: maps.first['fullName'] as String,
        password: maps.first['password'] as String,
      );
    } else {
      return null;
    }
  }

  // Methods for handling passwords
  Future<void> insertPassword(Password password) async {
    final db = await database;
    await db.insert('passwords', password.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Password>> getPasswords() async {
    final db = await database;
    final maps = await db.query('passwords');
    return List.generate(maps.length, (i) {
      return Password.fromMap(maps[i]);
    });
  }

  Future<void> updatePassword(Password password) async {
    final db = await database;
    await db.update(
      'passwords',
      password.toMap(),
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  Future<void> deletePassword(int id) async {
    final db = await database;
    await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }
}

bool get isWeb => identical(0, 0.0);