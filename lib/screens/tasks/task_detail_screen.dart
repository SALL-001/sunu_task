import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/cards/comment_card.dart';

/// Écran de détail d'une tâche
class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final AuthProvider authProvider;
  final TaskProvider taskProvider;
  final CommentProvider commentProvider;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.authProvider,
    required this.taskProvider,
    required this.commentProvider,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _commentCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Task? _task;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  void _loadTask() {
    final allTasks = widget.taskProvider.allTasks;
    setState(() {
      _task = allTasks.firstWhere(
            (t) => t.id == widget.taskId,
        orElse: () => Task(
          id: '',
          projectId: '',
          title: 'Tâche introuvable',
          createdAt: DateTime.now(),
        ),
      );
    });
    if (_task != null && _task!.id.isNotEmpty) {
      widget.commentProvider.loadComments(widget.taskId);
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    return switch (_task?.status) {
      TaskStatus.todo => AppColors.statusTodo,
      TaskStatus.inProgress => AppColors.statusInProgress,
      TaskStatus.done => AppColors.statusDone,
      null => AppColors.textHint,
    };
  }

  Future<void> _sendComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    final user = widget.authProvider.currentUser;
    if (user == null) return;

    await widget.commentProvider.addComment(
      widget.taskId,
      user.id,
      user.name,
      _commentCtrl.text.trim(),
    );
    _commentCtrl.clear();

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la tâche'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
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
      await widget.taskProvider.deleteTask(widget.taskId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;
    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tâche')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la tâche'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context)
                .pushNamed('/task/edit', arguments: task.id)
                .then((_) => _loadTask()),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                Text(task.title, style: Theme.of(context).textTheme.headlineLarge),

                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                _InfoRow(
                  icon: Icons.circle,
                  iconColor: _statusColor,
                  label: 'Statut',
                  child: PopupMenuButton<TaskStatus>(
                    initialValue: task.status,
                    onSelected: (s) async {
                      await widget.taskProvider.updateTaskStatus(task.id, s);
                      _loadTask();
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            task.status.label,
                            style: TextStyle(color: _statusColor, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, color: _statusColor, size: 16),
                        ],
                      ),
                    ),
                    itemBuilder: (_) => TaskStatus.values
                        .map((s) => PopupMenuItem(value: s, child: Text(s.label)))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 12),

                _InfoRow(
                  icon: Icons.flag_rounded,
                  iconColor: switch (task.priority) {
                    TaskPriority.high => AppColors.priorityHigh,
                    TaskPriority.medium => AppColors.priorityMedium,
                    TaskPriority.low => AppColors.priorityLow,
                  },
                  label: 'Priorité',
                  child: Text(task.priority.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),

                if (task.dueDate != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    iconColor: task.isOverdue ? AppColors.error : AppColors.textSecondary,
                    label: 'Échéance',
                    child: Text(
                      DateFormat('dd MMMM yyyy', 'fr').format(task.dueDate!),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: task.isOverdue ? AppColors.error : null,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                _InfoRow(
                  icon: Icons.access_time_rounded,
                  iconColor: AppColors.textSecondary,
                  label: 'Créée le',
                  child: Text(
                    DateFormat('dd MMM yyyy', 'fr').format(task.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                ListenableBuilder(
                  listenable: widget.commentProvider,
                  builder: (_, __) {
                    final comments = widget.commentProvider.comments;
                    final currentUserId = widget.authProvider.currentUser?.id ?? '';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.comment_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Commentaires (${widget.commentProvider.commentCount})',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (widget.commentProvider.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (comments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.textHint),
                                  const SizedBox(height: 8),
                                  const Text('Aucun commentaire', style: TextStyle(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          )
                        else
                          ...comments.map((c) => CommentCard(
                            comment: c,
                            isAuthor: c.userId == currentUserId,
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Supprimer'),
                                  content: const Text('Supprimer ce commentaire ?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await widget.commentProvider.deleteComment(c.id);
                              }
                            },
                          )),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          _CommentInput(controller: _commentCtrl, onSend: _sendComment),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget child;

  const _InfoRow({required this.icon, required this.iconColor, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text('$label : ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        child,
      ],
    );
  }
}

class _CommentInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _CommentInput({required this.controller, required this.onSend});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: 'Écrire un commentaire…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.newline,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: widget.controller.text.trim().isNotEmpty ? widget.onSend : null,
              icon: const Icon(Icons.send_rounded),
              color: AppColors.primary,
              disabledColor: AppColors.textHint,
              style: IconButton.styleFrom(
                backgroundColor: widget.controller.text.trim().isNotEmpty
                    ? AppColors.primary.withOpacity(0.1)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}