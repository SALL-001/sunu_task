import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Écran de création / modification d'une tâche
class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final String? projectId;
  final TaskProvider taskProvider;

  const TaskFormScreen({
    super.key,
    this.task,
    this.projectId,
    required this.taskProvider,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  TaskStatus _status = TaskStatus.todo;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  bool _isLoading = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('fr'),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updated = widget.task!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          status: _status,
          priority: _priority,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
          updatedAt: DateTime.now(),
        );
        await widget.taskProvider.updateTask(updated);
      } else {
        final task = Task(
          id: const Uuid().v4(),
          projectId: widget.projectId!,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          status: _status,
          priority: _priority,
          dueDate: _dueDate,
          createdAt: DateTime.now(),
        );
        await widget.taskProvider.createTask(task);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Tâche mise à jour ✓' : 'Tâche créée ✓'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
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
      await widget.taskProvider.deleteTask(widget.task!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Titre de la tâche',
                controller: _titleCtrl,
                hint: "Qu'est-ce que vous devez faire ?",
                prefixIcon: Icons.task_alt_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Titre obligatoire';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Description (optionnel)',
                controller: _descCtrl,
                hint: 'Décrivez cette tâche…',
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              Text('Statut', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: TaskStatus.values.map((s) {
                  final selected = _status == s;
                  Color color;
                  switch (s) {
                    case TaskStatus.todo: color = AppColors.statusTodo;
                    case TaskStatus.inProgress: color = AppColors.statusInProgress;
                    case TaskStatus.done: color = AppColors.statusDone;
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _status = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? color.withOpacity(0.2) : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? color : AppColors.border,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                color: selected ? color : AppColors.textHint,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                  color: selected ? color : AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              Text('Priorité', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: TaskPriority.values.map((p) {
                  final selected = _priority == p;
                  Color color;
                  IconData icon;
                  switch (p) {
                    case TaskPriority.high: color = AppColors.priorityHigh; icon = Icons.arrow_upward_rounded;
                    case TaskPriority.medium: color = AppColors.priorityMedium; icon = Icons.remove_rounded;
                    case TaskPriority.low: color = AppColors.priorityLow; icon = Icons.arrow_downward_rounded;
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? color.withOpacity(0.15) : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? color : AppColors.border,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(icon, color: selected ? color : AppColors.textHint, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                p.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                  color: selected ? color : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              Text("Date d'échéance", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dueDate != null
                              ? DateFormat('dd MMMM yyyy', 'fr').format(_dueDate!)
                              : 'Sélectionner une date',
                          style: TextStyle(
                            color: _dueDate != null ? AppColors.textPrimary : AppColors.textHint,
                          ),
                        ),
                      ),
                      if (_dueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _dueDate = null),
                          child: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              CustomButton(
                text: _isEditing ? 'Modifier la tâche' : 'Créer la tâche',
                onPressed: _submit,
                isLoading: _isLoading,
                icon: _isEditing ? Icons.check_rounded : Icons.add_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}