import 'package:flutter/foundation.dart';
import '../DataBase/database_helper.dart';
import '../Models/clients.dart';
import '../Models/items.dart';
import '../Models/listings.dart';

class MainProvider extends ChangeNotifier {
  final db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _listings = [];

  List<Map<String, dynamic>> get clients => List.from(_clients);
  List<Map<String, dynamic>> get items => List.from(_items);
  List<Map<String, dynamic>> get listings => List.from(_listings);

  MainProvider() {
    loadClients();
    loadItems();
    loadListings();
  }

  //! Clients
  Future<void> loadClients() async {
    _clients = await db.queryAllClients();
    notifyListeners();
  }
  Future<void> insertClient(Clients newClient) async {
    await db.insertClient(newClient);
    loadClients();
  }
  Future<void> clearAllClient() async {
    await db.deleteAllClientRecords();
    loadClients();
  }

  //! Items
  Future<void> loadItems() async {
    _items = await db.queryAllItems();
    notifyListeners();
  }
  Future<void> insertItem(Items newItem) async {
    await db.insertItem(newItem);
    loadItems();
  }
  Future<void> deleteItem(int id) async {
    await db.deleteItem(id);
    loadItems();
  }
  Future<void> clearAllItems() async {
    await db.deleteAllItemRecords();
    loadItems();
  }
  Future reorderItems(List<Map<String, dynamic>> items) async {
    await DatabaseHelper.instance.reorderItems(items);
    loadItems();
  }
  Future updateItems(int id, Items item) async {
    await DatabaseHelper.instance.updateItem(id, item);
    loadItems();
  }
  Future test() async {
    _items = await DatabaseHelper.instance.test('stock', true);
    notifyListeners();
  }

  //! Listings
  Future<void> loadListings() async {
    _listings = await db.queryAllListings();
    notifyListeners();
  }
  Future<void> insertListings(Listings newListing) async {
    await db.insertListing(newListing);
    loadListings();
  }
  Future<void> updateListings(String name, Listings listing) async {
    await db.updateListings(name, listing.toMap());
    loadListings();
  }
  Future<void> deleteListings(int id) async {
    await db.deleteListing(id);
    _listings = await db.queryAllListings();
    _listings = _listings.map((item) {
      Map<String, dynamic> newItem = Map.from(item);
      newItem.remove('id');
      return newItem;
    }).toList();

    await DatabaseHelper.instance.reorderListings(_listings);

    loadListings();
  }
  Future<void> clearAllListings() async {
    await db.deleteAllListingRecords();
    loadListings();
  }
}