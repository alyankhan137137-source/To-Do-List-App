import 'package:flutter/material.dart';

/// Centralized app color palette supporting light/dark modes, categories, and priority badges.
class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryVariant = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color accent = Color(0xFF8B5CF6); // Purple

  // Priority Colors
  static const Color priorityLow = Color(0xFF10B981); // Green
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber
  static const Color priorityHigh = Color(0xFFEF4444); // Red
  static const Color priorityUrgent = Color(0xFFDC2626); // Dark Red

  // Category Colors
  static const Color categoryWork = Color(0xFF3B82F6); // Blue
  static const Color categoryPersonal = Color(0xFFEC4899); // Pink
  static const Color categoryShopping = Color(0xFFF59E0B); // Amber
  static const Color categoryHealth = Color(0xFF10B981); // Green
  static const Color categoryFitness = Color(0xFF8B5CF6); // Purple
  static const Color categoryEducation = Color(0xFF06B6D4); // Cyan
  static const Color categoryOther = Color(0xFF6B7280); // Gray

  // Neutral Colors (Light Theme)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Neutral Colors (Dark Theme)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
}
