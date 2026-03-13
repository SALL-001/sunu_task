import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/cards/task_card.dart';
import '../../widgets/common/loading_indicator.dart';

/// Écran de détail d'un projet
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late final TaskProvider _localTaskProvider;

  @override
  void initState() {
    super.initState();
    _localTaskProvider = TaskProvider();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    await _localTaskProvider.loadTasks(widget.projectId);
  }

  @override
  void dispose() {
    _localTaskProvider.dispose();
    super.dispose();
  }

  Future<void> _deleteProject() async {
    final project = widget.projectProvider.allProjects
        .firstWhere((p) => p.id == widget.projectId);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer le projet'),
        content: Text(
          'Supprimer "${project.name}" supprimera aussi toutes ses tâches. Cette action est irréversible.',
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
      await widget.projectProvider.deleteProject(widget.projectId);
      final userId = widget.authProvider.currentUser?.id;
      if (userId != null) {
        await widget.taskProvider.loadAllUserTasks(userId);
      }
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.projectProvider, _localTaskProvider]),
      builder: (_, __) {
        final projects = widget.projectProvider.allProjects;
        final projectIdx = projects.indexWhere((p) => p.id == widget.projectId);
        if (projectIdx < 0) {
          return Scaffold(
            appBar: AppBar(title: const Text('Projet')),
            body: const Center(child: Text('Projet introuvable')),
          );
        }

        final project = projects[projectIdx];
        final tasks = _localTaskProvider.tasks;
        final counts = _localTaskProvider.taskCountByStatus;

        return Scaffold(
          appBar: AppBar(
            title: Text(project.name),
            backgroundColor: project.color,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context)
                    .pushNamed('/project/edit', arguments: project.id)
                    .then((_) {
                  _loadTasks();
                  final userId = widget.authProvider.currentUser?.id;
                  if (userId != null) {
                    widget.projectProvider.loadProjects(userId);
                  }
                }),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteProject,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context)
                .pushNamed('/task/new', arguments: project.id)
                .then((_) {
              _loadTasks();
              final userId = widget.authProvider.currentUser?.id;
              if (userId != null) {
                widget.taskProvider.loadAllUserTasks(userId);
              }
            }),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nouvelle tâche'),
          ),
          body: RefreshIndicator(
            onRefresh: _loadTasks,
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [project.color, project.color.withOpacity(0.7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (project.description.isNotEmpty)
                        Text(
                          project.description,
                          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            'Créé le ${DateFormat('dd MMM yyyy', 'fr').format(project.createdAt)}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusChip(label: 'À faire', count: counts[TaskStatus.todo] ?? 0, color: AppColors.statusTodo),
                      _StatusChip(label: 'En cours', count: counts[TaskStatus.inProgress] ?? 0, color: AppColors.statusInProgress),
                      _StatusChip(label: 'Terminées', count: counts[TaskStatus.done] ?? 0, color: AppColors.statusDone),
                    ],
                  ),
                ),

                const Divider(height: 1),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Tâches (${tasks.length})', style: Theme.of(context).textTheme.headlineSmall),
                ),

                if (_localTaskProvider.isLoading)
                  const LoadingIndicator()
                else if (tasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: EmptyStateWidget(
                      icon: Icons.task_alt_outlined,
                      title: 'Aucune tâche',
                      subtitle: 'Ajoutez une tâche à ce projet',
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    child: Column(
                      children: tasks.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(
                          task: t,
                          onTap: () => Navigator.of(context)
                              .pushNamed('/task/detail', arguments: t.id)
                              .then((_) {
                            _loadTasks();
                            final userId = widget.authProvider.currentUser?.id;
                            if (userId != null) {
                              widget.taskProvider.loadAllUserTasks(userId);
                            }
                          }),
                          onStatusChanged: (status) async {
                            await _localTaskProvider.updateTaskStatus(t.id, status);
                            final userId = widget.authProvider.currentUser?.id;
                            if (userId != null) {
                              await widget.taskProvider.loadAllUserTasks(userId);
                            }
                          },
                        ),
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$label : $count', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}