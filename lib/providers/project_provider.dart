import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../services/storage_service.dart';

/// Provider gérant la collection de projets
class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Project> get projects {
    if (_searchQuery.isEmpty) return List.unmodifiable(_projects);
    final q = _searchQuery.toLowerCase();
    return _projects
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q),
        )
        .toList();
  }

  List<Project> get allProjects => List.unmodifiable(_projects);
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;


  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await StorageService.instance.getProjectsByUserId(userId);
      // Trier par date de création décroissante
      _projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = 'Impossible de charger les projets';
      debugPrint('ProjectProvider loadProjects error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> createProject(Project project) async {
    try {
      await StorageService.instance.saveProject(project);
      _projects.insert(0, project);
      notifyListeners();
    } catch (e) {
      _error = 'Impossible de créer le projet';
      notifyListeners();
    }
  }


  Future<void> updateProject(Project project) async {
    try {
      final updated = project.copyWith(updatedAt: DateTime.now());
      await StorageService.instance.saveProject(updated);
      final idx = _projects.indexWhere((p) => p.id == project.id);
      if (idx >= 0) {
        _projects[idx] = updated;
        if (_selectedProject?.id == project.id) {
          _selectedProject = updated;
        }
        notifyListeners();
      }
    } catch (e) {
      _error = 'Impossible de mettre à jour le projet';
      notifyListeners();
    }
  }


  Future<void> deleteProject(String projectId) async {
    try {
      await StorageService.instance.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      if (_selectedProject?.id == projectId) {
        _selectedProject = null;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Impossible de supprimer le projet';
      notifyListeners();
    }
  }


  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }

  Future<void> refreshProjectTaskCount(String projectId) async {
    final projects = await StorageService.instance.getProjects();
    final idx = projects.indexWhere((p) => p.id == projectId);
    if (idx >= 0) {
      final localIdx = _projects.indexWhere((p) => p.id == projectId);
      if (localIdx >= 0) {
        _projects[localIdx] = projects[idx];
        notifyListeners();
      }
    }
  }


  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
