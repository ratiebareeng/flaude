import 'package:firebase_database/firebase_database.dart';

class FirebaseRTDBService {
  final FirebaseDatabase _database;

  // Constructor requires FirebaseDatabase instance
  FirebaseRTDBService({required FirebaseDatabase database})
      : _database = database;

  /// Delete data at a specific path
  Future<void> deleteData(String path) async {
    await _database.ref(path).remove();
  }

  /// Listen to changes at a specific path (returns a stream)
  Stream<DatabaseEvent> listenToPath(String path) {
    return _database.ref(path).onValue;
  }

  /// Read data from a specific path (returns a future)
  Future<DataSnapshot> readPath(String path) async {
    return await _database.ref(path).get();
  }

  /// Read data from a specific path with filtering (returns a future)
  Future<DataSnapshot> readPathWithFilter({
    required String path,
    required String filterKey,
    bool? desc = true,
    int? limit = 10,
  }) async {
    late Query query;
    query = _database.ref(path).orderByChild(filterKey);

    if (desc == true) {
      query = query.limitToLast(limit ?? 10);
    } else {
      query = query.limitToFirst(limit ?? 10);
    }
    return await query.get();
  }

  /// Update data at a specific path
  Future<void> updateData(String path, Map<String, dynamic> updates) async {
    await _database.ref(path).update(updates);
  }

  /// Write data to a specific path
  Future<void> writeData(String path, Map<String, dynamic> data) async {
    await _database.ref(path).set(data);
  }

  /// Write data with generated ID
  Future<String> writeDataWithId(
    String path,
    String refKey,
    Map<String, dynamic> data,
  ) async {
    final ref = _database.ref(path).push();
    data[refKey] = ref.key; // Add the generated ID to the data
    await ref.set(data);
    return ref.key!;
  }
}
