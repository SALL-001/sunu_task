import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/task.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/cards/project_card.dart';

/// Onglet tableau de bord
class DashboardTab extends StatelessWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;
  final VoidCallback onNewProject;
  final Future<void> Function() onRefresh;

  const DashboardTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
    required this.onNewProject,
    required this.onRefresh,
  });

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListenableBuilder(
        listenable: Listenable.merge([projectProvider, taskProvider]),
        builder: (_, __) {
          final user = authProvider.currentUser;
          final counts = taskProvider.taskCountByStatus;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              _WelcomeCard(
                greeting: _greeting(),
                userName: user?.name ?? '',
              ),
              const SizedBox(height: 20),


              Text(
                'Statistiques',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Projets',
                      count: projectProvider.projectCount,
                      color: AppColors.primary,
                      icon: Icons.folder_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'À faire',
                      count: counts[TaskStatus.todo] ?? 0,
                      color: AppColors.statusTodo,
                      icon: Icons.radio_button_unchecked_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'En cours',
                      count: counts[TaskStatus.inProgress] ?? 0,
                      color: AppColors.statusInProgress,
                      icon: Icons.pending_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Terminées',
                      count: counts[TaskStatus.done] ?? 0,
                      color: AppColors.statusDone,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Projets récents',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton(
                    onPressed: onNewProject,
                    child: const Text('+ Nouveau'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (projectProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (projectProvider.allProjects.isEmpty)
                _EmptyProjectsCard(onNewProject: onNewProject)
              else
                ...projectProvider.allProjects.take(3).map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ProjectCard(
                          project: p,
                          onTap: () => Navigator.of(context)
                              .pushNamed('/project/detail', arguments: p.id),
                          showMenu: false,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String greeting;
  final String userName;

  const _WelcomeCard({required this.greeting, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName.isNotEmpty ? userName.split(' ').first : 'Utilisateur',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bonne journée productive !',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyProjectsCard extends StatelessWidget {
  final VoidCallback onNewProject;

  const _EmptyProjectsCard({required this.onNewProject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.folder_open_rounded,
              size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text(
            'Aucun projet',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onNewProject,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Créer un projet'),
          ),
        ],
      ),
    );
  }
}
