import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/ui/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectDialog extends StatefulWidget {
  final Project? project; // null for create, non-null for edit

  const ProjectDialog({
    super.key,
    this.project,
  });

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _selectedColor;
  final List<String> _tags = [];
  bool _isLoading = false;

  final List<String> _availableColors = [
    '#FF6B6B',
    '#4ECDC4',
    '#45B7D1',
    '#96CEB4',
    '#FECA57',
    '#FF9FF3',
    '#54A0FF',
    '#5F27CD',
    '#00D2D3',
    '#FF9F43',
    '#10AC84',
    '#EE5A6F',
    '#0984E3',
    '#A29BFE',
    '#6C5CE7',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectsBloc, ProjectsState>(
      listener: (context, state) {
        if (state is ProjectsCreating || state is ProjectsUpdating) {
          setState(() => _isLoading = true);
        } else if (state is ProjectsLoaded) {
          setState(() => _isLoading = false);
          Navigator.of(context).pop(true);
        } else if (state is ProjectsError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AlertDialog(
        title: Text(widget.project == null ? 'Create Project' : 'Edit Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              Text(
                'Color',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              _buildColorPicker(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.project == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.project?.description ?? '');
    _selectedColor = widget.project?.color;
    if (widget.project?.tags != null) {
      _tags.addAll(widget.project!.tags!);
    }
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 8,
      children: _availableColors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        );
      }).toList(),
    );
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project name')),
      );
      return;
    }

    if (widget.project == null) {
      // Create new project
      context.read<ProjectsBloc>().add(
            ProjectCreated(
              name: name,
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              color: _selectedColor,
              tags: _tags.isEmpty ? null : _tags,
            ),
          );
    } else {
      // Update existing project
      final updatedProject = widget.project!.copyWith(
        name: name,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        color: _selectedColor,
        tags: _tags.isEmpty ? null : _tags,
        updatedAt: DateTime.now(),
      );
      context.read<ProjectsBloc>().add(ProjectUpdated(updatedProject));
    }
  }
}
