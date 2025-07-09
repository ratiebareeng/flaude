import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firestore;

  // Constructor requires FirebaseFirestore instance
  FirebaseFirestoreService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Create a new document with auto-generated ID.
  Future<String> createDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final docRef = _firestore.collection(collectionPath).doc();
    await docRef.set({...data, 'id': docRef.id});
    return docRef.id;
  }

  /// Delete a document.
  Future<void> deleteDocument({
    required String collectionPath,
    required String docId,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).delete();
  }

  /// Filter documents in a collection by a field and value.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> filterDocuments({
    required String collectionPath,
    required String field,
    required dynamic isEqualTo,
  }) async {
    final querySnapshot = await _firestore
        .collection(collectionPath)
        .where(field, isEqualTo: isEqualTo)
        .get();
    return querySnapshot.docs;
  }

  /// Listen to collection changes.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> listenToCollection({
    required String collectionPath,
  }) {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs;
    });
  }

  /// Listen to a document by ID.
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToDocument({
    required String collectionPath,
    required String docId,
  }) {
    return _firestore.collection(collectionPath).doc(docId).snapshots();
  }

  /// Listen filtered documents in a collection by a field and value.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      listenToFilteredDocuments({
    required String collectionPath,
    required String field,
    required dynamic isEqualTo,
  }) {
    return _firestore
        .collection(collectionPath)
        .where(field, isEqualTo: isEqualTo)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs;
    });
  }

  /// Read collection data.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> readCollection({
    required String collectionPath,
  }) async {
    final querySnapshot = await _firestore.collection(collectionPath).get();
    return querySnapshot.docs;
  }

  /// Read a document by ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> readDocument({
    required String collectionPath,
    required String docId,
  }) async {
    return await _firestore.collection(collectionPath).doc(docId).get();
  }

  /// Update fields in a document.
  Future<void> updateDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).update(data);
  }

  /// Write data to a document (creates or overwrites).
  Future<void> writeDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).set(data);
  }
}
