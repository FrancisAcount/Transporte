import 'package:flutter/material.dart';

import '../data/admin_store.dart';
import '../data/mock_data.dart';
import '../models/safety_alert.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/data_table.dart';

/// 🏠 Apartado 1: métricas rápidas de flota, rutas y estudiantes.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Estado del buscador global del administrador.
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStore.instance,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Buscador global: filtra por rutas, flota o estudiantes en tiempo real.
        AppSearchBar(
          hintText: 'Buscar rutas, autobuses, estudiantes o conductores...',
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 18),

        // Retroalimentación del buscador: coincidencias sobre los datos reales.
        if (_query.trim().isNotEmpty) ...[
          _buildSearchResults(_query.trim().toLowerCase()),
          const SizedBox(height: 18),
        ],

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
      ),
    );
  }

  /// Resumen de coincidencias del buscador global sobre rutas, flota,
  /// estudiantes y conductores. Deja claro qué está filtrando el usuario.
  Widget _buildSearchResults(String q) {
    final rutas = MockData.routes.where((r) => '${r.codigo} ${r.nombre}'.toLowerCase().contains(q)).length;
    final buses = MockData.buses.where((b) => '${b.placa} ${b.modelo}'.toLowerCase().contains(q)).length;
    final estudiantes = MockData.students.where((s) => s.nombre.toLowerCase().contains(q)).length;
    final conductores = MockData.drivers.where((d) => '${d.nombre} ${d.ruta}'.toLowerCase().contains(q)).length;
    final total = rutas + buses + estudiantes + conductores;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.guindo.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.guindo.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search_rounded, size: 18, color: AppColors.guindo),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  total == 0
                      ? 'Sin resultados para "$q"'
                      : '$total resultado${total == 1 ? '' : 's'} para "$q"',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.guindo),
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (rutas > 0) _tag('$rutas ruta${rutas == 1 ? '' : 's'}'),
                if (buses > 0) _tag('$buses autobus${buses == 1 ? '' : 'es'}'),
                if (estudiantes > 0) _tag('$estudiantes estudiante${estudiantes == 1 ? '' : 's'}'),
                if (conductores > 0) _tag('$conductores conductor${conductores == 1 ? '' : 'es'}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Etiqueta corta de una categoría con resultados.
  Widget _tag(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.guindo.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.guindo)),
      );

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
