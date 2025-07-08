import 'package:claude_chat_clone/plugins/error_manager/error_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestoreService();

  /// Delete a document.
  Future<bool> deleteDocument({
    required String collectionPath,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).delete();
      return true;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error deleting document($collectionPath/$docId): $e',
        originFunction: 'FirebaseFirestoreService.deleteDocument',
        fileName: 'firestore_service.dart',
        developer: 'Naledi',
      );
      return false;
    }
  }

  /// Filter documents in a collection by a field and value.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> filterDocuments({
    required String collectionPath,
    required String field,
    required dynamic isEqualTo,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .where(field, isEqualTo: isEqualTo)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error filtering documents($collectionPath): $e',
        originFunction: 'FirebaseFirestoreService.filterDocuments',
        fileName: 'firestore_service.dart',
        developer: 'Naledi',
      );

      return [];
    }
  }

  /// Listen to collection changes.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> listenToCollection({
    required String collectionPath,
  }) {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs;
    });
  }

  // Listen to a document by ID.
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToDocument({
    required String collectionPath,
    required String docId,
  }) {
    return _firestore.collection(collectionPath).doc(docId).snapshots();
  }

  // Listen filtered documents in a collection by a field and value.
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

  // Read collection data
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> readCollection({
    required String collectionPath,
  }) async {
    try {
      final querySnapshot = await _firestore.collection(collectionPath).get();
      return querySnapshot.docs;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error reading collection($collectionPath): $e',
        originFunction: 'FirebaseFirestoreService.readCollection',
        fileName: 'firestore_service.dart',
        developer: 'Naledi',
      );
      return [];
    }
  }

  /// Read a document by ID.
  Future<DocumentSnapshot<Map<String, dynamic>>?> readDocument({
    required String collectionPath,
    required String docId,
  }) async {
    try {
      return await _firestore.collection(collectionPath).doc(docId).get();
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error reading document($collectionPath/$docId): $e',
        originFunction: 'FirebaseFirestoreService.readDocument',
        fileName: 'firestore_service.dart',
        developer: 'Naledi',
      );
      return null;
    }
  }

  /// Update fields in a document.
  Future<bool> updateDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).update(data);
      return true;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error updating document($collectionPath/$docId): $e',
        originFunction: 'FirebaseFirestoreService.updateDocument',
        fileName: 'firestore_service.dart',
        developer: 'Naledi',
      );
      return false;
    }
  }

  /// Write data to a document (creates or overwrites).
  Future<bool> writeDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).set(data);

      return true;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error writing document($collectionPath/$docId): $e',
        originFunction: 'FirebaseFirestoreService.writeDocument',
        fileName: 'firestore_service.dart',
        developer: 'Naledi',
      );
      return false;
    }
  }

  /// Write data to a document (creates or overwrites).
  Future<bool> writeDocumentCreatePath({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      DocumentReference<Map<String, dynamic>> docRef =
          _firestore.collection(collectionPath).doc();

      String generatedId = docRef.id;

      data['id'] = generatedId; // Add the generated ID to the data
      docRef.set(data);
      return true;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error writing document($collectionPath): $e',
        originFunction: 'FirebaseFirestoreService.writeDocumentCreatePath',
        fileName: 'firestore_service.dart',
        developer: 'Naledi',
      );
      return false;
    }
  }
}
