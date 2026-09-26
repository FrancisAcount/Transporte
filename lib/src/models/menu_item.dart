import 'package:flutter/material.dart';

/// Un apartado del menú lateral.
class MenuItem {
  const MenuItem({required this.label, required this.icon, required this.title, required this.subtitle});

  final String label;
  final IconData icon;
  final String title; // Título mostrado en la cabecera central
  final String subtitle; // Descripción bajo el título
}

/// Catálogo central de los 7 módulos de la aplicación.
class AppMenu {
  AppMenu._();

  static const List<MenuItem> items = [
    MenuItem(label: 'Panel de Inicio', icon: Icons.dashboard_rounded, title: 'Panel de Inicio', subtitle: 'Resumen operativo de flota y estudiantes'),
    MenuItem(label: 'Rutas y Monitoreo', icon: Icons.map_rounded, title: 'Rutas y Monitoreo', subtitle: 'Visualización de mapas y caminos escolares'),
    MenuItem(label: 'Gestión de Flota', icon: Icons.directions_bus_rounded, title: 'Gestión de Flota', subtitle: 'Autobuses, placas y estado mecánico'),
    MenuItem(label: 'Conductores y Personal', icon: Icons.badge_rounded, title: 'Conductores y Personal', subtitle: 'Fichas técnicas de choferes y asistentes'),
    MenuItem(label: 'Registro de Estudiantes', icon: Icons.school_rounded, title: 'Registro de Estudiantes', subtitle: 'Alumnos asignados a cada ruta'),
    MenuItem(label: 'Alertas y Seguridad', icon: Icons.warning_amber_rounded, title: 'Alertas y Seguridad', subtitle: 'Bitácora de retrasos y emergencias'),
    MenuItem(label: 'Configuración', icon: Icons.settings_rounded, title: 'Configuración', subtitle: 'Ajustes generales del sistema y perfil'),
  ];

  /// Index → MenuItem (con fallback seguro).
  static MenuItem byIndex(int index) =>
      index >= 0 && index < items.length ? items[index] : items.first;
}
