import 'package:flutter/material.dart';

/// Paleta institucional de Transporte Escolar Maranata.
class AppColors {
  AppColors._();

  // --- Azules institucionales (sidebar, cabeceras) ---
  static const Color sidebarBg = Color(0xFF0F172A); // Azul oscuro institucional
  static const Color sidebarHover = Color(0xFF1E293B);
  static const Color sidebarActive = Color(0xFF1E293B);
  static const Color primaryBlue = Color(0xFF1D4ED8);
  /// Azul institucional profundo para cabeceras de diálogo y bloques de marca.
  static const Color navy = Color(0xFF1E3A8A);
  static const Color navyDeep = Color(0xFF172554);
  /// Alias corporativo usado en cabeceras de diálogo.
  static const Color azulCorporativo = navy;
  static const Color azulCorporativoOscuro = navyDeep;

  /// Verde oficial de WhatsApp para la acción "Mensaje".
  static const Color whatsappGreen = Color(0xFF25D366);

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

  // --- Acentos de la portada pública (welcome_view) ---
  /// Rosa institucional de los distintivos y chips rosados.
  static const Color rosado = Color(0xFFDB2777);
  static const Color rosadoLight = Color(0xFFFCE7F3);
  /// Carmesí brillante de los botones de llamada a la acción («Ver rutas»).
  static const Color crimson = Color(0xFFE11D48);
  static const Color crimsonDark = Color(0xFFBE123C);
  /// Verde de los estados activos en la portada.
  static const Color green = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFDCFCE7);
  /// Naranja de la etiqueta «Ruta Centro».
  static const Color naranja = Color(0xFFF97316);
  static const Color naranjaLight = Color(0xFFFFEDD5);
  /// Azul de la etiqueta «Ruta Norte».
  static const Color azulRuta = Color(0xFF1D4ED8);
  static const Color azulLight = Color(0xFFDBEAFE);
  /// Ámbar de los avisos preventivos.
  static const Color ambar = Color(0xFFF59E0B);
  static const Color ambarLight = Color(0xFFFEF3C7);
  /// Degradados de las ilustraciones de flota.
  static const Color cielo = Color(0xFFBFDBFE);
  static const Color asfalto = Color(0xFF475569);

  /// Fondo muy suave para alternar filas de tablas.
  static const Color rowAlt = Color(0xFFFAFBFC);
}
