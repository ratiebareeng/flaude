import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

/// Event to archive a project
class ProjectArchived extends ProjectsEvent {
  final String projectId;

  const ProjectArchived(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Event to add an artifact to a project
class ProjectArtifactAdded extends ProjectsEvent {
  final String projectId;
  final Artifact artifact;

  const ProjectArtifactAdded({
    required this.projectId,
    required this.artifact,
  });

  @override
  List<Object?> get props => [projectId, artifact];
}

/// Event to remove an artifact from a project
class ProjectArtifactRemoved extends ProjectsEvent {
  final String projectId;
  final String artifactId;

  const ProjectArtifactRemoved({
    required this.projectId,
    required this.artifactId,
  });

  @override
  List<Object?> get props => [projectId, artifactId];
}

/// Event to load project artifacts
class ProjectArtifactsLoaded extends ProjectsEvent {
  final String projectId;
  final String? artifactType;

  const ProjectArtifactsLoaded({
    required this.projectId,
    this.artifactType,
  });

  @override
  List<Object?> get props => [projectId, artifactType];
}

/// Event to update project color
class ProjectColorUpdated extends ProjectsEvent {
  final String projectId;
  final String? color;

  const ProjectColorUpdated({
    required this.projectId,
    this.color,
  });

  @override
  List<Object?> get props => [projectId, color];
}

/// Event to create a new project
class ProjectCreated extends ProjectsEvent {
  final String name;
  final String? description;
  final List<String>? tags;
  final String? color;
  final ProjectSettings? settings;

  const ProjectCreated({
    required this.name,
    this.description,
    this.tags,
    this.color,
    this.settings,
  });

  @override
  List<Object?> get props => [name, description, tags, color, settings];
}

/// Event to delete a project
class ProjectDeleted extends ProjectsEvent {
  final String projectId;
  final bool force;

  const ProjectDeleted({
    required this.projectId,
    this.force = false,
  });

  @override
  List<Object?> get props => [projectId, force];
}

/// Event to update project description
class ProjectDescriptionUpdated extends ProjectsEvent {
  final String projectId;
  final String? description;

  const ProjectDescriptionUpdated({
    required this.projectId,
    this.description,
  });

  @override
  List<Object?> get props => [projectId, description];
}

/// Event to duplicate a project
class ProjectDuplicated extends ProjectsEvent {
  final String projectId;
  final String? newName;

  const ProjectDuplicated({
    required this.projectId,
    this.newName,
  });

  @override
  List<Object?> get props => [projectId, newName];
}

/// Event to load a specific project
class ProjectLoaded extends ProjectsEvent {
  final String projectId;

  const ProjectLoaded(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Event to validate project name uniqueness
class ProjectNameValidated extends ProjectsEvent {
  final String name;
  final String? excludeProjectId;

  const ProjectNameValidated({
    required this.name,
    this.excludeProjectId,
  });

  @override
  List<Object?> get props => [name, excludeProjectId];
}

/// Event to rename a project
class ProjectRenamed extends ProjectsEvent {
  final String projectId;
  final String newName;

  const ProjectRenamed({
    required this.projectId,
    required this.newName,
  });

  @override
  List<Object?> get props => [projectId, newName];
}

/// Event to restore an archived project
class ProjectRestored extends ProjectsEvent {
  final String projectId;

  const ProjectRestored(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Event to perform bulk action on selected projects
class ProjectsBulkAction extends ProjectsEvent {
  final String action; // 'delete', 'archive', 'export', 'duplicate'
  final List<String> projectIds;

  const ProjectsBulkAction({
    required this.action,
    required this.projectIds,
  });

  @override
  List<Object?> get props => [action, projectIds];
}

/// Event to clear errors
class ProjectsErrorCleared extends ProjectsEvent {
  const ProjectsErrorCleared();
}

/// Event to handle errors
class ProjectsErrorOccurred extends ProjectsEvent {
  final String message;
  final String? details;

  const ProjectsErrorOccurred(this.message, {this.details});

  @override
  List<Object?> get props => [message, details];
}

/// Event to update project settings
class ProjectSettingsUpdated extends ProjectsEvent {
  final String projectId;
  final ProjectSettings settings;

  const ProjectSettingsUpdated({
    required this.projectId,
    required this.settings,
  });

  @override
  List<Object?> get props => [projectId, settings];
}

/// Base class for all projects events
abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to export projects
class ProjectsExportedEvent extends ProjectsEvent {
  final List<String> projectIds;
  final String format; // 'json', 'zip'
  final bool includeChats;
  final bool includeArtifacts;

  const ProjectsExportedEvent({
    required this.projectIds,
    required this.format,
    this.includeChats = true,
    this.includeArtifacts = true,
  });

  @override
  List<Object?> get props =>
      [projectIds, format, includeChats, includeArtifacts];
}

/// Event to filter projects
class ProjectsFiltered extends ProjectsEvent {
  final List<String>? tags;
  final bool? hasChats;
  final bool? hasArtifacts;
  final DateTime? createdAfter;
  final DateTime? createdBefore;

  const ProjectsFiltered({
    this.tags,
    this.hasChats,
    this.hasArtifacts,
    this.createdAfter,
    this.createdBefore,
  });

  @override
  List<Object?> get props =>
      [tags, hasChats, hasArtifacts, createdAfter, createdBefore];
}

/// Event to clear filters
class ProjectsFiltersCleared extends ProjectsEvent {
  const ProjectsFiltersCleared();
}

/// Event to import projects
class ProjectsImportedEvent extends ProjectsEvent {
  final String filePath;
  final String format;

  const ProjectsImportedEvent({
    required this.filePath,
    required this.format,
  });

  @override
  List<Object?> get props => [filePath, format];
}

/// Event to initialize the projects list
class ProjectsInitialized extends ProjectsEvent {
  const ProjectsInitialized();
}

/// Event to load all projects
class ProjectsLoadedEvent extends ProjectsEvent {
  final bool includeArchived;

  const ProjectsLoadedEvent({this.includeArchived = false});

  @override
  List<Object?> get props => [includeArchived];
}

/// Event to select multiple projects
class ProjectsMultiSelected extends ProjectsEvent {
  final List<String> projectIds;

  const ProjectsMultiSelected(this.projectIds);

  @override
  List<Object?> get props => [projectIds];
}

/// Event to clear multiple selection
class ProjectsMultiSelectionCleared extends ProjectsEvent {
  const ProjectsMultiSelectionCleared();
}

/// Event to paginate projects (load more)
class ProjectsPaginated extends ProjectsEvent {
  final int limit;
  final int offset;

  const ProjectsPaginated({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [limit, offset];
}

/// Event when projects are received from subscription
class ProjectsReceived extends ProjectsEvent {
  final List<Project> projects;

  const ProjectsReceived(this.projects);

  @override
  List<Object?> get props => [projects];
}

/// Event to refresh projects list
class ProjectsRefreshed extends ProjectsEvent {
  const ProjectsRefreshed();
}

/// Event to clear search
class ProjectsSearchCleared extends ProjectsEvent {
  const ProjectsSearchCleared();
}

/// Event to search projects
class ProjectsSearched extends ProjectsEvent {
  final String query;

  const ProjectsSearched(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to sort projects
class ProjectsSorted extends ProjectsEvent {
  final String
      sortBy; // 'name', 'created', 'updated', 'chatCount', 'artifactCount'
  final bool ascending;

  const ProjectsSorted({
    required this.sortBy,
    this.ascending = true,
  });

  @override
  List<Object?> get props => [sortBy, ascending];
}

/// Event to get project statistics
class ProjectsStatisticsRequested extends ProjectsEvent {
  const ProjectsStatisticsRequested();
}

/// Event to start listening to real-time project updates
class ProjectsSubscriptionStarted extends ProjectsEvent {
  const ProjectsSubscriptionStarted();
}

/// Event to stop listening to real-time updates
class ProjectsSubscriptionStopped extends ProjectsEvent {
  const ProjectsSubscriptionStopped();
}

/// Event to update project tags
class ProjectTagsUpdated extends ProjectsEvent {
  final String projectId;
  final List<String> tags;

  const ProjectTagsUpdated({
    required this.projectId,
    required this.tags,
  });

  @override
  List<Object?> get props => [projectId, tags];
}

/// Event to update a project
class ProjectUpdated extends ProjectsEvent {
  final Project project;

  const ProjectUpdated(this.project);

  @override
  List<Object?> get props => [project];
}
