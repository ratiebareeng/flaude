// List of Claude models
import 'claude_model.dart';

/// While aliases are useful for experimentation, we recommend using specific model versions
/// (e.g., claude-sonnet-4-20250514) in production applications to ensure consistent behavior
final List<ClaudeModel> claudeModels = [
  ClaudeModel(
      name: "Claude Opus 4",
      alias: "claude-opus-4-0",
      modelId: "claude-opus-4-20250514"),
  ClaudeModel(
      name: "Claude Sonnet 4",
      alias: "claude-sonnet-4-0",
      modelId: "claude-sonnet-4-20250514"),
  ClaudeModel(
      name: "Claude Sonnet 3.7",
      alias: "claude-3-7-sonnet-latest",
      modelId: "claude-3-7-sonnet-20250219"),
  ClaudeModel(
      name: "Claude Sonnet 3.5",
      alias: "claude-3-5-sonnet-latest",
      modelId: "claude-3-5-sonnet-20241022"),
  ClaudeModel(
      name: "Claude Haiku 3.5",
      alias: "claude-3-5-haiku-latest",
      modelId: "claude-3-5-haiku-20241022"),
  ClaudeModel(
      name: "Claude Opus 3",
      alias: "claude-3-opus-latest",
      modelId: "claude-3-opus-20240229"),
];
