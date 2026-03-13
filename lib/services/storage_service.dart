import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/comment.dart';

/// Service de stockage local utilisant SharedPreferences
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();


  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    if (_prefs == null) throw Exception('StorageService not initialized');
    return _prefs!;
  }

  // ──────────────────────────────────────────────────────────────
  // Clés de stockage
  // ──────────────────────────────────────────────────────────────
  static const String _keyOnboarding = 'onboarding_complete';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyUsers = 'users';
  static const String _keyProjects = 'projects';
  static const String _keyTasks = 'tasks';
  static const String _keyComments = 'comments';

  // ──────────────────────────────────────────────────────────────
  // Onboarding
  // ──────────────────────────────────────────────────────────────

  Future<bool> isOnboardingComplete() async {
    return _p.getBool(_keyOnboarding) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _p.setBool(_keyOnboarding, value);
  }

  // ──────────────────────────────────────────────────────────────
  // Utilisateurs
  // ──────────────────────────────────────────────────────────────

  Future<List<User>> getUsers() async {
    final json = _p.getString(_keyUsers);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => User.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveUser(User user) async {
    final users = await getUsers();
    final idx = users.indexWhere((u) => u.id == user.id);
    if (idx >= 0) {
      users[idx] = user;
    } else {
      users.add(user);
    }
    await _p.setString(_keyUsers, jsonEncode(users.map((u) => u.toMap()).toList()));
  }

  Future<User?> getCurrentUser() async {
    final json = _p.getString(_keyCurrentUser);
    if (json == null) return null;
    return User.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveCurrentUser(User? user) async {
    if (user == null) {
      await _p.remove(_keyCurrentUser);
    } else {
      await _p.setString(_keyCurrentUser, jsonEncode(user.toMap()));
    }
  }

  Future<void> clearCurrentUser() async {
    await _p.remove(_keyCurrentUser);
  }

  // ──────────────────────────────────────────────────────────────
  // Projets
  // ──────────────────────────────────────────────────────────────

  Future<List<Project>> getProjects() async {
    final json = _p.getString(_keyProjects);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Project.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<Project>> getProjectsByUserId(String userId) async {
    final all = await getProjects();
    return all.where((p) => p.ownerId == userId).toList();
  }

  Future<void> saveProject(Project project) async {
    final projects = await getProjects();
    final idx = projects.indexWhere((p) => p.id == project.id);
    if (idx >= 0) {
      projects[idx] = project;
    } else {
      projects.add(project);
    }
    await _p.setString(
      _keyProjects,
      jsonEncode(projects.map((p) => p.toMap()).toList()),
    );
  }

  Future<void> deleteProject(String projectId) async {
    final projects = await getProjects();
    projects.removeWhere((p) => p.id == projectId);
    await _p.setString(
      _keyProjects,
      jsonEncode(projects.map((p) => p.toMap()).toList()),
    );
    // Supprimer aussi toutes les tâches du projet
    await deleteTasksByProjectId(projectId);
  }

  // ──────────────────────────────────────────────────────────────
  // Tâches
  // ──────────────────────────────────────────────────────────────

  Future<List<Task>> getTasks() async {
    final json = _p.getString(_keyTasks);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Task.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<Task>> getTasksByProjectId(String projectId) async {
    final all = await getTasks();
    return all.where((t) => t.projectId == projectId).toList();
  }

  Future<List<Task>> getTasksByUserId(String userId) async {
    // On récupère les projets de l'utilisateur puis leurs tâches
    final projects = await getProjectsByUserId(userId);
    final projectIds = projects.map((p) => p.id).toSet();
    final all = await getTasks();
    return all.where((t) => projectIds.contains(t.projectId)).toList();
  }

  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      tasks[idx] = task;
    } else {
      tasks.add(task);
    }
    await _p.setString(
      _keyTasks,
      jsonEncode(tasks.map((t) => t.toMap()).toList()),
    );
    // Mettre à jour le compteur de tâches du projet
    await _updateProjectTaskCount(task.projectId);
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    final task = tasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));
    tasks.removeWhere((t) => t.id == taskId);
    await _p.setString(
      _keyTasks,
      jsonEncode(tasks.map((t) => t.toMap()).toList()),
    );
    await _updateProjectTaskCount(task.projectId);
    // Supprimer les commentaires
    await deleteCommentsByTaskId(taskId);
  }

  Future<void> deleteTasksByProjectId(String projectId) async {
    final tasks = await getTasks();
    final taskIds = tasks.where((t) => t.projectId == projectId).map((t) => t.id).toList();
    tasks.removeWhere((t) => t.projectId == projectId);
    await _p.setString(
      _keyTasks,
      jsonEncode(tasks.map((t) => t.toMap()).toList()),
    );
    // Supprimer aussi tous les commentaires
    for (final id in taskIds) {
      await deleteCommentsByTaskId(id);
    }
  }

  Future<void> _updateProjectTaskCount(String projectId) async {
    final tasks = await getTasksByProjectId(projectId);
    final projects = await getProjects();
    final idx = projects.indexWhere((p) => p.id == projectId);
    if (idx >= 0) {
      projects[idx] = projects[idx].copyWith(taskCount: tasks.length);
      await _p.setString(
        _keyProjects,
        jsonEncode(projects.map((p) => p.toMap()).toList()),
      );
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Commentaires
  // ──────────────────────────────────────────────────────────────

  Future<List<Comment>> getComments() async {
    final json = _p.getString(_keyComments);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Comment.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<Comment>> getCommentsByTaskId(String taskId) async {
    final all = await getComments();
    return all.where((c) => c.taskId == taskId).toList();
  }

  Future<void> saveComment(Comment comment) async {
    final comments = await getComments();
    final idx = comments.indexWhere((c) => c.id == comment.id);
    if (idx >= 0) {
      comments[idx] = comment;
    } else {
      comments.add(comment);
    }
    await _p.setString(
      _keyComments,
      jsonEncode(comments.map((c) => c.toMap()).toList()),
    );
  }

  Future<void> deleteComment(String commentId) async {
    final comments = await getComments();
    comments.removeWhere((c) => c.id == commentId);
    await _p.setString(
      _keyComments,
      jsonEncode(comments.map((c) => c.toMap()).toList()),
    );
  }

  Future<void> deleteCommentsByTaskId(String taskId) async {
    final comments = await getComments();
    comments.removeWhere((c) => c.taskId == taskId);
    await _p.setString(
      _keyComments,
      jsonEncode(comments.map((c) => c.toMap()).toList()),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Reset général
  // ──────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _p.clear();
  }
}
