/// Statut d'une tâche
enum TaskStatus {
  todo,
  inProgress,
  done;

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'À faire';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.done:
        return 'Terminée';
    }
  }

  /// Ordre pour le tri (inProgress > todo > done)
  int get sortOrder {
    switch (this) {
      case TaskStatus.inProgress:
        return 0;
      case TaskStatus.todo:
        return 1;
      case TaskStatus.done:
        return 2;
    }
  }
}


enum TaskPriority {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'Haute';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.low:
        return 'Basse';
    }
  }

  int get sortOrder {
    switch (this) {
      case TaskPriority.high:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.low:
        return 2;
    }
  }
}


class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String assigneeId;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.assigneeId = '',
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'assigneeId': assigneeId,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      assigneeId: (map['assigneeId'] as String?) ?? '',
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.done) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  @override
  String toString() => 'Task(id: $id, title: $title, status: $status)';
}
