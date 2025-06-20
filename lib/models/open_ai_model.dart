// Example OpenAI model
import 'ai_model.dart';

class OpenAIModel extends AIModel {
  final String? extraInfo; // You can add OpenAI-specific fields

  const OpenAIModel({
    required super.name,
    required super.alias,
    required super.modelId,
    this.extraInfo,
  });
}
