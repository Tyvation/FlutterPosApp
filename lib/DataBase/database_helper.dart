import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../Models/clients.dart';
import '../Models/items.dart';
import '../Models/listings.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  static Database? _database;
  static const _version = 5;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'myDataBase.db');
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }
  
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async{
    if (oldVersion < _version){
      print('Upgrading from $oldVersion to $newVersion');
      var r = await db.rawQuery('PRAGMA table_info(items)');
      bool ex = r.any((row)=>row['name'] == 'barCode');
      if(!ex) {await db.execute('ALTER TABLE items ADD COLUMN barCode');}
      await db.execute(
        '''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT
        )'''
      );
      await db.execute('DROP TABLE IF EXISTS itemTypes');
    }
  }

  Future _onDowngrade(Database db, int oldVersion, int newVersion) async{
    if(oldVersion > 1 && newVersion == 1){
      print('Downgrading from $oldVersion to $newVersion');
      var r = await db.rawQuery('PRAGMA table_info(items)');
      bool ex = r.any((row)=>row['name'] == 'type');
      if(ex) {await db.execute('ALTER TABLE items DROP COLUMN type');}
    }
  }

  Future<void> deleteDatabaseFile() async{
    Directory docDir = await getApplicationDocumentsDirectory();
    String path = join(docDir.path, 'myDataBase.db');

    if (_database != null){
      await _database!.close();
      _database = null;
    }
    final file = File(path);
    if (await file.exists()){
      await deleteDatabase(path);
    }
    _database = await _initDatabase();
  }

  Future _onCreate(Database db, int version) async{
    await db.execute(
      '''
      CREATE TABLE clients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contactName TEXT,
        clientName TEXT,
        phoneNumber TEXT,
        email TEXT,
        address TEXT
      )
      '''
    );
    await db.execute(
      '''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        description TEXT,
        imagePath TEXT
      )
      '''
    );

     await db.execute(
      '''
      CREATE TABLE listings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        quantity INTEGER,
        comment TEXT
      )
      '''
     );
  }

  //! Clients
  Future<List<Map<String, dynamic>>> queryAllClients() async {
    Database db = await database;
    return await db.query('clients');
  }
  Future insertClient(Clients client) async{
    Database db = await database;
    return await db.insert('clients', client.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future clearClient(String id) async{
    Database db = await database;
    return await db.delete('clients', where: "id = ?", whereArgs: [id]);
  }
  Future deleteAllClientRecords() async {
    final db = await database;
    await db.delete('sqlite_sequence', where:'name = ?', whereArgs: ['clients']);
    return await db.delete('clients');
  }
  //! Items
  Future<List<Map<String, dynamic>>> queryAllItems() async {
    Database db = await database;
    return await db.query('items');
  }
  Future<int> insertItem(Items item) async {
    Database db = await database;
    return await db.insert('items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<void> deleteItem(int id) async {
    Database db = await database;
    await db.delete('items', where: 'id= ?', whereArgs: [id]);
    try{
      await db.transaction((txn) async{
        final items = await txn.query('items');
        await txn.delete('items');
        await txn.rawUpdate('UPDATE sqlite_sequence SET seq = 0 WHERE name = "items"');

        for(var item in items){
          await txn.insert('items', item);
        }
      });
    } catch(e){
      debugPrint('Error when deleting item : $e');
    }
  }
  Future deleteAllItemRecords() async{
    Database db = await database;
    await db.delete('sqlite_sequence', where:'name = ?', whereArgs: ['items']);
    return await db.delete('items');
  }
  Future updateItem(int id, Items item) async{
    Database db = await database;
    await db.update('items', item.toMap(), where: 'id = ?', whereArgs: [id]);
  }
  Future<void> reorderItems(List<Map<String, dynamic>> items) async {
    Database db = await database;
    try{
      await db.transaction((txn) async {
        await txn.delete('items');
        await txn.rawUpdate('UPDATE sqlite_sequence SET seq = 0 WHERE name = "items"');

        for (var item in items) {
          await txn.insert('items', item);
        }
      });
    } catch(e){
      debugPrint('Error reordering items : $e');
    }
  }
  Future<List<Map<String, dynamic>>> test(String type, bool order) async{
    final ordering = order ? 'ASC': 'DESC';
    Database db = await database;
    return await db.query('items', orderBy: 'stock $ordering');
  }

  //! Listing Items

  Future<List<Map<String, dynamic>>> queryAllListings() async {
    Database db = await database;
    return await db.query('listings');
  }
  Future<int> insertListing(Listings item) async{
    Database db = await database;
    return await db.insert('listings', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
    Future<int> deleteListing(int id) async {
    Database db = await database;
    return await db.delete('listings', where: 'id= ?', whereArgs: [id]);
  }
  Future deleteAllListingRecords() async{
    Database db = await database;
    await db.delete('sqlite_sequence', where:'name = ?', whereArgs: ['listings']);
    return await db.delete('listings');
  }
  Future updateListings(String name, Map<String, dynamic> listing) async{
    Database db = await database;
    await db.update('listings', listing, where: 'name = ?', whereArgs: [name]);
  }
  Future reorderListings(List<Map<String,dynamic>> listings) async{
    Database db = await database;
    await db.transaction((txn) async{
      await txn.delete('listings');
      await txn.rawUpdate('UPDATE sqlite_sequence SET seq = 0 WHERE name = "listings"');

      for (var listing in listings){
        await txn.insert('listings', listing);
      }
    });
  }
}
