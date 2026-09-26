import 'package:flutter/material.dart';

/// Paleta institucional de Transporte Escolar Maranata.
class AppColors {
  AppColors._();

  // --- Azules institucionales (sidebar, cabeceras) ---
  static const Color sidebarBg = Color(0xFF0F172A); // Azul oscuro institucional
  static const Color sidebarHover = Color(0xFF1E293B);
  static const Color sidebarActive = Color(0xFF1E293B);
  static const Color primaryBlue = Color(0xFF1D4ED8);

  // --- Guindo / Carmesí (acciones, alertas, acentos) ---
  static const Color guindo = Color(0xFF991B1B);
  static const Color guindoDark = Color(0xFF7F1D1D);
  static const Color guindoLight = Color(0xFFFEE2E2);

  // --- Fondos y superficies ---
  static const Color background = Color(0xFFF8FAFC); // Gris claro limpio
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  // --- Texto ---
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnDark = Colors.white;

  // --- Estados ---
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFB45309);
  static const Color danger = Color(0xFFB91C1C);
  static const Color info = Color(0xFF0369A1);

  /// Fondo muy suave para alternar filas de tablas.
  static const Color rowAlt = Color(0xFFFAFBFC);
}
