import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E3A8A); // Deep Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF10B981); // Emerald
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color error = Color(0xFFEF4444);

  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
