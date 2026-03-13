/// Modèle de données pour un commentaire
class Comment {
  final String id;
  final String taskId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }


  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      taskId: map['taskId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }


  Comment copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? userName,
    String? content,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }


  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'hier';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} jours';

    final months = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun',
                    'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
    return '${createdAt.day} ${months[createdAt.month - 1]}';
  }

  @override
  String toString() => 'Comment(id: $id, taskId: $taskId)';
}
