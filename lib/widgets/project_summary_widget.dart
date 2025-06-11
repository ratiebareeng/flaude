import 'package:claude_chat_clone/helpers/helpers.dart';
import 'package:claude_chat_clone/models/models.dart';
import 'package:flutter/material.dart';

class ProjectSummaryWidget extends StatelessWidget {
  final Project project;
  const ProjectSummaryWidget({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to project chats
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (project.description.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  project.description,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              Spacer(),
              Text(
                'Updated ${StringHelper.instance.formatTimeAgo(project.updatedAt)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
