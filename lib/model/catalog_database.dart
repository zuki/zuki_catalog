import 'dart:async' show Future;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
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

    final Future<List<Map<String, dynamic>>> futureMaps = client.query(
      'biblio',
      columns: ['id', 'marcno', 'shelf', 'title', 'pub', 'isbn'],
      where: 'isbn like ? or title like ?',
      whereArgs: ['$term%', '%$term%'],
      orderBy: 'title',
    );

    var maps = await futureMaps;
    if (maps.length > 0) {
      return maps.map((item) => Book.fromDb(item)).toList();
    }
    return null;
  }

  Future<List<Book>> searchByIsbn(String isbn) async {
    var client = await db;

    final Future<List<Map<String, dynamic>>> futureMaps = client.query(
      'biblio',
      columns: ['id', 'marcno', 'shelf', 'title', 'pub', 'isbn'],
      where: 'isbn = ?',
      whereArgs: [isbn],
    );

    var maps = await futureMaps;
    if (maps.length > 0) {
      return maps.map((item) => Book.fromDb(item)).toList();
    }
    return null;
  }

  Future<Book> insert(Book book) async {
    await _database.transaction((txn) async {
      book.id = await txn.rawInsert(
        'insert into biblio(marcno, shelf, title, pub, isbn) values(?, ?, ?, ?, ?)',
        [book.marcno, book.shelf, book.title, book.pub, book.isbn]
      );
    });

    return book;
  }

  Future<int> delete(int id) async {
    return await _database.delete('biblio', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Book book) async {
    return await _database.update('biblio', book.toMap(),
        where: 'id = ?', whereArgs: [book.id]);
  }

  Future close() async => _database.close();

  Future<Database> init() async {
    var directory = await getDatabasesPath();
    String dbPath = join(directory, 'catalog.db');

    // Check if the database exists
    final exists = await databaseExists(dbPath);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(directory).create(recursive: true);
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
    var database = await openDatabase(dbPath);
    return database;
  }
}
