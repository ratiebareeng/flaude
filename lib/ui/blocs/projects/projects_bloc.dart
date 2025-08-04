import 'dart:async';

import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/usecases/usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'projects_event.dart';
import 'projects_state.dart';

/// BLoC for managing projects state
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final GetProjects _getProjects;
  final CreateProject _createProject;
  final UpdateProject _updateProject;
  final DeleteProject _deleteProject;
  final SearchProjects _searchProjects;
  final WatchProjects _watchProjects;
  final GetProjectArtifacts _getProjectArtifacts;
  final AddArtifactToProject _addArtifactToProject;
  final RemoveArtifactFromProject _removeArtifactFromProject;

  final Uuid _uuid = Uuid();
  StreamSubscription? _projectsSubscription;

  ProjectsBloc({
    required GetProjects getProjects,
    required CreateProject createProject,
    required UpdateProject updateProject,
    required DeleteProject deleteProject,
    required SearchProjects searchProjects,
    required WatchProjects watchProjects,
    required GetProjectArtifacts getProjectArtifacts,
    required AddArtifactToProject addArtifactToProject,
    required RemoveArtifactFromProject removeArtifactFromProject,
  })  : _getProjects = getProjects,
        _createProject = createProject,
        _updateProject = updateProject,
        _deleteProject = deleteProject,
        _searchProjects = searchProjects,
        _watchProjects = watchProjects,
        _getProjectArtifacts = getProjectArtifacts,
        _addArtifactToProject = addArtifactToProject,
        _removeArtifactFromProject = removeArtifactFromProject,
        super(const ProjectsInitial()) {
    on<ProjectsInitialized>(_onProjectsInitialized);
    on<ProjectsLoadedEvent>(
        _onProjectsLoaded); // Changed from ProjectsLoaded to ProjectsLoadedEvent
    on<ProjectLoaded>(_onProjectLoaded);
    on<ProjectsSearched>(_onProjectsSearched);
    on<ProjectsSearchCleared>(_onSearchCleared);
    on<ProjectCreated>(_onProjectCreated);
    on<ProjectUpdated>(_onProjectUpdated);
    on<ProjectDeleted>(_onProjectDeleted);
    on<ProjectArchived>(_onProjectArchived);
    on<ProjectRestored>(_onProjectRestored);
    on<ProjectDuplicated>(_onProjectDuplicated);
    on<ProjectRenamed>(_onProjectRenamed);
    on<ProjectDescriptionUpdated>(_onProjectDescriptionUpdated);
    on<ProjectTagsUpdated>(_onProjectTagsUpdated);
    on<ProjectColorUpdated>(_onProjectColorUpdated);
    on<ProjectSettingsUpdated>(_onProjectSettingsUpdated);
    on<ProjectArtifactAdded>(_onProjectArtifactAdded);
    on<ProjectArtifactRemoved>(_onProjectArtifactRemoved);
    on<ProjectArtifactsLoaded>(_onProjectArtifactsLoaded);
    on<ProjectsSorted>(_onProjectsSorted);
    on<ProjectsFiltered>(_onProjectsFiltered);
    on<ProjectsFiltersCleared>(_onFiltersCleared);
    on<ProjectsMultiSelected>(_onMultiSelected);
    on<ProjectsMultiSelectionCleared>(_onMultiSelectionCleared);
    on<ProjectsBulkAction>(_onBulkAction);
    on<ProjectsExportedEvent>(_onProjectsExported);
    on<ProjectsImportedEvent>(_onProjectsImported);
    on<ProjectsRefreshed>(_onProjectsRefreshed);
    on<ProjectsSubscriptionStarted>(_onSubscriptionStarted);
    on<ProjectsSubscriptionStopped>(_onSubscriptionStopped);
    on<ProjectsReceived>(_onProjectsReceived);
    on<ProjectsStatisticsRequested>(_onStatisticsRequested);
    on<ProjectNameValidated>(_onProjectNameValidated);
    on<ProjectsPaginated>(_onProjectsPaginated);
    on<ProjectsErrorOccurred>(_onErrorOccurred);
    on<ProjectsErrorCleared>(_onErrorCleared);
  }

  @override
  Future<void> close() {
    _projectsSubscription?.cancel();
    return super.close();
  }

  /// Apply filters and sorting to projects
  List<Project> _applyFiltersAndSort(
    List<Project> projects,
    ProjectsLoaded currentState, [
    ProjectsSortConfig? sortConfig,
    ProjectsFilterConfig? filterConfig,
  ]) {
    final sort = sortConfig ?? currentState.sortConfig;
    final filter = filterConfig ?? currentState.filterConfig;

    // Apply filters
    var filteredProjects = projects.where((project) {
      if (filter.tags != null && filter.tags!.isNotEmpty) {
        if (project.tags == null ||
            !filter.tags!.any((tag) => project.tags!.contains(tag))) {
          return false;
        }
      }
      if (filter.hasChats != null && (project.hasChats != filter.hasChats)) {
        return false;
      }
      if (filter.hasArtifacts != null &&
          (project.hasArtifacts != filter.hasArtifacts)) {
        return false;
      }
      if (filter.isArchived != null &&
          (project.isArchived != filter.isArchived)) {
        return false;
      }
      if (filter.createdAfter != null &&
          project.createdAt.isBefore(filter.createdAfter!)) {
        return false;
      }
      if (filter.createdBefore != null &&
          project.createdAt.isAfter(filter.createdBefore!)) {
        return false;
      }
      return true;
    }).toList();

    // Apply sorting
    filteredProjects.sort((a, b) {
      int comparison;
      switch (sort.sortBy) {
        case 'name':
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 'created':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'updated':
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
        case 'chatCount':
          comparison = a.chatCount.compareTo(b.chatCount);
          break;
        case 'artifactCount':
          comparison = a.artifactCount.compareTo(b.artifactCount);
          break;
        default:
          comparison = a.updatedAt.compareTo(b.updatedAt);
      }
      return sort.ascending ? comparison : -comparison;
    });

    return filteredProjects;
  }

  /// Calculate statistics from projects
  ProjectsStatistics _calculateStatistics(List<Project> projects) {
    final activeProjects = projects.where((p) => !p.isArchived).length;
    final archivedProjects = projects.where((p) => p.isArchived).length;
    final projectsWithChats = projects.where((p) => p.hasChats).length;
    final projectsWithArtifacts = projects.where((p) => p.hasArtifacts).length;

    final totalChats = projects.fold<int>(0, (sum, p) => sum + p.chatCount);
    final totalArtifacts =
        projects.fold<int>(0, (sum, p) => sum + p.artifactCount);

    final projectsByTag = <String, int>{};
    for (final project in projects) {
      if (project.tags != null) {
        for (final tag in project.tags!) {
          projectsByTag[tag] = (projectsByTag[tag] ?? 0) + 1;
        }
      }
    }

    final projectsByMonth = <String, int>{}; // Simplified implementation

    final oldestProject = projects.isEmpty
        ? null
        : projects.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
    final newestProject = projects.isEmpty
        ? null
        : projects.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);

    final averageChats =
        projects.isNotEmpty ? totalChats / projects.length : 0.0;
    final averageArtifacts =
        projects.isNotEmpty ? totalArtifacts / projects.length : 0.0;

    return ProjectsStatistics(
      totalProjects: projects.length,
      activeProjects: activeProjects,
      archivedProjects: archivedProjects,
      projectsWithChats: projectsWithChats,
      projectsWithArtifacts: projectsWithArtifacts,
      totalChats: totalChats,
      totalArtifacts: totalArtifacts,
      projectsByTag: projectsByTag,
      projectsByMonth: projectsByMonth,
      oldestProjectDate: oldestProject?.createdAt,
      newestProjectDate: newestProject?.createdAt,
      averageChatsPerProject: averageChats,
      averageArtifactsPerProject: averageArtifacts,
    );
  }

  /// Perform bulk action
  Future<void> _onBulkAction(
    ProjectsBulkAction event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    emit(ProjectsBulkOperating(
      operation: event.action,
      projectIds: event.projectIds,
      progress: 0,
      total: event.projectIds.length,
    ));

    try {
      for (int i = 0; i < event.projectIds.length; i++) {
        final projectId = event.projectIds[i];

        switch (event.action) {
          case 'delete':
            await _deleteProject
                .call(DeleteProjectParams(projectId: projectId));
            break;
          case 'archive':
            add(ProjectArchived(projectId));
            break;
          case 'duplicate':
            add(ProjectDuplicated(projectId: projectId));
            break;
        }

        emit(ProjectsBulkOperating(
          operation: event.action,
          projectIds: event.projectIds,
          progress: i + 1,
          total: event.projectIds.length,
        ));
      }

      // Reload projects after bulk operation
      add(const ProjectsRefreshed());
    } catch (e) {
      emit(ProjectsError(
        message: 'Bulk operation failed',
        details: e.toString(),
        previousState: currentState,
      ));
    }
  }

  /// Clear errors
  void _onErrorCleared(
    ProjectsErrorCleared event,
    Emitter<ProjectsState> emit,
  ) {
    if (state is ProjectsError) {
      final errorState = state as ProjectsError;
      if (errorState.previousState != null) {
        emit(errorState.previousState!);
      } else {
        emit(const ProjectsInitial());
        add(const ProjectsInitialized());
      }
    }
  }

  /// Handle errors
  void _onErrorOccurred(
    ProjectsErrorOccurred event,
    Emitter<ProjectsState> emit,
  ) {
    emit(ProjectsError(
      message: event.message,
      details: event.details,
      previousState: state is ProjectsError ? null : state,
    ));
  }

  /// Clear filters
  void _onFiltersCleared(
    ProjectsFiltersCleared event,
    Emitter<ProjectsState> emit,
  ) {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    emit(currentState.copyWith(
      clearFilters: true,
      filteredProjects: _applyFiltersAndSort(
        currentState.allProjects,
        currentState,
        null,
        const ProjectsFilterConfig(),
      ),
    ));
  }

  /// Multi-select projects
  void _onMultiSelected(
    ProjectsMultiSelected event,
    Emitter<ProjectsState> emit,
  ) {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    emit(currentState.copyWith(
      selectedProjectIds: event.projectIds,
      isMultiSelectMode: event.projectIds.isNotEmpty,
    ));
  }

  /// Clear multi-selection
  void _onMultiSelectionCleared(
    ProjectsMultiSelectionCleared event,
    Emitter<ProjectsState> emit,
  ) {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    emit(currentState.copyWith(clearSelection: true));
  }

  /// Archive a project
  Future<void> _onProjectArchived(
    ProjectArchived event,
    Emitter<ProjectsState> emit,
  ) async {
    await _updateProjectArchiveStatus(event.projectId, true, emit);
  }

  /// Add artifact to project
  Future<void> _onProjectArtifactAdded(
    ProjectArtifactAdded event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    final result = await _addArtifactToProject.call(
      AddArtifactToProjectParams(
        projectId: event.projectId,
        artifact: event.artifact,
      ),
    );

    result.fold(
      (failure) => emit(ProjectsError(
        message: 'Failed to add artifact to project',
        details: failure.message,
        previousState: currentState,
      )),
      (_) {
        // Reload artifacts if this project is selected
        if (currentState.selectedProject?.id == event.projectId) {
          add(ProjectArtifactsLoaded(projectId: event.projectId));
        }
      },
    );
  }

  /// Remove artifact from project
  Future<void> _onProjectArtifactRemoved(
    ProjectArtifactRemoved event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    final result = await _removeArtifactFromProject.call(
      RemoveArtifactFromProjectParams(
        projectId: event.projectId,
        artifactId: event.artifactId,
      ),
    );

    result.fold(
      (failure) => emit(ProjectsError(
        message: 'Failed to remove artifact from project',
        details: failure.message,
        previousState: currentState,
      )),
      (_) {
        // Update selected project artifacts if this project is selected
        if (currentState.selectedProject?.id == event.projectId) {
          final updatedArtifacts = currentState.selectedProjectArtifacts
              .where((artifact) => artifact.id != event.artifactId)
              .toList();

          emit(currentState.copyWith(
              selectedProjectArtifacts: updatedArtifacts));
        }
      },
    );
  }

  /// Load project artifacts
  Future<void> _onProjectArtifactsLoaded(
    ProjectArtifactsLoaded event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    emit(ProjectsLoadingArtifacts(event.projectId));

    final result = await _getProjectArtifacts.call(
      GetProjectArtifactsParams(
        projectId: event.projectId,
        artifactType: event.artifactType,
      ),
    );

    result.fold(
      (failure) => emit(ProjectsError(
        message: 'Failed to load project artifacts',
        details: failure.message,
        previousState: currentState,
      )),
      (artifacts) => emit(currentState.copyWith(
        selectedProjectArtifacts: artifacts,
      )),
    );
  }

  /// Update project color
  Future<void> _onProjectColorUpdated(
    ProjectColorUpdated event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    final projectIndex = currentState.allProjects.indexWhere(
      (project) => project.id == event.projectId,
    );

    if (projectIndex == -1) return;

    final originalProject = currentState.allProjects[projectIndex];
    final updatedProject = originalProject.copyWith(
      color: event.color,
      updatedAt: DateTime.now(),
    );

    add(ProjectUpdated(updatedProject));
  }

  /// Create a new project
  Future<void> _onProjectCreated(
    ProjectCreated event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    emit(ProjectsCreating(name: event.name, description: event.description));

    try {
      final project = Project.create(
        id: _uuid.v4(),
        name: event.name,
        description: event.description,
        tags: event.tags,
        color: event.color,
        settings: event.settings,
      );

      final result =
          await _createProject.call(CreateProjectParams(project: project));

      result.fold(
        (failure) => emit(ProjectsError(
          message: 'Failed to create project',
          details: failure.message,
          previousState: currentState,
        )),
        (projectId) {
          final createdProject = project.copyWith(id: projectId);
          final updatedProjects = [createdProject, ...currentState.allProjects];

          emit(currentState.copyWith(
            allProjects: updatedProjects,
            filteredProjects:
                _applyFiltersAndSort(updatedProjects, currentState),
          ));
        },
      );
    } catch (e) {
      emit(ProjectsError(
        message: 'Unexpected error creating project',
        details: e.toString(),
        previousState: currentState,
      ));
    }
  }

  /// Delete a project
  Future<void> _onProjectDeleted(
    ProjectDeleted event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    final remainingProjects = currentState.allProjects
        .where((project) => project.id != event.projectId)
        .toList();

    emit(ProjectsDeleting(
      projectId: event.projectId,
      remainingProjects: remainingProjects,
      force: event.force,
    ));

    final result = await _deleteProject.call(
      DeleteProjectParams(
        projectId: event.projectId,
        force: event.force,
      ),
    );

    result.fold(
      (failure) => emit(ProjectsError(
        message: 'Failed to delete project',
        details: failure.message,
        previousState: currentState,
      )),
      (_) => emit(currentState.copyWith(
        allProjects: remainingProjects,
        filteredProjects: _applyFiltersAndSort(remainingProjects, currentState),
        clearSelectedProject:
            currentState.selectedProject?.id == event.projectId,
      )),
    );
  }

  /// Update project description
  Future<void> _onProjectDescriptionUpdated(
    ProjectDescriptionUpdated event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    final projectIndex = currentState.allProjects.indexWhere(
      (project) => project.id == event.projectId,
    );

    if (projectIndex == -1) return;

    final originalProject = currentState.allProjects[projectIndex];
    final updatedProject = originalProject.copyWith(
      description: event.description,
      updatedAt: DateTime.now(),
    );

    add(ProjectUpdated(updatedProject));
  }

  // Placeholder implementations for remaining events
  void _onProjectDuplicated(
      ProjectDuplicated event, Emitter<ProjectsState> emit) {
    // Implementation for duplicating project
  }

  /// Load a specific project
  Future<void> _onProjectLoaded(
    ProjectLoaded event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    try {
      // Find project in current list
      final project = currentState.allProjects.firstWhere(
        (p) => p.id == event.projectId,
        orElse: () => throw Exception('Project not found'),
      );

      // Load project artifacts
      add(ProjectArtifactsLoaded(projectId: event.projectId));

      emit(currentState.copyWith(selectedProject: project));
    } catch (e) {
      emit(ProjectsError(
        message: 'Failed to load project',
        details: e.toString(),
        previousState: currentState,
      ));
    }
  }

  /// Validate project name
  Future<void> _onProjectNameValidated(
    ProjectNameValidated event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    emit(ProjectsValidatingName(
      name: event.name,
      excludeProjectId: event.excludeProjectId,
    ));

    try {
      // Check if name already exists
      final existingProject = currentState.allProjects.firstWhere(
        (project) =>
            project.name.toLowerCase() == event.name.toLowerCase() &&
            project.id != event.excludeProjectId,
        orElse: () => throw Exception('Not found'),
      );

      // Name already exists
      emit(ProjectsNameValidated(
        name: event.name,
        isValid: false,
        excludeProjectId: event.excludeProjectId,
        reason: 'A project with this name already exists',
      ));

      // Update cache
      final key = '${event.name}_${event.excludeProjectId ?? ''}';
      final updatedCache =
          Map<String, bool>.from(currentState.nameValidationCache);
      updatedCache[key] = false;

      emit(currentState.copyWith(nameValidationCache: updatedCache));
    } catch (e) {
      // Name is available
      emit(ProjectsNameValidated(
        name: event.name,
        isValid: true,
        excludeProjectId: event.excludeProjectId,
      ));

      // Update cache
      final key = '${event.name}_${event.excludeProjectId ?? ''}';
      final updatedCache =
          Map<String, bool>.from(currentState.nameValidationCache);
      updatedCache[key] = true;

      emit(currentState.copyWith(nameValidationCache: updatedCache));
    }
  }

  /// Rename a project
  Future<void> _onProjectRenamed(
    ProjectRenamed event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    final projectIndex = currentState.allProjects.indexWhere(
      (project) => project.id == event.projectId,
    );

    if (projectIndex == -1) {
      emit(ProjectsError(
        message: 'Project not found',
        previousState: currentState,
      ));
      return;
    }

    final originalProject = currentState.allProjects[projectIndex];
    final updatedProject = originalProject.copyWith(
      name: event.newName,
      updatedAt: DateTime.now(),
    );

    add(ProjectUpdated(updatedProject));
  }

  /// Restore an archived project
  Future<void> _onProjectRestored(
    ProjectRestored event,
    Emitter<ProjectsState> emit,
  ) async {
    await _updateProjectArchiveStatus(event.projectId, false, emit);
  }

  /// Update project settings
  Future<void> _onProjectSettingsUpdated(
    ProjectSettingsUpdated event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    final projectIndex = currentState.allProjects.indexWhere(
      (project) => project.id == event.projectId,
    );

    if (projectIndex == -1) return;

    final originalProject = currentState.allProjects[projectIndex];
    final updatedProject = originalProject.copyWith(
      settings: event.settings,
      updatedAt: DateTime.now(),
    );

    add(ProjectUpdated(updatedProject));
  }

  void _onProjectsExported(
      ProjectsExportedEvent event, Emitter<ProjectsState> emit) {
    // Implementation for exporting projects
  }

  /// Filter projects
  void _onProjectsFiltered(
    ProjectsFiltered event,
    Emitter<ProjectsState> emit,
  ) {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;
    final newFilterConfig = currentState.filterConfig.copyWith(
      tags: event.tags,
      hasChats: event.hasChats,
      hasArtifacts: event.hasArtifacts,
      createdAfter: event.createdAfter,
      createdBefore: event.createdBefore,
    );

    emit(currentState.copyWith(
      filterConfig: newFilterConfig,
      filteredProjects: _applyFiltersAndSort(
        currentState.allProjects,
        currentState,
        null,
        newFilterConfig,
      ),
    ));
  }

  void _onProjectsImported(
      ProjectsImportedEvent event, Emitter<ProjectsState> emit) {
    // Implementation for importing projects
  }

  /// Initialize projects list
  Future<void> _onProjectsInitialized(
    ProjectsInitialized event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(const ProjectsLoading());
    add(const ProjectsLoadedEvent());
  }

  /// Load all projects
  Future<void> _onProjectsLoaded(
    ProjectsLoadedEvent
        event, // Changed from ProjectsLoaded to ProjectsLoadedEvent
    Emitter<ProjectsState> emit,
  ) async {
    try {
      final result = await _getProjects.call(
        GetProjectsParams(includeArchived: event.includeArchived),
      );

      await result.fold(
        (failure) async {
          emit(ProjectsError(
            message: 'Failed to load projects',
            details: failure.message,
          ));
        },
        (projects) async {
          emit(ProjectsLoaded(
            allProjects: projects,
            filteredProjects: projects,
          ));

          // Start listening for real-time updates
          add(const ProjectsSubscriptionStarted());
        },
      );
    } catch (e) {
      emit(ProjectsError(
        message: 'Unexpected error loading projects',
        details: e.toString(),
      ));
    }
  }

  void _onProjectsPaginated(
      ProjectsPaginated event, Emitter<ProjectsState> emit) {
    // Implementation for pagination
  }

  /// Handle received projects from subscription
  void _onProjectsReceived(
    ProjectsReceived event,
    Emitter<ProjectsState> emit,
  ) {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    emit(currentState.copyWith(
      allProjects: event.projects,
      filteredProjects: _applyFiltersAndSort(event.projects, currentState),
    ));
  }

  /// Refresh projects
  void _onProjectsRefreshed(
    ProjectsRefreshed event,
    Emitter<ProjectsState> emit,
  ) {
    add(const ProjectsLoadedEvent());
  }

  /// Search projects
  Future<void> _onProjectsSearched(
    ProjectsSearched event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    if (event.query.isEmpty) {
      emit(currentState.copyWith(clearSearch: true));
      return;
    }

    try {
      final result = await _searchProjects.call(
        SearchProjectsParams(query: event.query),
      );

      result.fold(
        (failure) => emit(ProjectsError(
          message: 'Failed to search projects',
          details: failure.message,
          previousState: currentState,
        )),
        (searchResults) => emit(currentState.copyWith(
          filteredProjects: searchResults,
          searchQuery: event.query,
        )),
      );
    } catch (e) {
      emit(ProjectsError(
        message: 'Search failed',
        details: e.toString(),
        previousState: currentState,
      ));
    }
  }

  /// Sort projects
  void _onProjectsSorted(
    ProjectsSorted event,
    Emitter<ProjectsState> emit,
  ) {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;
    final newSortConfig = ProjectsSortConfig(
      sortBy: event.sortBy,
      ascending: event.ascending,
    );

    emit(currentState.copyWith(
      sortConfig: newSortConfig,
      filteredProjects: _applyFiltersAndSort(
        currentState.allProjects,
        currentState,
        newSortConfig,
      ),
    ));
  }

  /// Update project tags
  Future<void> _onProjectTagsUpdated(
    ProjectTagsUpdated event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    final projectIndex = currentState.allProjects.indexWhere(
      (project) => project.id == event.projectId,
    );

    if (projectIndex == -1) return;

    final originalProject = currentState.allProjects[projectIndex];
    final updatedProject = originalProject.copyWith(
      tags: event.tags,
      updatedAt: DateTime.now(),
    );

    add(ProjectUpdated(updatedProject));
  }

  /// Update a project
  Future<void> _onProjectUpdated(
    ProjectUpdated event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    emit(ProjectsUpdating(event.project));

    final result =
        await _updateProject.call(UpdateProjectParams(project: event.project));

    result.fold(
      (failure) => emit(ProjectsError(
        message: 'Failed to update project',
        details: failure.message,
        previousState: currentState,
      )),
      (_) {
        final projectIndex = currentState.allProjects.indexWhere(
          (project) => project.id == event.project.id,
        );

        if (projectIndex != -1) {
          final updatedProjects = List<Project>.from(currentState.allProjects);
          updatedProjects[projectIndex] = event.project;

          emit(currentState.copyWith(
            allProjects: updatedProjects,
            filteredProjects:
                _applyFiltersAndSort(updatedProjects, currentState),
            selectedProject:
                currentState.selectedProject?.id == event.project.id
                    ? event.project
                    : currentState.selectedProject,
          ));
        }
      },
    );
  }

  /// Clear search
  void _onSearchCleared(
    ProjectsSearchCleared event,
    Emitter<ProjectsState> emit,
  ) {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    emit(currentState.copyWith(
      filteredProjects: currentState.allProjects,
      clearSearch: true,
    ));
  }

  /// Get statistics
  Future<void> _onStatisticsRequested(
    ProjectsStatisticsRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    try {
      final statistics = _calculateStatistics(currentState.allProjects);
      emit(currentState.copyWith(statistics: statistics));
    } catch (e) {
      emit(ProjectsError(
        message: 'Failed to calculate statistics',
        details: e.toString(),
        previousState: currentState,
      ));
    }
  }

  /// Start listening to real-time project updates
  void _onSubscriptionStarted(
    ProjectsSubscriptionStarted event,
    Emitter<ProjectsState> emit,
  ) {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    _projectsSubscription?.cancel();
    _projectsSubscription = _watchProjects.call(const NoParams()).listen(
      (result) {
        result.fold(
          (failure) => add(ProjectsErrorOccurred(
            'Lost connection to projects',
            details: failure.message,
          )),
          (projects) => add(ProjectsReceived(projects)),
        );
      },
    );

    emit(currentState.copyWith(isListening: true));
  }

  /// Stop listening to real-time updates
  void _onSubscriptionStopped(
    ProjectsSubscriptionStopped event,
    Emitter<ProjectsState> emit,
  ) {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    _projectsSubscription?.cancel();
    _projectsSubscription = null;

    emit(currentState.copyWith(isListening: false));
  }

  /// Helper method to update project archive status
  Future<void> _updateProjectArchiveStatus(
    String projectId,
    bool archived,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;

    final projectIndex = currentState.allProjects.indexWhere(
      (project) => project.id == projectId,
    );

    if (projectIndex == -1) return;

    final originalProject = currentState.allProjects[projectIndex];
    final updatedProject = originalProject.copyWith(
      isArchived: archived,
      updatedAt: DateTime.now(),
    );

    final result =
        await _updateProject.call(UpdateProjectParams(project: updatedProject));

    result.fold(
      (failure) => emit(ProjectsError(
        message: 'Failed to ${archived ? 'archive' : 'restore'} project',
        details: failure.message,
        previousState: currentState,
      )),
      (_) {
        final updatedProjects = List<Project>.from(currentState.allProjects);
        updatedProjects[projectIndex] = updatedProject;

        emit(currentState.copyWith(
          allProjects: updatedProjects,
          filteredProjects: _applyFiltersAndSort(updatedProjects, currentState),
        ));
      },
    );
  }
}
