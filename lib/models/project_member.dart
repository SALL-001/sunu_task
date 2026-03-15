/// Rôle d'un membre dans un projet
enum MemberRole {
  owner,
  admin,
  member,
}

/// Modele représentant un membre d'un projet
class ProjectMember {
  final String id;
  final String projectId;
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;

  ProjectMember({
    required this.id,
    required this.projectId,
    required this.userId,
    this.role = MemberRole.member,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'role': role.name,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory ProjectMember.fromMap(Map<String, dynamic> map) {
    return ProjectMember(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      userId: map['userId'] as String,
      role: MemberRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => MemberRole.member,
      ),
      joinedAt: DateTime.parse(map['joinedAt'] as String),
    );
  }
}
