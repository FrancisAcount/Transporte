// `Route` se oculta porque Flutter ya define un widget con ese nombre.
import 'package:flutter/material.dart' hide Route;

import '../data/admin_store.dart';
import '../models/route.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/school_map_painter.dart';

/// 🗺️ Apartado 2: mapa de rutas, tarjetas por ruta y puntos de control.
class RoutesView extends StatelessWidget {
  const RoutesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStore.instance,
      builder: (context, _) {
        final rutas = AdminStore.instance.rutas;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Mapa simulado
            SectionCard(
              title: 'Mapa de rutas en vivo',
              subtitle: 'Vista general de la cobertura escolar',
              icon: Icons.map_outlined,
              trailing: StatusChip(
                label: '${rutas.length} rutas activas',
                color: AppColors.success,
                icon: Icons.sensors_rounded,
              ),
              child: const AspectRatio(
                aspectRatio: 16 / 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: CustomPaint(painter: SchoolMapPainter()),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tarjetas por ruta, dimensionadas por contenido.
            AdaptiveGrid(
              maxColumns: 2,
              children: rutas.map(_buildRouteCard).toList(),
            ),
            const SizedBox(height: 20),

            // Puntos de control de una ruta
            const SectionCard(
              title: 'Puntos de control — RT-01',
              subtitle: 'Secuencia estimada de paradas',
              icon: Icons.timeline_rounded,
              child: Column(
                children: [
                  TimelineItem(
                      time: '06:30',
                      label: 'Salida: Av. Los Pinos',
                      done: true),
                  TimelineItem(
                      time: '07:05',
                      label: 'Parada 1: Calle 12 (9 alumnos)',
                      done: true),
                  TimelineItem(
                      time: '07:40',
                      label: 'Parada 2: Ciudadela Norte (11 alumnos)',
                      done: true),
                  TimelineItem(
                      time: '08:10',
                      label: 'Llegada: Colegio Maranata (34 a bordo)',
                      done: false),
                  TimelineItem(
                      time: '13:30',
                      label: 'Regreso programado',
                      done: false,
                      isLast: true),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  /// Tarjeta resumen de una ruta.
  Widget _buildRouteCard(Route route) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.guindo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(route.codigo, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.guindo)),
                ),
                const Spacer(),
                StatusChip(label: route.estado, color: statusColor(route.estado)),
              ],
            ),
            const SizedBox(height: 10),
            Text(route.nombre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${route.primerPunto} → ${route.ultimoPunto}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                _miniStat(Icons.directions_bus_rounded, route.bus),
                _miniStat(Icons.groups_rounded, '${route.estudiantes} est.'),
                _miniStat(Icons.schedule_rounded, route.horaSalida),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Dato compacto dentro de la tarjeta de ruta.
  Widget _miniStat(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

/// Color asociado al estado textual de una ruta.
Color statusColor(String estado) => switch (estado) {
      'En curso' => AppColors.success,
      'Programada' => AppColors.info,
      _ => AppColors.textMuted,
    };

/// Hito de la línea de tiempo de una ruta.
class TimelineItem extends StatelessWidget {
  const TimelineItem({super.key, required this.time, required this.label, required this.done, this.isLast = false});

  final String time;
  final String label;
  final bool done;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          Column(
            children: [
              Container(
                height: 14,
                width: 14,
                decoration: BoxDecoration(
                  color: done ? AppColors.guindo : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: done ? AppColors.guindo : AppColors.border, width: 2),
                ),
              ),
              if (!isLast) Container(width: 2, height: 34, color: AppColors.border),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: done ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//__HELPERS__
