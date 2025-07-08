import 'package:claude_chat_clone/data/services/global_keys.dart';
import 'package:flutter/material.dart';

import '../../domain/models/project.dart';
import '../repositories/project_repository.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();

  static ProjectService get instance => _instance;

  factory ProjectService() => _instance;

  ProjectService._internal();

  Future<bool> createProject(Project project) async {
    final success = await ProjectRepository.instance.createProject(project);

    if (!success) {
      _showError('Failed to create project. Please try again.');
      return false;
    }
    _showSuccess('Project created successfully!');
    return success;
  }

  Future<bool> deleteProject(String projectId) async {
    final success = await ProjectRepository.instance.deleteProject(projectId);

    if (!success) {
      _showError('Failed to delete project. Please try again.');
      return false;
    }
    _showSuccess('Project deleted successfully!');
    return success;
  }

  Future<List<Project>> getAllProjects() async {
    final (success, projects) =
        await ProjectRepository.instance.readAllProjects();

    if (!success) {
      _showError('Failed to load projects. Please check your connection.');
      return [];
    }

    return projects ?? [];
  }

  Future<Project?> getProject(String projectId) async {
    final (success, project) =
        await ProjectRepository.instance.readProject(projectId);

    if (!success) {
      _showError('Failed to load project. Please check your connection.');
      return null;
    }

    return project;
  }

  Future<bool> updateProject(Project project) async {
    final success = await ProjectRepository.instance.updateProject(project);

    if (!success) {
      _showError('Failed to update project. Please try again.');
      return false;
    }
    _showSuccess('Project updated successfully!');

    return success;
  }

  Stream<List<Project>> watchAllProjects() {
    return ProjectRepository.instance.listenToAllProjects().map((result) {
      final (success, projects) = result;

      if (!success) {
        _showError('Lost connection to projects. Reconnecting...');
        return <Project>[];
      }

      return projects ?? [];
    });
  }

  Stream<Project?> watchProject(String projectId) {
    return ProjectRepository.instance.listenToProject(projectId).map((result) {
      final (success, project) = result;

      if (!success) {
        _showError('Lost connection to project. Reconnecting...');
        return null;
      }

      return project;
    });
  }

  void _showError(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade300,
      ),
    );
  }

  void _showSuccess(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade300,
      ),
    );
  }
}
