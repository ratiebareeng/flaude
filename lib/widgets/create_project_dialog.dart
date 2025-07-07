// widgets/create_project_dialog.dart
import 'package:claude_chat_clone/models/project.dart';
import 'package:claude_chat_clone/services/project_service.dart';
import 'package:claude_chat_clone/viewmodels/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  _CreateProjectDialogState createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF2d2d2d),
      title: Text('Create New Project'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Project Title',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Validate title input
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Project title cannot be empty')),
              );
              return;
            }

            bool result = await ProjectService.instance.createProject(
              Project(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );

            if (!result || !context.mounted) {
              return;
            }

            context.read<AppState>().createProject(
                  _titleController.text.trim(),
                  _descriptionController.text.trim(),
                );
            Navigator.of(context).pop();
          },
          child: Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
