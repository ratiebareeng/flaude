import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

import '../base_usecase.dart';

/// Use case for sending a single prompt to Claude
class SendPrompt extends UseCase<AIResponse, SendPromptParams> {
  final ClaudeRepository repository;

  SendPrompt(this.repository);

  @override
  Future<Either<Failure, AIResponse>> call(SendPromptParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to send message
    return await repository.sendMessage(
      message: params.message,
      model: params.model,
      apiKey: params.apiKey,
      maxTokens: params.maxTokens,
      temperature: params.temperature,
      topK: params.topK,
      topP: params.topP,
      stopSequences: params.stopSequences,
      metadata: params.metadata,
    );
  }
}

/// Parameters for the SendPrompt use case
class SendPromptParams extends BaseParams {
  /// Message to send to Claude
  final String message;
  
  /// Model ID to use
  final String model;
  
  /// API key for Claude
  final String apiKey;
  
  /// Maximum tokens to generate
  final int? maxTokens;
  
  /// Temperature setting (0.0-1.0)
  final double? temperature;
  
  /// Top-K setting
  final int? topK;
  
  /// Top-P setting
  final double? topP;
  
  /// List of stop sequences
  final List<String>? stopSequences;
  
  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const SendPromptParams({
    required this.message,
    required this.model,
    required this.apiKey,
    this.maxTokens,
    this.temperature,
    this.topK,
    this.topP,
    this.stopSequences,
    this.metadata,
  });

  @override
  Failure? validate() {
    if (message.trim().isEmpty) {
      return const ValidationFailure(
          message: 'Message cannot be empty');
    }

    if (model.trim().isEmpty) {
      return const ValidationFailure(
          message: 'Model ID cannot be empty');
    }

    if (apiKey.trim().isEmpty) {
      return const ValidationFailure(
          message: 'API key cannot be empty');
    }

    if (temperature != null && (temperature! < 0.0 || temperature! > 1.0)) {
      return const ValidationFailure(
          message: 'Temperature must be between 0.0 and 1.0');
    }

    if (topP != null && (topP! < 0.0 || topP! > 1.0)) {
      return const ValidationFailure(
          message: 'Top-P must be between 0.0 and 1.0');
    }

    if (maxTokens != null && maxTokens! <= 0) {
      return const ValidationFailure(
          message: 'Max tokens must be positive');
    }

    if (topK != null && topK! <= 0) {
      return const ValidationFailure(
          message: 'Top-K must be positive');
    }

    return super.validate();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SendPromptParams &&
        other.message == message &&
        other.model == model &&
        other.apiKey == apiKey &&
        other.maxTokens == maxTokens &&
        other.temperature == temperature &&
        other.topK == topK &&
        other.topP == topP;
  }

  @override
  int get hashCode {
    return message.hashCode ^
        model.hashCode ^
        apiKey.hashCode ^
        maxTokens.hashCode ^
        temperature.hashCode ^
        topK.hashCode ^
        topP.hashCode;
  }
}
