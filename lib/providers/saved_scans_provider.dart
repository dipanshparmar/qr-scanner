import 'package:flutter/material.dart';

// models
import '../models/models.dart';

// databases
import '../databases/databases.dart';

class SavedScansProvider with ChangeNotifier {
  // holding the scans
  final List<SavedScan> _savedScans = [];

  // method to fetch the saved scans
  Future<void> fetchSavedScans() async {
    // getting the data
    final data = await SavedScansDb.getData();

    // clearing the list before appending the new data
    _savedScans.clear();

    // for each data
    for (Map d in data) {
      // fetching the values
      final String id = d['id'];
      final String title = d['title'];
      final String code = d['code'];
      final String date = d['date'];

      // creating the SavedScan object
      final savedScan = SavedScan(id: id, title: title, code: code, date: date);

      // adding the data to the list
      _savedScans.add(savedScan);
    }
  }

  // method to insert the data
  Future<void> insert(Map<String, dynamic> data) async {
    // passing the data to the database
    await SavedScansDb.insert(data);

    // creating the SavedScan object of data
    // fetching the values
    final String id = data['id'];
    final String title = data['title'];
    final String code = data['code'];
    final String date = data['date'];

    // creating the object
    final savedScan = SavedScan(id: id, title: title, code: code, date: date);

    // adding the object to the list
    _savedScans.add(savedScan);

    // notifying listeners
    notifyListeners();
  }

  // getter to get the scans
  List<SavedScan> get savedScans {
    return _savedScans.toList();
  }

  // method to delete an item from the db
  Future<void> delete(String id) async {
    // deleting from db
    await SavedScansDb.delete(id);

    // deleting from the list
    _savedScans.removeWhere((element) => element.id == id);

    // notifying the listeners
    notifyListeners();
  }

  // method to delete all items from the db
  Future<void> deleteAll() async {
    // deleting from db
    await SavedScansDb.deleteAll();

    // deleting from the list
    _savedScans.clear();

    // notifying the listeners
    notifyListeners();
  }

  // method to update the data (the title)
  Future<void> update(Map<String, dynamic> data) async {
    // updating in the database
    await SavedScansDb.update(data);

    // getting the index of the scan that needs to be updated
    final index = _savedScans.indexWhere((element) => element.id == data['id']);

    // updating the title at that index
    _savedScans[index].title = data['title'];

    // notifying the listeners
    notifyListeners();
  }
}
