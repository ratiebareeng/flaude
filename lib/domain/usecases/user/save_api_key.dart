import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for saving a Claude API key
class SaveApiKey extends UseCase<void, SaveApiKeyParams> {
  final UserRepository repository;

  SaveApiKey(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveApiKeyParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to save API key
    return await repository.saveApiKey(params.apiKey);
  }
}

/// Parameters for the SaveApiKey use case
class SaveApiKeyParams extends BaseParams {
  /// API key to save
  final String apiKey;

  const SaveApiKeyParams({
    required this.apiKey,
  });

  @override
  int get hashCode => apiKey.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveApiKeyParams && other.apiKey == apiKey;
  }

  @override
  Failure? validate() {
    if (apiKey.trim().isEmpty) {
      return const ValidationFailure(message: 'API key cannot be empty');
    }

    // Basic format validation for Claude API keys
    if (!apiKey.startsWith('sk-ant-api03-')) {
      return const ValidationFailure(message: 'Invalid API key format');
    }

    return super.validate();
  }
}
