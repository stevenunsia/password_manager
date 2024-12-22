import 'package:sqflite/sqflite.dart';
import 'models/password.dart';
import 'models/user.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const userTable = '''
    CREATE TABLE users (
      userId INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      fullName TEXT NOT NULL,
      password TEXT NOT NULL
    )
    ''';

    const passwordTable = '''
    CREATE TABLE passwords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      email TEXT NOT NULL,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      FOREIGN KEY (username) REFERENCES users (username)
    )
    ''';

    await db.execute(userTable);
    await db.execute(passwordTable);
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
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'userId = ?',
      whereArgs: [user.userId],
    );
  }

  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Password>> getPasswordsByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'passwords',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return maps.map((map) => Password.fromMap(map)).toList();
    } else {
      return [];
    }
  }

  Future<void> insertPassword(Password password) async {
    final db = await database;
    await db.insert('passwords', password.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
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
    await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}