import 'package:claude_chat_clone/domain/models/models.dart';
import 'package:flutter/material.dart';

class AIModelDropDownMenu extends StatefulWidget {
  final List<AIModel> menuEntries;
  final AIModel? initialEntry;
  final Function(AIModel)? onSelected;
  const AIModelDropDownMenu({
    super.key,
    required this.menuEntries,
    this.initialEntry,
    this.onSelected,
  });
  @override
  State<AIModelDropDownMenu> createState() => _AIModelDropDownMenuState();
}

class _AIModelDropDownMenuState extends State<AIModelDropDownMenu> {
  bool _isOpen = false;
  AIModel? _selectedModel;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isOpen = hasFocus;
        });
      },
      child: DropdownMenu<AIModel>(
        initialSelection: widget.initialEntry,
        trailingIcon: Builder(
          builder: (context) {
            // final isOpen = MenuController.maybeIsOpenOf(context)!;
            // Icons.arrow_drop_down Icons.arrow_drop_up
            return Icon(!_isOpen
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded);
          },
        ),
        dropdownMenuEntries: widget.menuEntries
            .map((model) => DropdownMenuEntry<AIModel>(
                  value: model,
                  label: model.name,
                ))
            .toList(),
        onSelected: (model) {
          if (model == null || model == _selectedModel) {
            return; // Avoid unnecessary updates
          }

          setState(() {
            _selectedModel = model;
          });
          widget.onSelected?.call(model);
        },
      ),
    );
  }
}
