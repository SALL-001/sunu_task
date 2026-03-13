import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

/// Provider gérant les tâches avec filtrage et tri
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  /// Retourne les tâches filtrées et triées
  List<Task> get tasks {
    var result = List<Task>.from(_tasks);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                t.description.toLowerCase().contains(q),
          )
          .toList();
    }

    // Filtrage par statut
    if (_statusFilter != null) {
      result = result.where((t) => t.status == _statusFilter).toList();
    }

    // Filtrage par priorité
    if (_priorityFilter != null) {
      result = result.where((t) => t.priority == _priorityFilter).toList();
    }

    // Tri : statut (inProgress > todo > done), puis priorité (high > medium > low)
    result.sort((a, b) {
      final statusCmp = a.status.sortOrder.compareTo(b.status.sortOrder);
      if (statusCmp != 0) return statusCmp;
      return a.priority.sortOrder.compareTo(b.priority.sortOrder);
    });

    return result;
  }

  List<Task> get allTasks => List.unmodifiable(_tasks);
  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;


  Map<TaskStatus, int> get taskCountByStatus {
    final map = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      map[status] = _tasks.where((t) => t.status == status).length;
    }
    return map;
  }

  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await StorageService.instance.getTasksByProjectId(projectId);
    } catch (e) {
      _error = 'Impossible de charger les tâches';
      debugPrint('TaskProvider loadTasks error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllUserTasks(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await StorageService.instance.getTasksByUserId(userId);
    } catch (e) {
      _error = 'Impossible de charger les tâches';
      debugPrint('TaskProvider loadAllUserTasks error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(Task task) async {
    try {
      await StorageService.instance.saveTask(task);
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      _error = 'Impossible de créer la tâche';
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updated = task.copyWith(updatedAt: DateTime.now());
      await StorageService.instance.saveTask(updated);
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx >= 0) {
        _tasks[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Impossible de mettre à jour la tâche';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await StorageService.instance.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      _error = 'Impossible de supprimer la tâche';
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    await updateTask(task.copyWith(status: status));
  }



  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
