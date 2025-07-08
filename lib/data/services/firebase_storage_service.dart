import 'dart:io';
import 'dart:typed_data';

import 'package:claude_chat_clone/plugins/error_manager/error_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseStorageService();

  /// Batch delete multiple files
  Future<Map<String, bool>> batchDeleteFiles({
    required List<String> paths,
  }) async {
    final results = <String, bool>{};

    for (final path in paths) {
      final success = await deleteFile(path: path);
      results[path] = success;
    }

    return results;
  }

  /// Copy file to a new location
  Future<String?> copyFile({
    required String sourcePath,
    required String destinationPath,
  }) async {
    try {
      // Download the file
      final sourceRef = _storage.ref().child(sourcePath);
      final bytes = await sourceRef.getData();

      if (bytes == null) return null;

      // Get metadata for copying
      final metadata = await sourceRef.getMetadata();

      // Upload to new location
      final destinationRef = _storage.ref().child(destinationPath);
      await destinationRef.putData(
        bytes,
        SettableMetadata(
          contentType: metadata.contentType,
          customMetadata: metadata.customMetadata,
        ),
      );

      return await destinationRef.getDownloadURL();
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error copying file($sourcePath to $destinationPath): $e',
        originFunction: 'FirebaseStorageService.copyFile',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return null;
    }
  }

  /// Delete a file
  Future<bool> deleteFile({
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
      return true;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error deleting file($path): $e',
        originFunction: 'FirebaseStorageService.deleteFile',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return false;
    }
  }

  /// Download file as bytes
  Future<Uint8List?> downloadFile({
    required String path,
    int? maxSize,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final bytes =
          await ref.getData(maxSize ?? 1024 * 1024 * 10); // 10MB default
      return bytes;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error downloading file($path): $e',
        originFunction: 'FirebaseStorageService.downloadFile',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return null;
    }
  }

  /// Check if file exists
  Future<bool> fileExists({
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      // File doesn't exist or other error
      return false;
    }
  }

  /// Generate a unique file path with timestamp
  String generateUniqueFilePath({
    required String directory,
    required String fileName,
    String? extension,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = extension ?? '';
    return '$directory/${fileName}_$timestamp$ext';
  }

  /// Get download URL for a file
  Future<String?> getDownloadURL({
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error getting download URL($path): $e',
        originFunction: 'FirebaseStorageService.getDownloadURL',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return null;
    }
  }

  /// Get file metadata
  Future<FullMetadata?> getFileMetadata({
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = await ref.getMetadata();
      return metadata;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error getting file metadata($path): $e',
        originFunction: 'FirebaseStorageService.getFileMetadata',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return null;
    }
  }

  /// Get file size in bytes
  Future<int?> getFileSize({
    required String path,
  }) async {
    try {
      final metadata = await getFileMetadata(path: path);
      return metadata?.size;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error getting file size($path): $e',
        originFunction: 'FirebaseStorageService.getFileSize',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return null;
    }
  }

  /// Get storage bucket reference
  Reference getStorageRef({String? path}) {
    return path != null ? _storage.ref().child(path) : _storage.ref();
  }

  /// List all files and subdirectories in a directory
  Future<ListResult?> listAll({
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final result = await ref.listAll();
      return result;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error listing all files($path): $e',
        originFunction: 'FirebaseStorageService.listAll',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return null;
    }
  }

  /// List files in a directory
  Future<List<Reference>> listFiles({
    required String path,
    int? maxResults,
    String? pageToken,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final result = await ref.list(ListOptions(
        maxResults: maxResults,
        pageToken: pageToken,
      ));
      return result.items;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error listing files($path): $e',
        originFunction: 'FirebaseStorageService.listFiles',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return [];
    }
  }

  /// Move file to a new location (copy then delete original)
  Future<String?> moveFile({
    required String sourcePath,
    required String destinationPath,
  }) async {
    try {
      // Copy file to new location
      final newUrl = await copyFile(
        sourcePath: sourcePath,
        destinationPath: destinationPath,
      );

      if (newUrl == null) return null;

      // Delete original file
      final deleted = await deleteFile(path: sourcePath);

      if (!deleted) {
        // If deletion failed, clean up the copied file
        await deleteFile(path: destinationPath);
        return null;
      }

      return newUrl;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error moving file($sourcePath to $destinationPath): $e',
        originFunction: 'FirebaseStorageService.moveFile',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return null;
    }
  }

  /// Update file metadata
  Future<bool> updateFileMetadata({
    required String path,
    Map<String, String>? customMetadata,
    String? contentType,
    String? contentLanguage,
    String? contentEncoding,
    String? contentDisposition,
    String? cacheControl,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        customMetadata: customMetadata,
        contentType: contentType,
        contentLanguage: contentLanguage,
        contentEncoding: contentEncoding,
        contentDisposition: contentDisposition,
        cacheControl: cacheControl,
      );
      await ref.updateMetadata(metadata);
      return true;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error updating file metadata($path): $e',
        originFunction: 'FirebaseStorageService.updateFileMetadata',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return false;
    }
  }

  /// Upload bytes data to Firebase Storage
  Future<String?> uploadBytes({
    required String path,
    required Uint8List bytes,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      UploadTask uploadTask;
      if (contentType != null) {
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(
            contentType: contentType,
            customMetadata: metadata,
          ),
        );
      } else {
        uploadTask = ref.putData(bytes);
      }

      final snapshot = await uploadTask;
      final downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error uploading bytes($path): $e',
        originFunction: 'FirebaseStorageService.uploadBytes',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return null;
    }
  }

  /// Upload a file to Firebase Storage
  Future<String?> uploadFile({
    required String path,
    required File file,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      UploadTask uploadTask;
      if (contentType != null) {
        uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: contentType,
            customMetadata: metadata,
          ),
        );
      } else {
        uploadTask = ref.putFile(file);
      }

      final snapshot = await uploadTask;
      final downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error uploading file($path): $e',
        originFunction: 'FirebaseStorageService.uploadFile',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return null;
    }
  }

  /// Upload file with progress tracking
  Stream<TaskSnapshot> uploadFileWithProgress({
    required String path,
    required File file,
    String? contentType,
    Map<String, String>? metadata,
  }) {
    try {
      final ref = _storage.ref().child(path);

      UploadTask uploadTask;
      if (contentType != null) {
        uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: contentType,
            customMetadata: metadata,
          ),
        );
      } else {
        uploadTask = ref.putFile(file);
      }

      return uploadTask.snapshotEvents;
    } catch (e) {
      ErrorManager.logError(
        errorMessage: 'Error uploading file with progress($path): $e',
        originFunction: 'FirebaseStorageService.uploadFileWithProgress',
        fileName: 'firebase_storage_service.dart',
        developer: 'Naledi',
      );
      return Stream.error(e);
    }
  }
}
