import 'package:claude_chat_clone/data/services/firebase_firestore_service.dart';
import 'package:claude_chat_clone/plugins/error_manager/error_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks using build_runner
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
  ErrorManager,
])
import 'firebase_firestore_service_test.mocks.dart';

void main() {
  group('FirebaseFirestoreService', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDocument;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
    late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
    late MockQuery<Map<String, dynamic>> mockQuery;
    late FirebaseFirestoreService service;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockDocument = MockDocumentReference<Map<String, dynamic>>();
      mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      mockQuery = MockQuery<Map<String, dynamic>>();

      service = FirebaseFirestoreService(firestore: mockFirestore);

      // Common setup
      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
    });

    group('deleteDocument', () {
      test('should return true when document is deleted successfully',
          () async {
        // Arrange
        when(mockDocument.delete()).thenAnswer((_) async => {});

        // Act
        final result = await service.deleteDocument(
          collectionPath: 'users',
          docId: 'user123',
        );

        // Assert
        expect(result, true);
        verify(mockFirestore.collection('users')).called(1);
        verify(mockCollection.doc('user123')).called(1);
        verify(mockDocument.delete()).called(1);
      });

      test('should return false and log error when deletion fails', () async {
        // Arrange
        when(mockDocument.delete()).thenThrow(Exception('Delete failed'));

        // Act
        final result = await service.deleteDocument(
          collectionPath: 'users',
          docId: 'user123',
        );

        // Assert
        expect(result, false);
        verify(mockDocument.delete()).called(1);
      });
    });

    group('filterDocuments', () {
      test('should return filtered documents successfully', () async {
        // Arrange
        final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        when(mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn(mockDocs);

        // Act
        final result = await service.filterDocuments(
          collectionPath: 'users',
          field: 'status',
          isEqualTo: 'active',
        );

        // Assert
        expect(result, mockDocs);
        verify(mockCollection.where('status', isEqualTo: 'active')).called(1);
        verify(mockQuery.get()).called(1);
      });

      test('should return empty list and log error when filtering fails',
          () async {
        // Arrange
        when(mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')))
            .thenThrow(Exception('Filter failed'));

        // Act
        final result = await service.filterDocuments(
          collectionPath: 'users',
          field: 'status',
          isEqualTo: 'active',
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('listenToCollection', () {
      test('should return stream of documents', () async {
        // Arrange
        final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        when(mockCollection.snapshots())
            .thenAnswer((_) => Stream.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs).thenReturn(mockDocs);

        // Act
        final stream = service.listenToCollection(collectionPath: 'users');

        // Assert
        expect(await stream.first, mockDocs);
        verify(mockCollection.snapshots()).called(1);
      });
    });

    group('listenToDocument', () {
      test('should return stream of document snapshot', () async {
        // Arrange
        when(mockDocument.snapshots())
            .thenAnswer((_) => Stream.value(mockDocSnapshot));

        // Act
        final stream = service.listenToDocument(
          collectionPath: 'users',
          docId: 'user123',
        );

        // Assert
        expect(await stream.first, mockDocSnapshot);
        verify(mockDocument.snapshots()).called(1);
      });
    });

    group('listenToFilteredDocuments', () {
      test('should return stream of filtered documents', () async {
        // Arrange
        final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        when(mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')))
            .thenReturn(mockQuery);
        when(mockQuery.snapshots())
            .thenAnswer((_) => Stream.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs).thenReturn(mockDocs);

        // Act
        final stream = service.listenToFilteredDocuments(
          collectionPath: 'users',
          field: 'status',
          isEqualTo: 'active',
        );

        // Assert
        expect(await stream.first, mockDocs);
        verify(mockCollection.where('status', isEqualTo: 'active')).called(1);
        verify(mockQuery.snapshots()).called(1);
      });
    });

    group('readCollection', () {
      test('should return collection documents successfully', () async {
        // Arrange
        final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn(mockDocs);

        // Act
        final result = await service.readCollection(collectionPath: 'users');

        // Assert
        expect(result, mockDocs);
        verify(mockCollection.get()).called(1);
      });

      test('should return empty list and log error when reading fails',
          () async {
        // Arrange
        when(mockCollection.get()).thenThrow(Exception('Read failed'));

        // Act
        final result = await service.readCollection(collectionPath: 'users');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('readDocument', () {
      test('should return document snapshot successfully', () async {
        // Arrange
        when(mockDocument.get()).thenAnswer((_) async => mockDocSnapshot);

        // Act
        final result = await service.readDocument(
          collectionPath: 'users',
          docId: 'user123',
        );

        // Assert
        expect(result, mockDocSnapshot);
        verify(mockDocument.get()).called(1);
      });

      test('should return null and log error when reading fails', () async {
        // Arrange
        when(mockDocument.get()).thenThrow(Exception('Read failed'));

        // Act
        final result = await service.readDocument(
          collectionPath: 'users',
          docId: 'user123',
        );

        // Assert
        expect(result, null);
      });
    });

    group('updateDocument', () {
      test('should return true when document is updated successfully',
          () async {
        // Arrange
        final data = {'name': 'John Doe', 'age': 30};
        when(mockDocument.update(any)).thenAnswer((_) async => {});

        // Act
        final result = await service.updateDocument(
          collectionPath: 'users',
          docId: 'user123',
          data: data,
        );

        // Assert
        expect(result, true);
        verify(mockDocument.update(data)).called(1);
      });

      test('should return false and log error when update fails', () async {
        // Arrange
        final data = {'name': 'John Doe', 'age': 30};
        when(mockDocument.update(any)).thenThrow(Exception('Update failed'));

        // Act
        final result = await service.updateDocument(
          collectionPath: 'users',
          docId: 'user123',
          data: data,
        );

        // Assert
        expect(result, false);
      });
    });

    group('writeDocument', () {
      test('should return true when document is written successfully',
          () async {
        // Arrange
        final data = {'name': 'John Doe', 'age': 30};
        when(mockDocument.set(any)).thenAnswer((_) async => {});

        // Act
        final result = await service.writeDocument(
          collectionPath: 'users',
          docId: 'user123',
          data: data,
        );

        // Assert
        expect(result, true);
        verify(mockDocument.set(data)).called(1);
      });

      test('should return false and log error when write fails', () async {
        // Arrange
        final data = {'name': 'John Doe', 'age': 30};
        when(mockDocument.set(any)).thenThrow(Exception('Write failed'));

        // Act
        final result = await service.writeDocument(
          collectionPath: 'users',
          docId: 'user123',
          data: data,
        );

        // Assert
        expect(result, false);
      });
    });

    group('writeDocumentCreatePath', () {
      test('should return true when document is written with generated ID',
          () async {
        // Arrange
        final data = {'name': 'John Doe', 'age': 30};
        final generatedId = 'generated_id_123';

        when(mockCollection.doc()).thenReturn(mockDocument);
        when(mockDocument.id).thenReturn(generatedId);
        when(mockDocument.set(any)).thenAnswer((_) async => {});

        // Act
        final result = await service.writeDocumentCreatePath(
          collectionPath: 'users',
          data: data,
        );

        // Assert
        expect(result, true);
        expect(data['id'], generatedId);
        verify(mockCollection.doc()).called(1);
        verify(mockDocument.set(data)).called(1);
      });

      test(
          'should return false and log error when write with generated ID fails',
          () async {
        // Arrange
        final data = {'name': 'John Doe', 'age': 30};
        when(mockCollection.doc()).thenThrow(Exception('Create path failed'));

        // Act
        final result = await service.writeDocumentCreatePath(
          collectionPath: 'users',
          data: data,
        );

        // Assert
        expect(result, false);
      });
    });

    group('constructor', () {
      test('should use provided firestore instance', () {
        // Arrange & Act
        final service = FirebaseFirestoreService(firestore: mockFirestore);

        // Assert
        expect(service, isA<FirebaseFirestoreService>());
      });
    });
  });
}
