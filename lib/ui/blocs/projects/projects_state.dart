import 'package:equatable/equatable.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';

/// Base class for all projects states
abstract class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when projects list is first created
class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

/// State when projects are being loaded
class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

/// State when projects are loaded and ready
class ProjectsLoaded extends ProjectsState {
  final List<Project> allProjects;
  final List<Project> filteredProjects;
  final Project? selectedProject;
  final List<Artifact> selectedProjectArtifacts;
  final String? searchQuery;
  final bool isListening;
  final ProjectsSortConfig sortConfig;
  final ProjectsFilterConfig filterConfig;
  final List<String> selectedProjectIds;
  final bool isMultiSelectMode;
  final ProjectsStatistics? statistics;
  final bool hasMoreProjects;
  final int currentPage;
  final Map<String, bool> nameValidationCache;

  const ProjectsLoaded({
    required this.allProjects,
    required this.filteredProjects,
    this.selectedProject,
    this.selectedProjectArtifacts = const [],
    this.searchQuery,
    this.isListening = false,
    this.sortConfig = const ProjectsSortConfig(),
    this.filterConfig = const ProjectsFilterConfig(),
    this.selectedProjectIds = const [],
    this.isMultiSelectMode = false,
    this.statistics,
    this.hasMoreProjects = false,
    this.currentPage = 0,
    this.nameValidationCache = const {},
  });

  @override
  List<Object?> get props => [
        allProjects,
        filteredProjects,
        selectedProject,
        selectedProjectArtifacts,
        searchQuery,
        isListening,
        sortConfig,
        filterConfig,
        selectedProjectIds,
        isMultiSelectMode,
        statistics,
        hasMoreProjects,
        currentPage,
        nameValidationCache,
      ];

  /// Get the total number of projects
  int get totalProjects => allProjects.length;

  /// Check if there are any projects
  bool get hasProjects => allProjects.isNotEmpty;

  /// Check if there are filtered projects to display
  bool get hasFilteredProjects => filteredProjects.isNotEmpty;

  /// Check if search is active
  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;

  /// Check if filters are active
  bool get hasActiveFilters => filterConfig.hasActiveFilters;

  /// Get the effective projects to display (considering search and filters)
  List<Project> get displayProjects {
    if (isSearching) {
      return filteredProjects
          .where((project) =>
              project.name.toLowerCase().contains(searchQuery!.toLowerCase()) ||
              (project.description?.toLowerCase().contains(searchQuery!.toLowerCase()) ?? false))
          .toList();
    }
    return filteredProjects;
  }

  /// Get selected projects
  List<Project> get selectedProjects {
    return allProjects.where((project) => selectedProjectIds.contains(project.id)).toList();
  }

  /// Check if a project is selected
  bool isProjectSelected(String projectId) => selectedProjectIds.contains(projectId);

  /// Check if all displayed projects are selected
  bool get areAllDisplayedProjectsSelected {
    if (displayProjects.isEmpty) return false;
    return displayProjects.every((project) => selectedProjectIds.contains(project.id));
  }

  /// Get archived projects
  List<Project> get archivedProjects {
    return allProjects.where((project) => project.isArchived).toList();
  }

  /// Get active (non-archived) projects
  List<Project> get activeProjects {
    return allProjects.where((project) => !project.isArchived).toList();
  }

  /// Get projects with chats
  List<Project> get projectsWithChats {
    return allProjects.where((project) => project.hasChats).toList();
  }

  /// Get projects with artifacts
  List<Project> get projectsWithArtifacts {
    return allProjects.where((project) => project.hasArtifacts).toList();
  }

  /// Get all unique tags from all projects
  List<String> get allTags {
    final tags = <String>{};
    for (final project in allProjects) {
      if (project.tags != null) {
        tags.addAll(project.tags!);
      }
    }
    return tags.toList()..sort();
  }

  /// Check if a project name is valid (cached result)
  bool? isProjectNameValid(String name, [String? excludeProjectId]) {
    final key = '${name}_${excludeProjectId ?? ''}';
    return nameValidationCache[key];
  }

  ProjectsLoaded copyWith({
    List<Project>? allProjects,
    List<Project>? filteredProjects,
    Project? selectedProject,
    List<Artifact>? selectedProjectArtifacts,
    String? searchQuery,
    bool? isListening,
    ProjectsSortConfig? sortConfig,
    ProjectsFilterConfig? filterConfig,
    List<String>? selectedProjectIds,
    bool? isMultiSelectMode,
    ProjectsStatistics? statistics,
    bool? hasMoreProjects,
    int? currentPage,
    Map<String, bool>? nameValidationCache,
    bool clearSearch = false,
    bool clearFilters = false,
    bool clearSelection = false,
    bool clearSelectedProject = false,
  }) {
    return ProjectsLoaded(
      allProjects: allProjects ?? this.allProjects,
      filteredProjects: filteredProjects ?? this.filteredProjects,
      selectedProject: clearSelectedProject ? null : (selectedProject ?? this.selectedProject),
      selectedProjectArtifacts: clearSelectedProject ? [] : (selectedProjectArtifacts ?? this.selectedProjectArtifacts),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      isListening: isListening ?? this.isListening,
      sortConfig: sortConfig ?? this.sortConfig,
      filterConfig: clearFilters ? const ProjectsFilterConfig() : (filterConfig ?? this.filterConfig),
      selectedProjectIds: clearSelection ? [] : (selectedProjectIds ?? this.selectedProjectIds),
      isMultiSelectMode: clearSelection ? false : (isMultiSelectMode ?? this.isMultiSelectMode),
      statistics: statistics ?? this.statistics,
      hasMoreProjects: hasMoreProjects ?? this.hasMoreProjects,
      currentPage: currentPage ?? this.currentPage,
      nameValidationCache: nameValidationCache ?? this.nameValidationCache,
    );
  }
}

/// State when creating a new project
class ProjectsCreating extends ProjectsState {
  final String name;
  final String? description;

  const ProjectsCreating({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

/// State when deleting a project
class ProjectsDeleting extends ProjectsState {
  final String projectId;
  final List<Project> remainingProjects;
  final bool force;

  const ProjectsDeleting({
    required this.projectId,
    required this.remainingProjects,
    this.force = false,
  });

  @override
  List<Object?> get props => [projectId, remainingProjects, force];
}

/// State when updating a project
class ProjectsUpdating extends ProjectsState {
  final Project project;

  const ProjectsUpdating(this.project);

  @override
  List<Object?> get props => [project];
}

/// State when loading project artifacts
class ProjectsLoadingArtifacts extends ProjectsState {
  final String projectId;

  const ProjectsLoadingArtifacts(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// State when validating project name
class ProjectsValidatingName extends ProjectsState {
  final String name;
  final String? excludeProjectId;

  const ProjectsValidatingName({
    required this.name,
    this.excludeProjectId,
  });

  @override
  List<Object?> get props => [name, excludeProjectId];
}

/// State when name validation is complete
class ProjectsNameValidated extends ProjectsState {
  final String name;
  final bool isValid;
  final String? excludeProjectId;
  final String? reason;

  const ProjectsNameValidated({
    required this.name,
    required this.isValid,
    this.excludeProjectId,
    this.reason,
  });

  @override
  List<Object?> get props => [name, isValid, excludeProjectId, reason];
}

/// State when performing bulk operations
class ProjectsBulkOperating extends ProjectsState {
  final String operation;
  final List<String> projectIds;
  final int progress;
  final int total;

  const ProjectsBulkOperating({
    required this.operation,
    required this.projectIds,
    required this.progress,
    required this.total,
  });

  @override
  List<Object?> get props => [operation, projectIds, progress, total];

  /// Get progress percentage
  double get progressPercentage => total > 0 ? progress / total : 0.0;

  /// Check if operation is complete
  bool get isComplete => progress >= total;
}

/// State when exporting projects
class ProjectsExporting extends ProjectsState {
  final List<String> projectIds;
  final String format;
  final bool includeChats;
  final bool includeArtifacts;
  final int progress;
  final int total;

  const ProjectsExporting({
    required this.projectIds,
    required this.format,
    required this.includeChats,
    required this.includeArtifacts,
    required this.progress,
    required this.total,
  });

  @override
  List<Object?> get props => [projectIds, format, includeChats, includeArtifacts, progress, total];

  /// Get progress percentage
  double get progressPercentage => total > 0 ? progress / total : 0.0;
}

/// State when importing projects
class ProjectsImporting extends ProjectsState {
  final String filePath;
  final String format;
  final int progress;
  final int total;

  const ProjectsImporting({
    required this.filePath,
    required this.format,
    required this.progress,
    required this.total,
  });

  @override
  List<Object?> get props => [filePath, format, progress, total];

  /// Get progress percentage
  double get progressPercentage => total > 0 ? progress / total : 0.0;
}

/// State when an error occurs
class ProjectsError extends ProjectsState {
  final String message;
  final String? details;
  final ProjectsState? previousState;
  final String? errorCode;

  const ProjectsError({
    required this.message,
    this.details,
    this.previousState,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, details, previousState, errorCode];

  /// Check if this is a network error
  bool get isNetworkError =>
      errorCode == 'network' ||
      message.toLowerCase().contains('network') ||
      message.toLowerCase().contains('connection');

  /// Check if this is a validation error
  bool get isValidationError =>
      errorCode == 'validation' ||
      message.toLowerCase().contains('validation') ||
      message.toLowerCase().contains('invalid') ||
      message.toLowerCase().contains('already exists');

  /// Check if this is a storage error
  bool get isStorageError =>
      errorCode == 'storage' ||
      message.toLowerCase().contains('storage') ||
      message.toLowerCase().contains('database');

  /// Check if the error is recoverable
  bool get isRecoverable => isNetworkError;
}

/// State when export is complete
class ProjectsExported extends ProjectsState {
  final List<String> projectIds;
  final String format;
  final String exportPath;
  final int exportedCount;

  const ProjectsExported({
    required this.projectIds,
    required this.format,
    required this.exportPath,
    required this.exportedCount,
  });

  @override
  List<Object?> get props => [projectIds, format, exportPath, exportedCount];
}

/// State when import is complete
class ProjectsImported extends ProjectsState {
  final String filePath;
  final String format;
  final int importedCount;
  final List<String> importedProjectIds;

  const ProjectsImported({
    required this.filePath,
    required this.format,
    required this.importedCount,
    required this.importedProjectIds,
  });

  @override
  List<Object?> get props => [filePath, format, importedCount, importedProjectIds];
}

/// Configuration for sorting projects
class ProjectsSortConfig extends Equatable {
  final String sortBy; // 'name', 'created', 'updated', 'chatCount', 'artifactCount'
  final bool ascending;

  const ProjectsSortConfig({
    this.sortBy = 'updated',
    this.ascending = false, // Default to newest first
  });

  @override
  List<Object?> get props => [sortBy, ascending];

  ProjectsSortConfig copyWith({
    String? sortBy,
    bool? ascending,
  }) {
    return ProjectsSortConfig(
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

/// Configuration for filtering projects
class ProjectsFilterConfig extends Equatable {
  final List<String>? tags;
  final bool? hasChats;
  final bool? hasArtifacts;
  final bool? isArchived;
  final DateTime? createdAfter;
  final DateTime? createdBefore;

  const ProjectsFilterConfig({
    this.tags,
    this.hasChats,
    this.hasArtifacts,
    this.isArchived,
    this.createdAfter,
    this.createdBefore,
  });

  @override
  List<Object?> get props => [
        tags,
        hasChats,
        hasArtifacts,
        isArchived,
        createdAfter,
        createdBefore,
      ];

  /// Check if any filters are active
  bool get hasActiveFilters =>
      (tags != null && tags!.isNotEmpty) ||
      hasChats != null ||
      hasArtifacts != null ||
      isArchived != null ||
      createdAfter != null ||
      createdBefore != null;

  ProjectsFilterConfig copyWith({
    List<String>? tags,
    bool? hasChats,
    bool? hasArtifacts,
    bool? isArchived,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool clearTags = false,
    bool clearDates = false,
  }) {
    return ProjectsFilterConfig(
      tags: clearTags ? null : (tags ?? this.tags),
      hasChats: hasChats ?? this.hasChats,
      hasArtifacts: hasArtifacts ?? this.hasArtifacts,
      isArchived: isArchived ?? this.isArchived,
      createdAfter: clearDates ? null : (createdAfter ?? this.createdAfter),
      createdBefore: clearDates ? null : (createdBefore ?? this.createdBefore),
    );
  }
}

/// Statistics about projects
class ProjectsStatistics extends Equatable {
  final int totalProjects;
  final int activeProjects;
  final int archivedProjects;
  final int projectsWithChats;
  final int projectsWithArtifacts;
  final int totalChats;
  final int totalArtifacts;
  final Map<String, int> projectsByTag;
  final Map<String, int> projectsByMonth;
  final DateTime? oldestProjectDate;
  final DateTime? newestProjectDate;
  final double averageChatsPerProject;
  final double averageArtifactsPerProject;

  const ProjectsStatistics({
    required this.totalProjects,
    required this.activeProjects,
    required this.archivedProjects,
    required this.projectsWithChats,
    required this.projectsWithArtifacts,
    required this.totalChats,
    required this.totalArtifacts,
    required this.projectsByTag,
    required this.projectsByMonth,
    this.oldestProjectDate,
    this.newestProjectDate,
    required this.averageChatsPerProject,
    required this.averageArtifactsPerProject,
  });

  @override
  List<Object?> get props => [
        totalProjects,
        activeProjects,
        archivedProjects,
        projectsWithChats,
        projectsWithArtifacts,
        totalChats,
        totalArtifacts,
        projectsByTag,
        projectsByMonth,
        oldestProjectDate,
        newestProjectDate,
        averageChatsPerProject,
        averageArtifactsPerProject,
      ];
}