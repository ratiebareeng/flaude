/// Claude API Error DTO
class ClaudeApiErrorDTO {
  final String type;
  final String message;
  final Map<String, dynamic>? details;

  const ClaudeApiErrorDTO({
    required this.type,
    required this.message,
    this.details,
  });

  factory ClaudeApiErrorDTO.fromJson(Map<String, dynamic> json) {
    return ClaudeApiErrorDTO(
      type: json['type'] as String,
      message: json['message'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'ClaudeApiErrorDTO{type: $type, message: $message}';
  }
}

/// Data Transfer Objects for Claude API communication
/// Claude API Request DTO
class ClaudeApiRequestDTO {
  final String model;
  final List<Map<String, dynamic>> messages;
  final int maxTokens;
  final double? temperature;
  final int? topK;
  final double? topP;
  final List<String>? stopSequences;
  final Map<String, dynamic>? metadata;

  const ClaudeApiRequestDTO({
    required this.model,
    required this.messages,
    this.maxTokens = 4096,
    this.temperature,
    this.topK,
    this.topP,
    this.stopSequences,
    this.metadata,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'model': model,
      'max_tokens': maxTokens,
      'messages': messages,
    };

    if (temperature != null) json['temperature'] = temperature;
    if (topK != null) json['top_k'] = topK;
    if (topP != null) json['top_p'] = topP;
    if (stopSequences != null) json['stop_sequences'] = stopSequences;
    if (metadata != null) json['metadata'] = metadata;

    return json;
  }

  @override
  String toString() {
    return 'ClaudeApiRequestDTO{model: $model, messages: ${messages.length}}';
  }
}

/// Claude API Response DTO
class ClaudeApiResponseDTO {
  final String id;
  final String type;
  final String role;
  final List<ClaudeContentBlockDTO> content;
  final String model;
  final String? stopReason;
  final String? stopSequence;
  final ClaudeUsageDTO usage;

  const ClaudeApiResponseDTO({
    required this.id,
    required this.type,
    required this.role,
    required this.content,
    required this.model,
    this.stopReason,
    this.stopSequence,
    required this.usage,
  });

  /// Create from API JSON response
  factory ClaudeApiResponseDTO.fromJson(Map<String, dynamic> json) {
    return ClaudeApiResponseDTO(
      id: json['id'] as String,
      type: json['type'] as String,
      role: json['role'] as String,
      content: (json['content'] as List)
          .map((e) => ClaudeContentBlockDTO.fromJson(e))
          .toList(),
      model: json['model'] as String,
      stopReason: json['stop_reason'] as String?,
      stopSequence: json['stop_sequence'] as String?,
      usage: ClaudeUsageDTO.fromJson(json['usage']),
    );
  }

  /// Get text content from response
  String get textContent {
    return content
        .where((block) => block.type == 'text')
        .map((block) => block.text)
        .join('\n');
  }

  @override
  String toString() {
    return 'ClaudeApiResponseDTO{id: $id, model: $model, stopReason: $stopReason}';
  }
}

/// Claude Content Block DTO
class ClaudeContentBlockDTO {
  final String type;
  final String text;

  const ClaudeContentBlockDTO({
    required this.type,
    required this.text,
  });

  factory ClaudeContentBlockDTO.fromJson(Map<String, dynamic> json) {
    return ClaudeContentBlockDTO(
      type: json['type'] as String,
      text: json['text'] as String,
    );
  }

  @override
  String toString() {
    return 'ClaudeContentBlockDTO{type: $type, text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...}';
  }
}

/// Claude Usage DTO
class ClaudeUsageDTO {
  final int inputTokens;
  final int outputTokens;

  const ClaudeUsageDTO({
    required this.inputTokens,
    required this.outputTokens,
  });

  factory ClaudeUsageDTO.fromJson(Map<String, dynamic> json) {
    return ClaudeUsageDTO(
      inputTokens: json['input_tokens'] as int,
      outputTokens: json['output_tokens'] as int,
    );
  }

  int get totalTokens => inputTokens + outputTokens;

  @override
  String toString() {
    return 'ClaudeUsageDTO{inputTokens: $inputTokens, outputTokens: $outputTokens}';
  }
}
