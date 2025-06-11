import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/repositories/project_repository.dart';
import 'package:claude_chat_clone/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Projects',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (MediaQuery.of(context).size.width < 600)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showCreateProjectDialog(context),
            )
          else
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () => _showCreateProjectDialog(context),
                icon: Icon(Icons.add),
                label: Text('New project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Color(0xFF2d2d2d),
              ),
            ),
          ),

          // Sort options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Sort by', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: 'Activity',
                  items:
                      ['Activity', 'Name', 'Date Created'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // Handle sorting
                  },
                  dropdownColor: Color(0xFF2d2d2d),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Projects grid/list
          Expanded(
            child: StreamBuilder<(bool, List<Project>?)>(
              stream: ProjectRepository.instance.listenToAllProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading projects',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                final (success, projects) = snapshot.data ?? (false, null);
                if (!success || projects == null || projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No projects yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first project to get started',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return _buildProjectsList(context, projects);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to project chats
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (project.description.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  project.description,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              Spacer(),
              Text(
                'Updated ${_formatTimeAgo(project.updatedAt)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsList(BuildContext context, List<Project> projects) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    if (isTablet) {
      return GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
        ),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return _buildProjectCard(context, projects[index]);
        },
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _buildProjectCard(context, projects[index]),
          );
        },
      );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateProjectDialog(),
    );
  }
}
