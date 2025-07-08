import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';

import '../../domain/models/project.dart';
import '../services/firebase_rtdb_service.dart';

class ProjectRepository {
  static final ProjectRepository _instance = ProjectRepository._internal();

  static ProjectRepository get instance => _instance;

  final String _projectsPath = 'projects';

  factory ProjectRepository() => _instance;

  ProjectRepository._internal();

  /// Create a new project
  Future<bool> createProject(Project project) async {
    try {
      final path = '$_projectsPath/${project.id}';
      await FirebaseRTDBService.instance.writeData(path, project.toJson());
      return true;
    } on FirebaseException catch (e) {
      log('Firebase error creating project ${project.id}: ${e.message}');
      return false;
    } catch (e) {
      log('Unexpected error creating project ${project.id}: $e');
      return false;
    }
  }

  /// Delete a project
  Future<bool> deleteProject(String projectId) async {
    try {
      final path = '$_projectsPath/$projectId';
      await FirebaseRTDBService.instance.deleteData(path);
      return true;
    } on FirebaseException catch (e) {
      log('Firebase error deleting project $projectId: ${e.message}');
      return false;
    } catch (e) {
      log('Unexpected error deleting project $projectId: $e');
      return false;
    }
  }

  /// Listen to all projects changes
  Stream<(bool, List<Project>?)> listenToAllProjects() {
    return FirebaseRTDBService.instance
        .listenToPath(_projectsPath)
        .map((event) {
      try {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          return (true, <Project>[]);
        }
        final data = Map<String, dynamic>.from(
            jsonDecode(jsonEncode(event.snapshot.value)) as Map);
        final projects = data.entries
            .map((entry) =>
                Project.fromJson(Map<String, dynamic>.from(entry.value)))
            .toList();
        return (true, projects);
      } on FirebaseException catch (e) {
        log('Firebase error listening to all projects: ${e.message}');
        return (false, null);
      } catch (e) {
        log('Unexpected error listening to all projects: $e');
        return (false, null);
      }
    });
  }

  /// Listen to a single project changes
  Stream<(bool, Project?)> listenToProject(String projectId) {
    final path = '$_projectsPath/$projectId';
    return FirebaseRTDBService.instance.listenToPath(path).map((event) {
      try {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          return (true, null);
        }
        final data = Map<String, dynamic>.from(
            jsonDecode(jsonEncode(event.snapshot.value)) as Map);
        final project = Project.fromJson(data);
        return (true, project);
      } on FirebaseException catch (e) {
        log('Firebase error listening to project $projectId: ${e.message}');
        return (false, null);
      } catch (e) {
        log('Unexpected error listening to project $projectId: $e');
        return (false, null);
      }
    });
  }

  /// Read all projects
  Future<(bool, List<Project>?)> readAllProjects() async {
    try {
      final snapshot =
          await FirebaseRTDBService.instance.readPath(_projectsPath);

      if (!snapshot.exists || snapshot.value == null) {
        return (true, <Project>[]);
      }
      final data = Map<String, dynamic>.from(
          jsonDecode(jsonEncode(snapshot.value)) as Map);
      final projects = data.entries
          .map((entry) =>
              Project.fromJson(Map<String, dynamic>.from(entry.value)))
          .toList();
      return (true, projects);
    } on FirebaseException catch (e) {
      log('Firebase error reading all projects: ${e.message}');
      return (false, null);
    } catch (e) {
      log('Unexpected error reading all projects: $e');
      return (false, null);
    }
  }

  /// Read a single project
  Future<(bool, Project?)> readProject(String projectId) async {
    try {
      final path = '$_projectsPath/$projectId';
      final snapshot = await FirebaseRTDBService.instance.readPath(path);

      if (!snapshot.exists && snapshot.value == null) {
        return (true, null);
      }
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final project = Project.fromJson(data);
      return (true, project);
    } on FirebaseException catch (e) {
      log('Firebase error reading project $projectId: ${e.message}');
      return (false, null);
    } catch (e) {
      log('Unexpected error reading project $projectId: $e');
      return (false, null);
    }
  }

  /// Update an existing project
  Future<bool> updateProject(Project project) async {
    try {
      final updatedProject = project.copyWith(updatedAt: DateTime.now());
      final path = '$_projectsPath/${project.id}';
      await FirebaseRTDBService.instance
          .updateData(path, updatedProject.toJson());
      return true;
    } on FirebaseException catch (e) {
      log('Firebase error updating project ${project.id}: ${e.message}');
      return false;
    } catch (e) {
      log('Unexpected error updating project ${project.id}: $e');
      return false;
    }
  }
}
