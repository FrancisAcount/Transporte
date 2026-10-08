import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/bus_illustration.dart';

/// Datos simulados de la portada pública.
///
/// Se centralizan aquí para que las secciones sean solo maquetación y el
/// sustituto por un backend real sea un cambio de un único archivo.

/// Métrica destacada de la sección de servicio.
class WelcomeMetric {
  const WelcomeMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.tint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color tint;
}

/// Tarjeta del carrusel de beneficios.
class WelcomeBenefit {
  const WelcomeBenefit({
    required this.tag,
    required this.title,
    required this.text,
    required this.scene,
  });

  final String tag;
  final String title;
  final String text;
  final BusScene scene;
}

/// Ruta escolar destacada con su botón «Ver ruta».
class WelcomeRoute {
  const WelcomeRoute({
    required this.name,
    required this.color,
    required this.tint,
    required this.stops,
    required this.schedule,
    required this.summary,
  });

  final String name;
  final Color color;
  final Color tint;
  final int stops;
  final String schedule;
  final String summary;
}

/// Salida de la mañana (tabla de horarios).
class WelcomeDeparture {
  const WelcomeDeparture({required this.time, required this.route, required this.bus});

  final String time;
  final String route;
  final String bus;
}

/// Paradero principal activo.
class WelcomeStop {
  const WelcomeStop({required this.name, required this.route, required this.time});

  final String name;
  final String route;
  final String time;
}

/// Aviso publicado en el tablón de novedades.
class WelcomeNotice {
  const WelcomeNotice({
    required this.title,
    required this.text,
    required this.date,
    required this.icon,
    required this.color,
    required this.tint,
  });

  final String title;
  final String text;
  final String date;
  final IconData icon;
  final Color color;
  final Color tint;
}

/// Fotografía de la galería de flota.
class WelcomeGalleryItem {
  const WelcomeGalleryItem({required this.caption, required this.scene});

  final String caption;
  final BusScene scene;
}

/// Objetivo del proyecto mostrado junto a la galería.
class WelcomeObjective {
  const WelcomeObjective({required this.title, required this.text, required this.icon});

  final String title;
  final String text;
  final IconData icon;
}

/// Métricas clave de la portada.
const List<WelcomeMetric> kWelcomeMetrics = [
  WelcomeMetric(
    label: 'Rutas',
    value: '18',
    icon: Icons.route_rounded,
    color: AppColors.azulRuta,
    tint: AppColors.azulLight,
  ),
  WelcomeMetric(
    label: 'Paraderos',
    value: '48',
    icon: Icons.location_on_rounded,
    color: AppColors.green,
    tint: AppColors.greenLight,
  ),
  WelcomeMetric(
    label: 'Acompañantes',
    value: '2 turnos',
    icon: Icons.groups_rounded,
    color: AppColors.naranja,
    tint: AppColors.naranjaLight,
  ),
];

/// Rutas principales con su color de distintivo.
const List<WelcomeRoute> kWelcomeRoutes = [
  WelcomeRoute(
    name: 'Ruta Norte',
    color: AppColors.azulRuta,
    tint: AppColors.azulLight,
    stops: 18,
    schedule: '06:30 h',
    summary: 'Recorrido centro norte, 18 paraderos, Horario: 06:30 h',
  ),
  WelcomeRoute(
    name: 'Ruta Sur',
    color: AppColors.green,
    tint: AppColors.greenLight,
    stops: 16,
    schedule: '06:30 h',
    summary: 'Recorrido centro sur, 16 paraderos, Horario: 06:30 h',
  ),
  WelcomeRoute(
    name: 'Ruta Centro',
    color: AppColors.naranja,
    tint: AppColors.naranjaLight,
    stops: 14,
    schedule: '06:30 h',
    summary: 'Recorrido centro, 14 paraderos, Horario: 06:30 h',
  ),
];

/// Horarios de salida de la mañana.
const List<WelcomeDeparture> kWelcomeDepartures = [
  WelcomeDeparture(time: '06:30', route: 'Ruta Norte', bus: 'Bus-01 · Zona Norte'),
  WelcomeDeparture(time: '06:45', route: 'Ruta Sur', bus: 'Bus-03 · Zona Sur'),
  WelcomeDeparture(time: '07:00', route: 'Ruta Centro', bus: 'Bus-05 · Zona Centro'),
];

/// Paraderos principales con su estado.
const List<WelcomeStop> kWelcomeStops = [
  WelcomeStop(name: 'Plaza Norte', route: 'Ruta Norte', time: '06:10'),
  WelcomeStop(name: 'Calle del Sol', route: 'Ruta Sur', time: '06:20'),
  WelcomeStop(name: 'Parque Central', route: 'Ruta Centro', time: '06:25'),
  WelcomeStop(name: 'Terminal Sur', route: 'Ruta Centro', time: '06:30'),
];

/// Últimos avisos del tablero.
const List<WelcomeNotice> kWelcomeNotices = [
  WelcomeNotice(
    title: 'Aviso sobre horarios',
    text: 'Consulta los cambios en los horarios de salida.',
    date: 'Publicado 2025-04-11',
    icon: Icons.info_rounded,
    color: AppColors.info,
    tint: Color(0xFFE0F2FE),
  ),
  WelcomeNotice(
    title: 'Aviso sobre rutas',
    text: 'Revisa el mapa y los lugares actualizados.',
    date: 'Publicado 2025-04-11',
    icon: Icons.warning_amber_rounded,
    color: AppColors.warning,
    tint: AppColors.ambarLight,
  ),
  WelcomeNotice(
    title: 'Aviso sobre paraderos',
    text: 'Nuevos paraderos operativos.',
    date: 'Publicado 2025-04-11',
    icon: Icons.check_circle_rounded,
    color: AppColors.success,
    tint: AppColors.greenLight,
  ),
];

/// Galería de la flota.
const List<WelcomeGalleryItem> kWelcomeGallery = [
  WelcomeGalleryItem(caption: 'Transporte escolar', scene: BusScene.estudiantes),
  WelcomeGalleryItem(caption: 'Nuestra flota', scene: BusScene.galeria),
  WelcomeGalleryItem(caption: 'Recorridos Maranata', scene: BusScene.carretera),
];

/// Objetivos del proyecto.
const List<WelcomeObjective> kWelcomeObjectives = [
  WelcomeObjective(
    title: 'Seguridad',
    text: 'Monitoreo en tiempo real de las rutas y paraderos.',
    icon: Icons.verified_user_rounded,
  ),
  WelcomeObjective(
    title: 'Puntualidad',
    text: 'Cumplimiento de los horarios establecidos.',
    icon: Icons.schedule_rounded,
  ),
  WelcomeObjective(
    title: 'Organización',
    text: 'Facilita la gestión de rutas, buses, conductores y estudiantes.',
    icon: Icons.groups_rounded,
  ),
];

/// Enlaces de navegación rápida del pie de página.
const List<String> kWelcomeNavLinks = [
  'Inicio',
  'Rutas',
  'Paraderos',
  'Galería',
  'Contacto',
  'Nosotros',
];

/// Totales del cuadro «Estado del servicio».
const List<WelcomeMetric> kServiceTotals = [
  WelcomeMetric(
    label: 'Vacantes',
    value: '18',
    icon: Icons.airline_seat_recline_normal_rounded,
    color: AppColors.azulRuta,
    tint: AppColors.azulLight,
  ),
  WelcomeMetric(
    label: 'Paraderos',
    value: '48',
    icon: Icons.location_on_rounded,
    color: AppColors.green,
    tint: AppColors.greenLight,
  ),
  WelcomeMetric(
    label: 'Acompañantes',
    value: '06',
    icon: Icons.groups_rounded,
    color: AppColors.naranja,
    tint: AppColors.naranjaLight,
  ),
];

/// Beneficios del carrusel horizontal.
const List<WelcomeBenefit> kWelcomeBenefits = [
  WelcomeBenefit(
    tag: 'Transporte seguro',
    title: 'Viaja con tranquilidad',
    text: 'Benjamín, cada día a las diferentes rutas y paraderos verificados.',
    scene: BusScene.estudiantes,
  ),
  WelcomeBenefit(
    tag: 'Rutas escolares',
    title: 'Cerca de tu colegio',
    text: 'Conozca los horarios y las diferentes rutas y paraderos designados.',
    scene: BusScene.carretera,
  ),
  WelcomeBenefit(
    tag: 'Servicio confianza',
    title: 'Siempre a tiempo',
    text: 'Nuestro transporte está diseñado para priorizar la puntualidad y la seguridad.',
    scene: BusScene.galeria,
  ),
];
