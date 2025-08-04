import 'package:equatable/equatable.dart';

import 'artifact.dart';

/// AI Response domain entity representing a response from an AI model
class AIResponse extends Equatable {
  /// Unique identifier for the response
  final String id;

  /// The generated content/text
  final String content;

  /// Model that generated this response
  final String model;

  /// Reason why the response finished (e.g., 'stop', 'length', 'timeout')
  final String finishReason;

  /// Token usage information for this response
  final AIUsage usage;

  /// Additional metadata about the response
  final Map<String, dynamic>? metadata;

  /// List of artifacts generated with this response
  final List<Artifact>? artifacts;

  /// Response generation time in milliseconds
  final int? generationTimeMs;

  /// Whether the response was streamed
  final bool wasStreamed;

  /// Quality score or confidence (if available)
  final double? qualityScore;

  /// Safety information about the response
  final AIResponseSafety? safety;

  const AIResponse({
    required this.id,
    required this.content,
    required this.model,
    required this.finishReason,
    required this.usage,
    this.metadata,
    this.artifacts,
    this.generationTimeMs,
    this.wasStreamed = false,
    this.qualityScore,
    this.safety,
  });

  /// Factory constructor for creating a successful response
  factory AIResponse.success({
    required String id,
    required String content,
    required String model,
    required AIUsage usage,
    List<Artifact>? artifacts,
    int? generationTimeMs,
    bool wasStreamed = false,
    Map<String, dynamic>? metadata,
  }) {
    return AIResponse(
      id: id,
      content: content,
      model: model,
      finishReason: 'stop',
      usage: usage,
      artifacts: artifacts,
      generationTimeMs: generationTimeMs,
      wasStreamed: wasStreamed,
      metadata: metadata,
    );
  }

  /// Factory constructor for creating a truncated response
  factory AIResponse.truncated({
    required String id,
    required String content,
    required String model,
    required AIUsage usage,
    List<Artifact>? artifacts,
    int? generationTimeMs,
    bool wasStreamed = false,
    Map<String, dynamic>? metadata,
  }) {
    return AIResponse(
      id: id,
      content: content,
      model: model,
      finishReason: 'length',
      usage: usage,
      artifacts: artifacts,
      generationTimeMs: generationTimeMs,
      wasStreamed: wasStreamed,
      metadata: metadata,
    );
  }

  /// Get the content length in characters
  int get contentLength => content.length;

  /// Get cost estimation if available in metadata
  double? get estimatedCost => metadata?['estimated_cost'] as double?;

  /// Get the estimated reading time in minutes
  int get estimatedReadingTimeMinutes => (contentLength / 250).ceil();

  /// Check if the response has artifacts
  bool get hasArtifacts => artifacts != null && artifacts!.isNotEmpty;

  /// Check if the response has safety concerns
  bool get hasSafetyConcerns => safety?.hasConcerns == true;

  /// Check if the response completed successfully
  bool get isComplete => finishReason == 'stop' || finishReason == 'end_turn';

  @override
  List<Object?> get props => [
        id,
        content,
        model,
        finishReason,
        usage,
        metadata,
        artifacts,
        generationTimeMs,
        wasStreamed,
        qualityScore,
        safety,
      ];

  /// Get generation speed in tokens per second
  double? get tokensPerSecond {
    if (generationTimeMs == null || usage.outputTokens == 0) return null;
    return (usage.outputTokens * 1000.0) / generationTimeMs!;
  }

  /// Check if the response was truncated due to length limits
  bool get wasTruncated =>
      finishReason == 'length' || finishReason == 'max_tokens';

  /// Create a copy of this response with updated fields
  AIResponse copyWith({
    String? id,
    String? content,
    String? model,
    String? finishReason,
    AIUsage? usage,
    Map<String, dynamic>? metadata,
    List<Artifact>? artifacts,
    int? generationTimeMs,
    bool? wasStreamed,
    double? qualityScore,
    AIResponseSafety? safety,
  }) {
    return AIResponse(
      id: id ?? this.id,
      content: content ?? this.content,
      model: model ?? this.model,
      finishReason: finishReason ?? this.finishReason,
      usage: usage ?? this.usage,
      metadata: metadata ?? this.metadata,
      artifacts: artifacts ?? this.artifacts,
      generationTimeMs: generationTimeMs ?? this.generationTimeMs,
      wasStreamed: wasStreamed ?? this.wasStreamed,
      qualityScore: qualityScore ?? this.qualityScore,
      safety: safety ?? this.safety,
    );
  }

  @override
  String toString() {
    return 'AIResponse(id: $id, model: $model, contentLength: $contentLength, '
        'finishReason: $finishReason, inputTokens: ${usage.inputTokens}, '
        'outputTokens: ${usage.outputTokens})';
  }
}

/// AI Response safety information
class AIResponseSafety extends Equatable {
  /// Whether the response has any safety concerns
  final bool hasConcerns;

  /// List of safety categories flagged
  final List<String> flaggedCategories;

  /// Confidence scores for safety categories (0.0 to 1.0)
  final Map<String, double> confidenceScores;

  /// Whether the response was filtered/modified for safety
  final bool wasFiltered;

  /// Additional safety metadata
  final Map<String, dynamic>? metadata;

  const AIResponseSafety({
    required this.hasConcerns,
    this.flaggedCategories = const [],
    this.confidenceScores = const {},
    this.wasFiltered = false,
    this.metadata,
  });

  /// Factory constructor for safe response
  factory AIResponseSafety.safe() {
    return const AIResponseSafety(hasConcerns: false);
  }

  /// Factory constructor for unsafe response
  factory AIResponseSafety.unsafe({
    required List<String> flaggedCategories,
    Map<String, double>? confidenceScores,
    bool wasFiltered = false,
    Map<String, dynamic>? metadata,
  }) {
    return AIResponseSafety(
      hasConcerns: true,
      flaggedCategories: flaggedCategories,
      confidenceScores: confidenceScores ?? {},
      wasFiltered: wasFiltered,
      metadata: metadata,
    );
  }

  /// Get the highest confidence score among flagged categories
  double? get highestConfidenceScore {
    if (confidenceScores.isEmpty) return null;
    return confidenceScores.values.reduce((a, b) => a > b ? a : b);
  }

  @override
  List<Object?> get props => [
        hasConcerns,
        flaggedCategories,
        confidenceScores,
        wasFiltered,
        metadata,
      ];

  /// Create a copy with updated fields
  AIResponseSafety copyWith({
    bool? hasConcerns,
    List<String>? flaggedCategories,
    Map<String, double>? confidenceScores,
    bool? wasFiltered,
    Map<String, dynamic>? metadata,
  }) {
    return AIResponseSafety(
      hasConcerns: hasConcerns ?? this.hasConcerns,
      flaggedCategories: flaggedCategories ?? this.flaggedCategories,
      confidenceScores: confidenceScores ?? this.confidenceScores,
      wasFiltered: wasFiltered ?? this.wasFiltered,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if a specific category is flagged
  bool isCategoryFlagged(String category) =>
      flaggedCategories.contains(category);

  @override
  String toString() {
    return 'AIResponseSafety(hasConcerns: $hasConcerns, '
        'flaggedCategories: $flaggedCategories, wasFiltered: $wasFiltered)';
  }
}

/// AI Usage domain entity representing token usage information
class AIUsage extends Equatable {
  /// Number of input tokens used
  final int inputTokens;

  /// Number of output tokens generated
  final int outputTokens;

  /// Total tokens used (input + output)
  final int totalTokens;

  /// Additional usage metrics
  final Map<String, dynamic>? additionalMetrics;

  const AIUsage({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    this.additionalMetrics,
  });

  /// Factory constructor for creating usage from individual counts
  factory AIUsage.fromCounts({
    required int inputTokens,
    required int outputTokens,
    Map<String, dynamic>? additionalMetrics,
  }) {
    return AIUsage(
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      totalTokens: inputTokens + outputTokens,
      additionalMetrics: additionalMetrics,
    );
  }

  /// Calculate the percentage of input tokens
  double get inputTokensPercentage =>
      totalTokens > 0 ? (inputTokens / totalTokens) * 100 : 0;

  /// Check if the total tokens match input + output
  bool get isConsistent => totalTokens == inputTokens + outputTokens;

  /// Calculate the percentage of output tokens
  double get outputTokensPercentage =>
      totalTokens > 0 ? (outputTokens / totalTokens) * 100 : 0;

  @override
  List<Object?> get props => [
        inputTokens,
        outputTokens,
        totalTokens,
        additionalMetrics,
      ];

  /// Create a copy with updated fields
  AIUsage copyWith({
    int? inputTokens,
    int? outputTokens,
    int? totalTokens,
    Map<String, dynamic>? additionalMetrics,
  }) {
    return AIUsage(
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      totalTokens: totalTokens ?? this.totalTokens,
      additionalMetrics: additionalMetrics ?? this.additionalMetrics,
    );
  }

  @override
  String toString() {
    return 'AIUsage(input: $inputTokens, output: $outputTokens, total: $totalTokens)';
  }
}
