import 'dart:async' show Future;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'book.dart';

class CatalogDatabase {
  static final CatalogDatabase _instance = CatalogDatabase._internal();
  static Database _database;

  CatalogDatabase._internal();

  factory CatalogDatabase() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }

    _database = await init();
    return _database;
  }

  Future<List<Book>> search(String term) async {
    var client = await db;
    //final sql = 'select id, marcno, shelf, title, pub, isbn from biblio where isbn=? or title like ?';
    //final Future<List<Map<String, dynamic>>> futureMaps = client.rawQuery(sql, [term, '%term%']);

    final Future<List<Map<String, dynamic>>> futureMaps = client.query(
      'biblio',
      columns: ['id', 'marcno', 'shelf', 'title', 'pub', 'isbn'],
      where: 'isbn=? or title like ?',
      whereArgs: [term, '%$term%'],
    );

    var maps = await futureMaps;
    if (maps.length > 0) {
      return maps.map((item) => Book.fromDb(item)).toList();
    }
    return null;
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, 'catalog.db');

    // Check if the database exists
    final exists = await databaseExists(dbPath);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(dbPath)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("data", "catalog.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(dbPath).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    // open the database
    var database = await openDatabase(dbPath, readOnly: true);
    return database;
  }
}
