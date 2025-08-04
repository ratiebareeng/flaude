import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for retrieving available Claude AI models
class GetModels extends UseCase<List<AIModel>, GetModelsParams> {
  final ClaudeRepository repository;

  GetModels(this.repository);

  @override
  Future<Either<Failure, List<AIModel>>> call(GetModelsParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to get available models
    return await repository.getAvailableModels(apiKey: params.apiKey);
  }
}

/// Parameters for the GetModels use case
class GetModelsParams extends BaseParams {
  /// API key for Claude
  final String apiKey;

  const GetModelsParams({
    required this.apiKey,
  });

  @override
  int get hashCode => apiKey.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetModelsParams && other.apiKey == apiKey;
  }

  @override
  Failure? validate() {
    if (apiKey.trim().isEmpty) {
      return const ValidationFailure(message: 'API key cannot be empty');
    }

    return super.validate();
  }
}
