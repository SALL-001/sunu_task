import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/comment.dart';
import '../services/storage_service.dart';

/// Provider gérant les commentaires
class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  bool _isLoading = false;

  /// Retourne les commentaires triés du plus récent au plus ancien
  List<Comment> get comments {
    final sorted = List<Comment>.from(_comments);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  int get commentCount => _comments.length;
  bool get isLoading => _isLoading;

  /// Charge les commentaires d'une tâche
  Future<void> loadComments(String taskId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _comments = await StorageService.instance.getCommentsByTaskId(taskId);
    } catch (e) {
      debugPrint('CommentProvider loadComments error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute un commentaire
  Future<void> addComment(
    String taskId,
    String userId,
    String userName,
    String content,
  ) async {
    if (content.trim().isEmpty) return;

    final comment = Comment(
      id: const Uuid().v4(),
      taskId: taskId,
      userId: userId,
      userName: userName,
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await StorageService.instance.saveComment(comment);
      _comments.add(comment);
      notifyListeners();
    } catch (e) {
      debugPrint('CommentProvider addComment error: $e');
    }
  }

  /// Supprime un commentaire
  Future<void> deleteComment(String commentId) async {
    try {
      await StorageService.instance.deleteComment(commentId);
      _comments.removeWhere((c) => c.id == commentId);
      notifyListeners();
    } catch (e) {
      debugPrint('CommentProvider deleteComment error: $e');
    }
  }

  /// Vide les commentaires
  void clear() {
    _comments = [];
    notifyListeners();
  }
}
