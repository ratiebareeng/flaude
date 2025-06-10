import 'package:firebase_database/firebase_database.dart';

class FirebaseRTDBService {
  static final FirebaseRTDBService _instance = FirebaseRTDBService._internal();

  static FirebaseRTDBService get instance => _instance;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  factory FirebaseRTDBService() => _instance;

  FirebaseRTDBService._internal();

  /// Delete data at a specific path
  Future<void> deleteData(String path) async {
    try {
      await _database.ref(path).remove();
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }

  /// Listen to changes at a specific path (returns a stream)
  Stream<DatabaseEvent> listenToPath(String path) {
    try {
      return _database.ref(path).onValue;
    } catch (e) {
      throw Exception('Failed to listen to path: $e');
    }
  }

  /// Read data from a specific path (returns a future)
  Future<DataSnapshot> readPath(String path) async {
    try {
      return await _database.ref(path).get();
    } catch (e) {
      throw Exception('Failed to read data: $e');
    }
  }

  /// Update data at a specific path
  Future<void> updateData(String path, Map<String, dynamic> updates) async {
    try {
      await _database.ref(path).update(updates);
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  /// Write data to a specific path
  Future<void> writeData(String path, Map<String, dynamic> data) async {
    try {
      await _database.ref(path).set(data);
    } catch (e) {
      throw Exception('Failed to write data: $e');
    }
  }
}
