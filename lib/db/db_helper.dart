import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static Database? _db;


  Future<Database> get database async {
    if (_db != null) return _db!;


    // Init for desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _db = await initDB();
    return _db!;
  }


  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, 'members.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT,
            address TEXT,
            password TEXT
          )
        ''');
        await db.execute('DROP TABLE IF EXISTS Bulletins');

        await db.execute('''
         CREATE TABLE Bulletins (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         title TEXT,
         date TEXT,
         description TEXT,
         time TEXT
         )
         ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS family (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        relationship TEXT NOT NULL
        )
        ''');



      },
    );
  }

  Future<void> insertMember(String name, String phone, String address, String password) async {
    final db = await database;
    await db.insert('members', {
      'name': name,
      'phone': phone,
      'address': address,
      'password': password,
    });
  }

  Future<Map<String, dynamic>?> getMember(String name, String password) async {
    final db = await database;
    final result = await db.query(
      'members',
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
    );
    return result.isNotEmpty ? result.first : null;
  }
    Future<List<Map<String, dynamic>>> getAllMember()async{
      final db = await database;
      final result = await db.query('members');
      print("value $result");
      return result;
    }
  Future<int> updateMember(int id, String name, String phone, String address ) async {
    final db = await database;
    return await db.update(
      'members',
      {
      'name': name,
      'phone': phone,
      'address': address,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> deleteMember(int id) async {
    final db = await database;
    return await db.delete(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<Map<String, dynamic>?> getUserByNameAndPassword(String name, String password) async {
    final db = await database;
    final result = await db.query(
      'members',
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ---------------- Church Bulletin Functions ----------------

  Future<List<Map<String, dynamic>>> getBulletins() async {
    final db = await database;
    return await db.query('Bulletins');
  }

  Future<void> insertBulletins(String title, String date, String description, String time) async {
    try {
      final db = await database;
      await db.insert(
        'Bulletins',
        {
          'title': title,
          'date': date,
          'description': description,
          'time': time,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 🔍 Debug: check if data was inserted
      final data = await db.query('Bulletins');
      print("📦 Bulletins after insert: $data");

    } catch (e) {
      print('❌ DB Insert Error: $e');
    }
  }



  Future<int> updateBulletins(int id, String title, String date, String description, String time) async {
    final db = await database;
    return await db.update(
      'Bulletins',
      {'title': title, 'date': date, 'time': time, 'description': description},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBulletins(int id) async {
    final db = await database;
    return await db.delete(
      'Bulletins',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<int> insertFamily(String name, String relationship) async {
    try {
      final db = await database;
      final result = await db.insert('family', {
        'name': name,
        'relationship': relationship
      });
      print("✅ Inserted: $name as $relationship");
      return result;
    } catch (e) {
      print("❌ Failed to insert family member: $e");
      return -1;
    }
  }


  Future<List<Map<String, dynamic>>> getAllFamily() async {
    final db = await database;
    final data = await db.query('family');
    print("📋 All family: $data");
    return data;
  }


  Future<int> updateFamily(int id, String name, String relationship) async {
    final db = await database;
    return await db.update(
      'family',
      {'name': name, 'relationship': relationship},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFamily(int id) async {
    final db = await database;
    return await db.delete(
      'family',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


}
