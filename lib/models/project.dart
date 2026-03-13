import 'package:flutter/material.dart';

/// Modèle de données pour un projet
class Project {
  final String id;
  final String name;
  final String description;
  final Color color;
  final String ownerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int taskCount;

  const Project({
    required this.id,
    required this.name,
    this.description = '',
    this.color = const Color(0xFF6C63FF),
    required this.ownerId,
    required this.createdAt,
    this.updatedAt,
    this.taskCount = 0,
  });

  /// Sérialisation vers Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'taskCount': taskCount,
    };
  }

  /// Désérialisation depuis Map
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      color: Color(map['color'] as int),
      ownerId: map['ownerId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      taskCount: (map['taskCount'] as int?) ?? 0,
    );
  }

  /// Copie avec modifications
  Project copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? taskCount,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      taskCount: taskCount ?? this.taskCount,
    );
  }

  @override
  String toString() => 'Project(id: $id, name: $name)';
}
