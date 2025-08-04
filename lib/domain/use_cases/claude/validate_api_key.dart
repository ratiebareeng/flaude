import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

import '../base_usecase.dart';

/// Use case for validating a Claude API key
class ValidateApiKey extends UseCase<bool, ValidateApiKeyParams> {
  final ClaudeRepository repository;

  ValidateApiKey(this.repository);

  @override
  Future<Either<Failure, bool>> call(ValidateApiKeyParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to validate API key
    return await repository.validateApiKey(params.apiKey);
  }
}

/// Parameters for the ValidateApiKey use case
class ValidateApiKeyParams extends BaseParams {
  /// API key to validate
  final String apiKey;

  const ValidateApiKeyParams({
    required this.apiKey,
  });

  @override
  Failure? validate() {
    if (apiKey.trim().isEmpty) {
      return const ValidationFailure(
          message: 'API key cannot be empty');
    }

    // Basic format validation for Claude API keys
    if (!apiKey.startsWith('sk-ant-api03-')) {
      return const ValidationFailure(
          message: 'Invalid API key format');
    }

    return super.validate();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidateApiKeyParams && other.apiKey == apiKey;
  }

  @override
  int get hashCode => apiKey.hashCode;
}
