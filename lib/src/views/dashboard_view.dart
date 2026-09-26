import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/safety_alert.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/data_table.dart';

/// 🏠 Apartado 1: métricas rápidas de flota, rutas y estudiantes.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Fila 1: métricas rápidas
        const MetricGrid(
          children: [
            StatCard(label: 'Autobuses operativos', value: '6', icon: Icons.directions_bus_filled_rounded, caption: '1 en mantenimiento'),
            StatCard(label: 'Rutas activas', value: '4', icon: Icons.route_rounded, color: AppColors.info, caption: '119 estudiantes'),
            StatCard(label: 'Conductores', value: '7', icon: Icons.people_alt_rounded, color: AppColors.success, caption: '6 activos'),
            StatCard(label: 'Alertas abiertas', value: '3', icon: Icons.warning_amber_rounded, caption: '2 críticas'),
          ],
        ),
        const SizedBox(height: 20),

        // Fila 2: estado de rutas + actividad reciente
        LayoutBuilder(builder: (context, c) {
          final isWide = c.maxWidth > 900;
          final routes = _buildRoutesCard();
          final activity = _buildActivityCard();
          return isWide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: routes), const SizedBox(width: 16), Expanded(flex: 2, child: activity)])
              : Column(children: [routes, const SizedBox(height: 16), activity]);
        }),
        const SizedBox(height: 20),

        // Fila 3: próximos mantenimientos
        SectionCard(
          title: 'Próximos mantenimientos',
          subtitle: 'Agenda técnica de la flota',
          icon: Icons.build_circle_outlined,
          child: Column(
            children: MockData.buses
                .map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_bus_rounded, size: 18, color: AppColors.textMuted),
                          const SizedBox(width: 10),
                          SizedBox(width: 90, child: Text(b.placa, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                          Expanded(child: Text(b.modelo, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                          StatusChip(
                            label: b.proximoMantenimiento,
                            color: b.proximoMantenimiento == 'Hoy' ? AppColors.guindo : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Tarjeta con el resumen de rutas del día.
  Widget _buildRoutesCard() {
    return SectionCard(
      title: 'Estado de rutas del día',
      subtitle: 'Operación en tiempo real',
      icon: Icons.route_rounded,
      child: DataTableSim(
        headers: const ['Código', 'Ruta', 'Bus', 'Salida', 'Estado'],
        rows: MockData.routes
            .map((r) => <Widget>[
                  Text(r.codigo, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  Text(r.nombre, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  Text(r.bus, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  Text(r.horaSalida, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  StatusChip(
                    label: r.estado,
                    color: switch (r.estado) {
                      'En curso' => AppColors.success,
                      'Programada' => AppColors.info,
                      _ => AppColors.textMuted,
                    },
                  ),
                ])
            .toList(),
      ),
    );
  }

  /// Tarjeta con las últimas alertas registradas.
  Widget _buildActivityCard() {
    return SectionCard(
      title: 'Actividad reciente',
      subtitle: 'Últimas notificaciones del sistema',
      icon: Icons.notifications_none_rounded,
      child: Column(
        children: MockData.alerts.take(4).map((a) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(color: a.nivel.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(a.detalle, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Text(a.hora, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
