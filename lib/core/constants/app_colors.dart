import 'package:flutter/material.dart';

/// Constantes de couleurs pour l'application SunuTask
class AppColors {
  AppColors._();

  // Couleurs primaires
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF3D35CC);

  // Couleurs secondaires
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF67FFF9);
  static const Color secondaryDark = Color(0xFF00A896);

  // Couleurs de fond
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F5);

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);

  // Couleurs de statut de tâches
  static const Color statusTodo = Color(0xFF6B7280);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusDone = Color(0xFF10B981);

  static const Color statusTodoBg = Color(0xFFF3F4F6);
  static const Color statusInProgressBg = Color(0xFFEFF6FF);
  static const Color statusDoneBg = Color(0xFFECFDF5);

  // Couleurs de priorité
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);

  static const Color priorityHighBg = Color(0xFFFEF2F2);
  static const Color priorityMediumBg = Color(0xFFFFFBEB);
  static const Color priorityLowBg = Color(0xFFECFDF5);

  // Couleurs utilitaires
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Divider et bordures
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);

  // Couleurs prédéfinies pour les projets (8 couleurs)
  static const List<Color> projectColors = [
    Color(0xFF6C63FF),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  // Mode sombre
  static const Color darkBackground = Color(0xFF0F0F1E);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF16213E);
  static const Color darkTextPrimary = Color(0xFFE8E8F0);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
}
