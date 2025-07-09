import 'package:claude_chat_clone/data/repositories/project_repository.dart';
import 'package:claude_chat_clone/data/services/firebase_rtdb_service.dart';
import 'package:claude_chat_clone/domain/models/models.dart';
import 'package:claude_chat_clone/ui/widgets/widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final ProjectRepository _projectRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Projects',
        ),
        actions: [
          if (MediaQuery.of(context).size.width < 600)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showCreateProjectDialog(context),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Adjust radius as needed
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () => _showCreateProjectDialog(context),
                icon: Icon(Icons.add),
                label: Text(
                  'New project',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Adjust radius as needed
                  ),
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
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade300,
                ),
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
              stream: _projectRepository.listenToAllProjects(),
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

  @override
  void initState() {
    super.initState();
    // Initialize the repository with required dependencies
    final rtdbService =
        FirebaseRTDBService(database: FirebaseDatabase.instance);
    _projectRepository = ProjectRepository(rtdbService: rtdbService);
  }

  Widget _buildProjectsList(BuildContext context, List<Project> projects) {
    final isTablet = MediaQuery.of(context).size.width >= 1000;

    if (isTablet) {
      return GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isTablet ? 3 : 1.5,
        ),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return ProjectSummaryWidget(project: projects[index]);
        },
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ProjectSummaryWidget(project: projects[index]),
          );
        },
      );
    }
  }

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateProjectDialog(
          // projectRepository: _projectRepository,
          ),
    );
  }
}
