import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/projects_tab.dart';
import 'tabs/tasks_tab.dart';
import 'tabs/profile_tab.dart';

/// Écran principal avec navigation par onglets
class HomeScreen extends StatefulWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const HomeScreen({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = widget.authProvider.currentUser?.id;
    if (userId == null) return;
    await widget.projectProvider.loadProjects(userId);
    await widget.taskProvider.loadAllUserTasks(userId);
  }

  static const _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.folder_outlined),
      activeIcon: Icon(Icons.folder_rounded),
      label: 'Projets',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.task_alt_outlined),
      activeIcon: Icon(Icons.task_alt_rounded),
      label: 'Tâches',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Profil',
    ),
  ];

  void _goToNewProject() {
    Navigator.of(context).pushNamed('/project/new').then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (_currentIndex == 0 || _currentIndex == 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadData,
                tooltip: 'Actualiser',
              ),
            ),
        ],
      ),
      drawer: _buildDrawer(user),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardTab(
            authProvider: widget.authProvider,
            projectProvider: widget.projectProvider,
            taskProvider: widget.taskProvider,
            onNewProject: _goToNewProject,
            onRefresh: _loadData,
          ),
          ProjectsTab(
            authProvider: widget.authProvider,
            projectProvider: widget.projectProvider,
            taskProvider: widget.taskProvider,
            onRefresh: _loadData,
          ),
          TasksTab(
            taskProvider: widget.taskProvider,
            projectProvider: widget.projectProvider,
          ),
          ProfileTab(
            authProvider: widget.authProvider,
            projectProvider: widget.projectProvider,
            taskProvider: widget.taskProvider,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: _navItems,
      ),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
              onPressed: _goToNewProject,
              tooltip: 'Nouveau projet',
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  String _getTitle() {
    return switch (_currentIndex) {
      0 => 'SunuTask',
      1 => 'Projets',
      2 => 'Tâches',
      3 => 'Profil',
      _ => 'SunuTask',
    };
  }

  Widget _buildDrawer(user) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.dashboard_outlined, 'Dashboard', 0),
                _drawerItem(Icons.folder_outlined, 'Projets', 1),
                _drawerItem(Icons.task_alt_outlined, 'Tâches', 2),
                _drawerItem(Icons.person_outline_rounded, 'Profil', 3),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: const Text(
                    'Déconnexion',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await widget.authProvider.logout();
                    if (mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login', (_) => false);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String label, int index) {
    final selected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.primary : null,
        ),
      ),
      selected: selected,
      selectedTileColor: AppColors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.of(context).pop();
      },
    );
  }
}
