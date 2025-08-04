import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

import '../base_usecase.dart';

/// Use case for sending a conversation with history to Claude
class SendConversation extends UseCase<AIResponse, SendConversationParams> {
  final ClaudeRepository repository;

  SendConversation(this.repository);

  @override
  Future<Either<Failure, AIResponse>> call(SendConversationParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to send conversation
    return await repository.sendConversation(
      message: params.message,
      conversationHistory: params.conversationHistory,
      model: params.model,
      apiKey: params.apiKey,
      maxTokens: params.maxTokens,
      temperature: params.temperature,
      topK: params.topK,
      topP: params.topP,
      stopSequences: params.stopSequences,
    );
  }
}

/// Parameters for the SendConversation use case
class SendConversationParams extends BaseParams {
  /// New message to send to Claude
  final String message;
  
  /// Previous messages in the conversation
  final List<Message> conversationHistory;
  
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

  const SendConversationParams({
    required this.message,
    required this.conversationHistory,
    required this.model,
    required this.apiKey,
    this.maxTokens,
    this.temperature,
    this.topK,
    this.topP,
    this.stopSequences,
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
    return other is SendConversationParams &&
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
        conversationHistory.hashCode ^
        model.hashCode ^
        apiKey.hashCode ^
        maxTokens.hashCode ^
        temperature.hashCode ^
        topK.hashCode ^
        topP.hashCode;
  }
}
