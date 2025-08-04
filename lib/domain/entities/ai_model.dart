import 'package:equatable/equatable.dart';

/// AI Model domain entity representing an available AI model
class AIModel extends Equatable {
  /// Unique identifier for the model (e.g., 'claude-sonnet-4-20250514')
  final String id;
  
  /// Human-readable name of the model
  final String name;
  
  /// Provider of the model (e.g., 'Anthropic', 'OpenAI')
  final String provider;
  
  /// Maximum number of tokens the model can handle
  final int maxTokens;
  
  /// List of capabilities this model supports
  final List<String> capabilities;
  
  /// Model version information
  final String? version;
  
  /// Description of the model
  final String? description;
  
  /// Whether the model is currently available
  final bool isAvailable;
  
  /// Cost per input token (in cents or smallest currency unit)
  final double? inputTokenCost;
  
  /// Cost per output token (in cents or smallest currency unit)
  final double? outputTokenCost;
  
  /// Model parameters and configuration
  final AIModelConfig? config;
  
  /// Additional metadata about the model
  final Map<String, dynamic>? metadata;

  const AIModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.maxTokens,
    required this.capabilities,
    this.version,
    this.description,
    this.isAvailable = true,
    this.inputTokenCost,
    this.outputTokenCost,
    this.config,
    this.metadata,
  });

  /// Create a copy of this model with updated fields
  AIModel copyWith({
    String? id,
    String? name,
    String? provider,
    int? maxTokens,
    List<String>? capabilities,
    String? version,
    String? description,
    bool? isAvailable,
    double? inputTokenCost,
    double? outputTokenCost,
    AIModelConfig? config,
    Map<String, dynamic>? metadata,
  }) {
    return AIModel(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      maxTokens: maxTokens ?? this.maxTokens,
      capabilities: capabilities ?? this.capabilities,
      version: version ?? this.version,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      inputTokenCost: inputTokenCost ?? this.inputTokenCost,
      outputTokenCost: outputTokenCost ?? this.outputTokenCost,
      config: config ?? this.config,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if model supports a specific capability
  bool supportsCapability(String capability) => capabilities.contains(capability);
  
  /// Check if model supports text generation
  bool get supportsTextGeneration => supportsCapability('text_generation');
  
  /// Check if model supports conversation
  bool get supportsConversation => supportsCapability('conversation');
  
  /// Check if model supports code generation
  bool get supportsCodeGeneration => supportsCapability('code_generation');
  
  /// Check if model supports image understanding
  bool get supportsImageUnderstanding => supportsCapability('image_understanding');
  
  /// Check if model supports function calling
  bool get supportsFunctionCalling => supportsCapability('function_calling');
  
  /// Check if model supports artifacts
  bool get supportsArtifacts => supportsCapability('artifacts');
  
  /// Get model type based on capabilities and name
  AIModelType get modelType {
    if (name.toLowerCase().contains('opus')) return AIModelType.opus;
    if (name.toLowerCase().contains('sonnet')) return AIModelType.sonnet;
    if (name.toLowerCase().contains('haiku')) return AIModelType.haiku;
    if (provider.toLowerCase().contains('openai')) return AIModelType.gpt;
    return AIModelType.other;
  }
  
  /// Get display name with version
  String get displayNameWithVersion => 
      version != null ? '$name (v$version)' : name;
  
  /// Calculate estimated cost for token usage
  double? calculateCost({
    required int inputTokens,
    required int outputTokens,
  }) {
    if (inputTokenCost == null || outputTokenCost == null) return null;
    
    return (inputTokens * inputTokenCost!) + (outputTokens * outputTokenCost!);
  }

  /// Factory constructor for Claude models
  factory AIModel.claude({
    required String id,
    required String name,
    int? maxTokens,
    String? version,
    String? description,
    List<String>? additionalCapabilities,
    double? inputTokenCost,
    double? outputTokenCost,
    AIModelConfig? config,
  }) {
    final baseCapabilities = [
      'text_generation',
      'conversation',
      'reasoning',
      'analysis',
      'artifacts',
    ];
    
    final allCapabilities = [
      ...baseCapabilities,
      ...?additionalCapabilities,
    ];
    
    return AIModel(
      id: id,
      name: name,
      provider: 'Anthropic',
      maxTokens: maxTokens ?? 200000,
      capabilities: allCapabilities,
      version: version,
      description: description,
      inputTokenCost: inputTokenCost,
      outputTokenCost: outputTokenCost,
      config: config,
    );
  }

  /// Factory constructor for OpenAI models
  factory AIModel.openAI({
    required String id,
    required String name,
    int? maxTokens,
    String? version,
    String? description,
    List<String>? additionalCapabilities,
    double? inputTokenCost,
    double? outputTokenCost,
    AIModelConfig? config,
  }) {
    final baseCapabilities = [
      'text_generation',
      'conversation',
      'function_calling',
    ];
    
    final allCapabilities = [
      ...baseCapabilities,
      ...?additionalCapabilities,
    ];
    
    return AIModel(
      id: id,
      name: name,
      provider: 'OpenAI',
      maxTokens: maxTokens ?? 4096,
      capabilities: allCapabilities,
      version: version,
      description: description,
      inputTokenCost: inputTokenCost,
      outputTokenCost: outputTokenCost,
      config: config,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        provider,
        maxTokens,
        capabilities,
        version,
        description,
        isAvailable,
        inputTokenCost,
        outputTokenCost,
        config,
        metadata,
      ];

  @override
  String toString() {
    return 'AIModel(id: $id, name: $name, provider: $provider, '
           'maxTokens: $maxTokens, isAvailable: $isAvailable)';
  }
}

/// AI Model configuration parameters
class AIModelConfig extends Equatable {
  /// Default temperature (0.0 to 1.0)
  final double? defaultTemperature;
  
  /// Default maximum tokens for responses
  final int? defaultMaxTokens;
  
  /// Default top-p value
  final double? defaultTopP;
  
  /// Default top-k value
  final int? defaultTopK;
  
  /// Supported temperature range
  final (double min, double max)? temperatureRange;
  
  /// Supported max tokens range
  final (int min, int max)? maxTokensRange;
  
  /// Default stop sequences
  final List<String>? defaultStopSequences;
  
  /// Whether streaming is supported
  final bool supportsStreaming;
  
  /// Whether system messages are supported
  final bool supportsSystemMessages;
  
  /// Additional configuration options
  final Map<String, dynamic>? customConfig;

  const AIModelConfig({
    this.defaultTemperature,
    this.defaultMaxTokens,
    this.defaultTopP,
    this.defaultTopK,
    this.temperatureRange,
    this.maxTokensRange,
    this.defaultStopSequences,
    this.supportsStreaming = true,
    this.supportsSystemMessages = true,
    this.customConfig,
  });

  /// Create a copy with updated fields
  AIModelConfig copyWith({
    double? defaultTemperature,
    int? defaultMaxTokens,
    double? defaultTopP,
    int? defaultTopK,
    (double, double)? temperatureRange,
    (int, int)? maxTokensRange,
    List<String>? defaultStopSequences,
    bool? supportsStreaming,
    bool? supportsSystemMessages,
    Map<String, dynamic>? customConfig,
  }) {
    return AIModelConfig(
      defaultTemperature: defaultTemperature ?? this.defaultTemperature,
      defaultMaxTokens: defaultMaxTokens ?? this.defaultMaxTokens,
      defaultTopP: defaultTopP ?? this.defaultTopP,
      defaultTopK: defaultTopK ?? this.defaultTopK,
      temperatureRange: temperatureRange ?? this.temperatureRange,
      maxTokensRange: maxTokensRange ?? this.maxTokensRange,
      defaultStopSequences: defaultStopSequences ?? this.defaultStopSequences,
      supportsStreaming: supportsStreaming ?? this.supportsStreaming,
      supportsSystemMessages: supportsSystemMessages ?? this.supportsSystemMessages,
      customConfig: customConfig ?? this.customConfig,
    );
  }

  /// Validate if a temperature value is within supported range
  bool isValidTemperature(double temperature) {
    if (temperatureRange == null) return true;
    return temperature >= temperatureRange!.$1 && temperature <= temperatureRange!.$2;
  }

  /// Validate if a max tokens value is within supported range
  bool isValidMaxTokens(int maxTokens) {
    if (maxTokensRange == null) return true;
    return maxTokens >= maxTokensRange!.$1 && maxTokens <= maxTokensRange!.$2;
  }

  @override
  List<Object?> get props => [
        defaultTemperature,
        defaultMaxTokens,
        defaultTopP,
        defaultTopK,
        temperatureRange,
        maxTokensRange,
        defaultStopSequences,
        supportsStreaming,
        supportsSystemMessages,
        customConfig,
      ];
}

/// Enumeration of AI model types
enum AIModelType {
  opus,
  sonnet,
  haiku,
  gpt,
  other;
  
  /// Get display name for the model type
  String get displayName {
    switch (this) {
      case AIModelType.opus:
        return 'Opus';
      case AIModelType.sonnet:
        return 'Sonnet';
      case AIModelType.haiku:
        return 'Haiku';
      case AIModelType.gpt:
        return 'GPT';
      case AIModelType.other:
        return 'Other';
    }
  }
  
  /// Get description for the model type
  String get description {
    switch (this) {
      case AIModelType.opus:
        return 'Most capable model for complex tasks';
      case AIModelType.sonnet:
        return 'Balanced performance for most tasks';
      case AIModelType.haiku:
        return 'Fast and efficient for simple tasks';
      case AIModelType.gpt:
        return 'OpenAI GPT model';
      case AIModelType.other:
        return 'Other AI model';
    }
  }
}