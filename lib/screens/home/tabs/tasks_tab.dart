import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/task.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/cards/task_card.dart';
import '../../../widgets/common/loading_indicator.dart';

/// Onglet liste de toutes les tâches
class TasksTab extends StatefulWidget {
  final TaskProvider taskProvider;
  final ProjectProvider projectProvider;

  const TasksTab({
    super.key,
    required this.taskProvider,
    required this.projectProvider,
  });

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.taskProvider,
      builder: (_, __) {
        final tasks = widget.taskProvider.tasks;

        return Column(
          children: [

            _FiltersBar(taskProvider: widget.taskProvider),


            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: widget.taskProvider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Rechercher une tâche…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            widget.taskProvider.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Liste
            Expanded(
              child: widget.taskProvider.isLoading
                  ? const LoadingIndicator(message: 'Chargement des tâches…')
                  : tasks.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.task_alt_rounded,
                          title: 'Aucune tâche',
                          subtitle: 'Vos tâches apparaîtront ici',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: tasks.length,
                          itemBuilder: (_, i) {
                            final t = tasks[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TaskCard(
                                task: t,
                                onTap: () => Navigator.of(context).pushNamed(
                                  '/task/detail',
                                  arguments: t.id,
                                ),
                                onStatusChanged: (status) =>
                                    widget.taskProvider.updateTaskStatus(
                                        t.id, status),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _FiltersBar extends StatelessWidget {
  final TaskProvider taskProvider;

  const _FiltersBar({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Filtre statut
          ...TaskStatus.values.map((s) {
            final selected = taskProvider.statusFilter == s;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(s.label),
                selected: selected,
                onSelected: (_) => taskProvider.setStatusFilter(selected ? null : s),
                selectedColor: AppColors.primary.withOpacity(0.15),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : null,
                  fontWeight: selected ? FontWeight.w700 : null,
                ),
              ),
            );
          }),


          ...TaskPriority.values.map((p) {
            final selected = taskProvider.priorityFilter == p;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(p.label),
                selected: selected,
                onSelected: (_) =>
                    taskProvider.setPriorityFilter(selected ? null : p),
                selectedColor: AppColors.secondary.withOpacity(0.15),
                checkmarkColor: AppColors.secondary,
              ),
            );
          }),

          if (taskProvider.statusFilter != null ||
              taskProvider.priorityFilter != null)
            TextButton.icon(
              onPressed: taskProvider.clearFilters,
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('Effacer'),
            ),
        ],
      ),
    );
  }
}
