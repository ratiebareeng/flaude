import '../models/project.dart';
import '../services/firebase_rtdb_service.dart';

class ProjectRepository {
  static const String _projectsPath = 'projects';
  final FirebaseRTDBService _rtdbService;

  ProjectRepository(this._rtdbService);

  /// Create a new project
  Future<void> createProject(Project project) async {
    final path = '$_projectsPath/${project.id}';
    await _rtdbService.writeData(path, project.toJson());
  }

  /// Delete a project
  Future<void> deleteProject(String projectId) async {
    final path = '$_projectsPath/$projectId';
    await _rtdbService.deleteData(path);
  }

  /// Listen to all projects changes
  Stream<List<Project>> listenToAllProjects() {
    return _rtdbService.listenToPath(_projectsPath).map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return data.entries
            .map((entry) =>
                Project.fromJson(Map<String, dynamic>.from(entry.value)))
            .toList();
      }
      return <Project>[];
    });
  }

  /// Listen to a single project changes
  Stream<Project?> listenToProject(String projectId) {
    final path = '$_projectsPath/$projectId';
    return _rtdbService.listenToPath(path).map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return Project.fromJson(data);
      }
      return null;
    });
  }

  /// Read all projects
  Future<List<Project>> readAllProjects() async {
    final snapshot = await _rtdbService.readPath(_projectsPath);

    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.entries
          .map((entry) =>
              Project.fromJson(Map<String, dynamic>.from(entry.value)))
          .toList();
    }
    return [];
  }

  /// Read a single project
  Future<Project?> readProject(String projectId) async {
    final path = '$_projectsPath/$projectId';
    final snapshot = await _rtdbService.readPath(path);

    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return Project.fromJson(data);
    }
    return null;
  }

  /// Update an existing project
  Future<void> updateProject(Project project) async {
    final updatedProject = project.copyWith(updatedAt: DateTime.now());
    final path = '$_projectsPath/${project.id}';
    await _rtdbService.updateData(path, updatedProject.toJson());
  }
}
