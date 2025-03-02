import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

Future<void> markAttendance(String eid) async {
  final db = await database;
  await db.update(
    'employees',
    {'attendance': 'Present', 'punchIn': DateTime.now().toString()},
    where: 'eid = ?',
    whereArgs: [eid],
  );
}


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'employee.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE employees(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        facedata TEXT,
        eid TEXT,
        password TEXT,
        attendance TEXT,
        punchIn TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS employees');
      await _onCreate(db, newVersion);
    }
  }

  Future<List<Map<String, dynamic>>> getEmployeesByEid(String eid) async {
    final db = await database;
    return await db.query(
      'employees',
      where: 'eid = ?',
      whereArgs: [eid],
    );
  }

  Future<bool> validateEmployee(String eid, String password) async {
    final db = await database;
    final result = await db.query(
      'employees',
      where: 'eid = ? AND password = ?',
      whereArgs: [eid, password],
    );
    return result.isNotEmpty;
  }

  Future<void> updateEmployeeByEID(String eid, Map<String, dynamic> newData) async {
    final db = await database;
    await db.update(
      'employees',
      newData,
      where: 'eid = ?',
      whereArgs: [eid],
    );
  }

  Future<int> insertEmployee(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('employees', data);
  }

  Future<List<Map<String, dynamic>>> getEmployees() async {
    final db = await database;
    return await db.query('employees');
  }

  Future<int> updateEmployee(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('employees', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteEmployee(int id) async {
    final db = await database;
    return await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  Future<List?> getFaceEncoding(String eid) async {
    final db = await database;
    final result = await db.query(
      'employees',
      where: 'eid = ?',
      whereArgs: [eid],
    );

    if (result.isNotEmpty) {
      var faceEncodingString = result.first['facedata'];

      if (faceEncodingString != null) {
      }
    }
    return null;
  }
}
