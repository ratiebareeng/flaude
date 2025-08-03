import 'dart:convert';

import 'package:claude_chat_clone/core/constants/constants.dart';
import 'package:claude_chat_clone/core/error/exceptions.dart';
import 'package:claude_chat_clone/data/datasources/base/remote_datasource.dart';
import 'package:claude_chat_clone/data/datasources/interfaces/project_remote_datasource_interface.dart';
import 'package:claude_chat_clone/data/models/data_models.dart';
import 'package:claude_chat_clone/data/services/firebase_rtdb_service.dart';
import 'package:firebase_database/firebase_database.dart';

/// Firebase implementation of project remote datasource
class ProjectRemoteDatasourceImpl extends RemoteDatasource
    implements ProjectRemoteDatasource {
  final FirebaseRTDBService _rtdbService;
  final String _projectsPath = ApiConstants.projectsPath;
  final String _artifactsPath = ApiConstants.artifactsPath;

  ProjectRemoteDatasourceImpl({
    required FirebaseRTDBService rtdbService,
    required super.networkInfo,
  }) : _rtdbService = rtdbService;

  @override
  Future<void> addArtifactToProject(
      String projectId, ArtifactDTO artifact) async {
    return performNetworkOperation(
      () async {
        if (projectId.isEmpty) {
          throw ProjectException.notFound(projectId);
        }

        if (!artifact.isValid()) {
          throw ValidationException.invalidInput(
            field: 'artifact',
            reason: 'Invalid artifact data: ${artifact.getValidationErrors()}',
          );
        }

        // Verify project exists
        final projectExists = await this.projectExists(projectId);
        if (!projectExists) {
          throw ProjectException.notFound(projectId);
        }

        // Add artifact with project reference
        final artifactWithProject = artifact.copyWith(
          projectId: projectId,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        final artifactPath = '$_artifactsPath/${artifact.id}';
        await _rtdbService.writeData(
          artifactPath,
          artifactWithProject.toFirebaseJson(),
        );

        // Update project timestamp
        await _updateProjectTimestamp(projectId);
      },
      context: 'ProjectRemoteDatasource.addArtifactToProject',
      customMessage: 'Failed to add artifact to project',
    );
  }

  @override
  Future<String> createProject(ProjectDTO project) async {
    return performNetworkOperation(
      () async {
        if (!project.isValid()) {
          throw ProjectException.createFailed(
            reason: 'Invalid project data: ${project.getValidationErrors()}',
          );
        }

        // Check if name is unique
        final nameExists = await isProjectNameUnique(project.name);
        if (!nameExists) {
          throw ProjectException.nameAlreadyExists(project.name);
        }

        final projectData = project.toFirebaseJson();

        if (project.id.isEmpty) {
          // Generate new ID
          final projectId = await _rtdbService.writeDataWithId(
            _projectsPath,
            'id',
            projectData,
          );
          return projectId;
        } else {
          // Use provided ID
          final path = '$_projectsPath/${project.id}';
          await _rtdbService.writeData(path, projectData);
          return project.id;
        }
      },
      context: 'ProjectRemoteDatasource.createProject',
      customMessage: 'Failed to create project',
    );
  }

  @override
  Future<void> deleteProject(String projectId) async {
    return performNetworkOperation(
      () async {
        if (projectId.isEmpty) {
          throw ProjectException.notFound(projectId);
        }

        // Check if project has artifacts
        final artifacts = await getProjectArtifacts(projectId);

        // Delete all project artifacts first
        for (final artifact in artifacts) {
          await removeArtifactFromProject(projectId, artifact.id);
        }

        // Delete the project
        final projectPath = '$_projectsPath/$projectId';
        await _rtdbService.deleteData(projectPath);
      },
      context: 'ProjectRemoteDatasource.deleteProject',
      customMessage: 'Failed to delete project',
    );
  }

  @override
  Future<List<ProjectDTO>> getAllProjects() async {
    return performNetworkOperation(
      () async {
        final snapshot = await _rtdbService.readPath(_projectsPath);

        if (!snapshot.exists || snapshot.value == null) {
          return <ProjectDTO>[];
        }

        final data = _parseSnapshotData(snapshot);
        final projects = data.entries
            .map((entry) => ProjectDTO.fromFirebaseJson(
                Map<String, dynamic>.from(entry.value)))
            .where((project) => project.isValid())
            .toList();

        // Sort by most recently updated
        projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        return projects;
      },
      context: 'ProjectRemoteDatasource.getAllProjects',
      customMessage: 'Failed to load projects',
    );
  }

  @override
  Future<ProjectDTO?> getProject(String projectId) async {
    return performNetworkOperation(
      () async {
        if (projectId.isEmpty) {
          throw ProjectException.notFound(projectId);
        }

        final path = '$_projectsPath/$projectId';
        final snapshot = await _rtdbService.readPath(path);

        if (!snapshot.exists || snapshot.value == null) {
          return null;
        }

        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final project = ProjectDTO.fromFirebaseJson(data);

        if (!project.isValid()) {
          throw ProjectException.createFailed(
            reason: 'Invalid project data: ${project.getValidationErrors()}',
          );
        }

        return project;
      },
      context: 'ProjectRemoteDatasource.getProject',
      customMessage: 'Failed to load project',
    );
  }

  @override
  Future<List<ArtifactDTO>> getProjectArtifacts(String projectId) async {
    return performNetworkOperation(
      () async {
        if (projectId.isEmpty) {
          throw ProjectException.notFound(projectId);
        }

        final snapshot = await _rtdbService.readPath(_artifactsPath);

        if (!snapshot.exists || snapshot.value == null) {
          return <ArtifactDTO>[];
        }

        final data = _parseSnapshotData(snapshot);
        final artifacts = data.entries
            .map((entry) => ArtifactDTO.fromFirebaseJson(
                Map<String, dynamic>.from(entry.value)))
            .where((artifact) =>
                artifact.isValid() && artifact.projectId == projectId)
            .toList();

        // Sort by creation date (newest first)
        artifacts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return artifacts;
      },
      context: 'ProjectRemoteDatasource.getProjectArtifacts',
      customMessage: 'Failed to load project artifacts',
    );
  }

  @override
  Future<List<ProjectDTO>> getProjectsByName(String name) async {
    return performNetworkOperation(
      () async {
        final allProjects = await getAllProjects();
        return allProjects
            .where(
                (project) => project.name.toLowerCase() == name.toLowerCase())
            .toList();
      },
      context: 'ProjectRemoteDatasource.getProjectsByName',
      customMessage: 'Failed to search projects by name',
    );
  }

  @override
  Future<bool> isProjectNameUnique(String name,
      {String? excludeProjectId}) async {
    return performNetworkOperation(
      () async {
        final projectsWithName = await getProjectsByName(name);

        if (excludeProjectId != null) {
          // Filter out the excluded project
          return !projectsWithName
              .any((project) => project.id != excludeProjectId);
        }

        return projectsWithName.isEmpty;
      },
      context: 'ProjectRemoteDatasource.isProjectNameUnique',
      customMessage: 'Failed to check project name uniqueness',
    );
  }

  @override
  Future<bool> projectExists(String projectId) async {
    return performNetworkOperation(
      () async {
        if (projectId.isEmpty) return false;

        final path = '$_projectsPath/$projectId';
        final snapshot = await _rtdbService.readPath(path);
        return snapshot.exists && snapshot.value != null;
      },
      context: 'ProjectRemoteDatasource.projectExists',
    );
  }

  @override
  Future<void> removeArtifactFromProject(
      String projectId, String artifactId) async {
    return performNetworkOperation(
      () async {
        if (projectId.isEmpty || artifactId.isEmpty) {
          throw ProjectException.notFound(projectId);
        }

        final artifactPath = '$_artifactsPath/$artifactId';
        await _rtdbService.deleteData(artifactPath);

        // Update project timestamp
        await _updateProjectTimestamp(projectId);
      },
      context: 'ProjectRemoteDatasource.removeArtifactFromProject',
      customMessage: 'Failed to remove artifact from project',
    );
  }

  @override
  Future<List<ProjectDTO>> searchProjects(String query) async {
    return performNetworkOperation(
      () async {
        if (query.trim().isEmpty) {
          return await getAllProjects();
        }

        final allProjects = await getAllProjects();
        final lowerQuery = query.toLowerCase();

        return allProjects.where((project) {
          final nameMatch = project.name.toLowerCase().contains(lowerQuery);
          final descMatch =
              project.description.toLowerCase().contains(lowerQuery);
          return nameMatch || descMatch;
        }).toList();
      },
      context: 'ProjectRemoteDatasource.searchProjects',
      customMessage: 'Failed to search projects',
    );
  }

  @override
  Future<void> updateProject(ProjectDTO project) async {
    return performNetworkOperation(
      () async {
        if (project.id.isEmpty) {
          throw ProjectException.notFound(project.id);
        }

        if (!project.isValid()) {
          throw ProjectException.updateFailed(
            reason: 'Invalid project data: ${project.getValidationErrors()}',
          );
        }

        // Check if new name is unique (if name changed)
        final currentProject = await getProject(project.id);
        if (currentProject != null && currentProject.name != project.name) {
          final nameExists = await isProjectNameUnique(
            project.name,
            excludeProjectId: project.id,
          );
          if (!nameExists) {
            throw ProjectException.nameAlreadyExists(project.name);
          }
        }

        // Update timestamp
        final updatedProject = project.copyWith(
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        final path = '$_projectsPath/${project.id}';
        await _rtdbService.updateData(path, updatedProject.toFirebaseJson());
      },
      context: 'ProjectRemoteDatasource.updateProject',
      customMessage: 'Failed to update project',
    );
  }

  @override
  Stream<List<ProjectDTO>> watchAllProjects() {
    return _rtdbService.listenToPath(_projectsPath).map((event) {
      return handleException(
        () {
          if (!event.snapshot.exists || event.snapshot.value == null) {
            return <ProjectDTO>[];
          }

          final data = _parseSnapshotData(event.snapshot);
          final projects = data.entries
              .map((entry) => ProjectDTO.fromFirebaseJson(
                  Map<String, dynamic>.from(entry.value)))
              .where((project) => project.isValid())
              .toList();

          // Sort by most recently updated
          projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return projects;
        },
        context: 'ProjectRemoteDatasource.watchAllProjects',
      );
    });
  }

  @override
  Stream<ProjectDTO?> watchProject(String projectId) {
    if (projectId.isEmpty) {
      return Stream.value(null);
    }

    final path = '$_projectsPath/$projectId';
    return _rtdbService.listenToPath(path).map((event) {
      return handleException(
        () {
          if (!event.snapshot.exists || event.snapshot.value == null) {
            return null;
          }

          final data = Map<String, dynamic>.from(
              jsonDecode(jsonEncode(event.snapshot.value)) as Map);
          final project = ProjectDTO.fromFirebaseJson(data);

          return project.isValid() ? project : null;
        },
        context: 'ProjectRemoteDatasource.watchProject',
      );
    });
  }

  /// Helper method to parse Firebase snapshot data
  Map<String, dynamic> _parseSnapshotData(DataSnapshot snapshot) {
    try {
      return Map<String, dynamic>.from(
          jsonDecode(jsonEncode(snapshot.value)) as Map);
    } catch (e) {
      throw DatabaseException.dataNotFound();
    }
  }

  /// Helper method to update project timestamp
  Future<void> _updateProjectTimestamp(String projectId) async {
    try {
      final projectPath = '$_projectsPath/$projectId';
      final snapshot = await _rtdbService.readPath(projectPath);

      if (snapshot.exists && snapshot.value != null) {
        await _rtdbService.updateData(projectPath, {
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      // Don't throw error for timestamp update failures
      // as they're not critical to core functionality
    }
  }
}
