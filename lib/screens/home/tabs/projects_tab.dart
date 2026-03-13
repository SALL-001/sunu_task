import 'package:flutter/material.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/cards/project_card.dart';
import '../../../widgets/common/loading_indicator.dart';

/// Onglet liste des projets
class ProjectsTab extends StatefulWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;
  final Future<void> Function() onRefresh;

  const ProjectsTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
    required this.onRefresh,
  });

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _deleteProject(String projectId, String projectName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer le projet'),
        content: Text(
          'Supprimer "$projectName" supprimera aussi toutes ses tâches. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await widget.projectProvider.deleteProject(projectId);
      final userId = widget.authProvider.currentUser?.id;
      if (userId != null) {
        await widget.taskProvider.loadAllUserTasks(userId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projet supprimé')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.projectProvider,
      builder: (_, __) {
        final projects = widget.projectProvider.projects;

        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: widget.projectProvider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un projet…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              widget.projectProvider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
              ),


              Expanded(
                child: widget.projectProvider.isLoading
                    ? const LoadingIndicator(message: 'Chargement des projets…')
                    : projects.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.folder_open_rounded,
                            title: 'Aucun projet',
                            subtitle: 'Créez votre premier projet pour commencer',
                            action: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed('/project/new')
                                  .then((_) => widget.onRefresh()),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Créer un projet'),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            itemCount: projects.length,
                            itemBuilder: (_, i) {
                              final p = projects[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ProjectCard(
                                  project: p,
                                  onTap: () => Navigator.of(context)
                                      .pushNamed('/project/detail',
                                          arguments: p.id)
                                      .then((_) => widget.onRefresh()),
                                  onEdit: () => Navigator.of(context)
                                      .pushNamed('/project/edit',
                                          arguments: p.id)
                                      .then((_) => widget.onRefresh()),
                                  onDelete: () =>
                                      _deleteProject(p.id, p.name),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
