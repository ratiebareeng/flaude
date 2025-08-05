import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/ui/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AIModelDropdown extends StatelessWidget {
  final AIModel? selectedModel;
  final ValueChanged<AIModel?>? onChanged;
  final bool enabled;

  const AIModelDropdown({
    super.key,
    this.selectedModel,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is! AppReady) {
          return const SizedBox.shrink();
        }

        final models = state.availableModels;
        if (models.isEmpty) {
          return const SizedBox.shrink();
        }

        return DropdownMenu<AIModel>(
          enabled: enabled,
          initialSelection: selectedModel ?? state.selectedModel,
          trailingIcon: const Icon(Icons.keyboard_arrow_down),
          dropdownMenuEntries: models.map((model) {
            return DropdownMenuEntry<AIModel>(
              value: model,
              label: model.name,
              leadingIcon: Icon(
                _getModelIcon(model.modelType),
                size: 16,
              ),
            );
          }).toList(),
          onSelected: (model) {
            if (model != null) {
              context.read<AppBloc>().add(AppModelSelected(model.id));
              onChanged?.call(model);
            }
          },
        );
      },
    );
  }

  IconData _getModelIcon(AIModelType type) {
    switch (type) {
      case AIModelType.opus:
        return Icons.psychology;
      case AIModelType.sonnet:
        return Icons.auto_awesome;
      case AIModelType.haiku:
        return Icons.flash_on;
      case AIModelType.gpt:
        return Icons.smart_toy;
      case AIModelType.other:
        return Icons.computer;
    }
  }
}
