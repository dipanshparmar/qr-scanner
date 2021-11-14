import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class SavedScansDb {
  // static method to get the database
  static Future<Database> database() async {
    // getting the path
    final dbPath = await getDatabasesPath();

    // opening the database if exists otherwise creating
    return openDatabase(path.join(dbPath, 'scans.db'), onCreate: (db, version) {
      db.execute(
        'CREATE TABLE scans(id TEXT PRIMARY KEY, title TEXT, code TEXT, date TEXT)',
      );
    }, version: 1);
  }

  // static method for insertion
  static Future<void> insert(Map<String, dynamic> data) async {
    // getting the db
    final db = await database();

    // inserting
    await db.insert('scans', data);
  }

  // static method to get the data
  static Future<List<Map<String, dynamic>>> getData() async {
    // getting the db
    final db = await database();

    // returning the future that will give the data
    return db.query('scans');
  }

  // static method to delete the data
  static Future<void> delete(String id) async {
    // getting the db
    final db = await database();

    db.delete('scans', where: 'id = ?', whereArgs: [id]);
  }

  // static method to delete all the data
  static Future<void> deleteAll() async {
    // getting the db
    final db = await database();

    // deleting
    db.delete('scans');
  }

  // static method to update the data
  static Future<void> update(Map<String, dynamic> data) async {
    // getting the db
    final db = await database();

    // updating
    db.update('scans', data, where: 'id = ?', whereArgs: [data['id']]);
  }
}
