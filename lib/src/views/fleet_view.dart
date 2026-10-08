import 'package:flutter/material.dart';

import '../data/admin_store.dart';
import '../models/bus.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/data_table.dart';

/// 🚌 Apartado 3: control de autobuses, placas y estado mecánico.
class FleetView extends StatelessWidget {
  const FleetView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStore.instance,
      builder: (context, _) {
        final buses = AdminStore.instance.buses;
        int porEstado(BusStatus s) =>
            buses.where((b) => b.estado == s).length;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Resumen de estados de la flota (conteos vivos del panel).
            MetricGrid(
              children: [
                StatCard(
                  label: 'En ruta',
                  value: '${porEstado(BusStatus.enRuta)}',
                  icon: Icons.directions_bus_filled_rounded,
                  color: AppColors.success,
                ),
                StatCard(
                  label: 'En garaje',
                  value: '${porEstado(BusStatus.enGaraje)}',
                  icon: Icons.garage_outlined,
                  color: AppColors.info,
                ),
                StatCard(
                  label: 'En mantenimiento',
                  value: '${porEstado(BusStatus.mantenimiento)}',
                  icon: Icons.build_circle_outlined,
                  color: AppColors.warning,
                ),
                StatCard(
                  label: 'Fuera de servicio',
                  value: '${porEstado(BusStatus.fueraDeServicio)}',
                  icon: Icons.car_crash_outlined,
                  color: AppColors.guindo,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tabla de la flota
            SectionCard(
              title: 'Inventario de flota',
              subtitle: '${buses.length} vehículos registrados',
              icon: Icons.directions_bus_filled_rounded,
              trailing: FilledButton.icon(
                onPressed: () => _notify(context, 'Registro de vehículo'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nuevo bus'),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTableSim(
                  headers: const [
                    'Placa',
                    'Marca y modelo',
                    'Capacidad',
                    'Conductor',
                    'Ruta',
                    'Kilometraje',
                    'Mantenimiento',
                    'Estado'
                  ],
                  rows: buses.map(_buildRow).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Fichas de vehículo
            SectionCard(
              title: 'Fichas técnicas destacadas',
              subtitle: 'Vehículos con intervención reciente',
              icon: Icons.assignment_outlined,
              // Fichas técnicas dimensionadas por contenido (sin alturas fijas).
              child: AdaptiveGrid(
                maxColumns: 3,
                children: buses.take(3).map(_buildSpecCard).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
  /// Fila de la tabla de flota.
  List<Widget> _buildRow(Bus b) => <Widget>[
        Text(b.placa, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        Text('${b.marca} ${b.modelo}', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text('${b.capacidad} pax', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(b.conductor, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(b.ruta, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text('${formatThousands(b.kilometraje)} km', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(
          b.proximoMantenimiento,
          style: TextStyle(
            fontSize: 12.5,
            color: b.proximoMantenimiento == 'Hoy' ? AppColors.guindo : AppColors.textSecondary,
            fontWeight: b.proximoMantenimiento == 'Hoy' ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        StatusChip(label: b.estado.label, color: busStatusColor(b.estado)),
      ];

  /// Ficha técnica de un vehículo.
  Widget _buildSpecCard(Bus b) {
    final color = busStatusColor(b.estado);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.airport_shuttle_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.placa, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(
                        '${b.marca} ${b.modelo}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _specLine('Capacidad', '${b.capacidad} pasajeros'),
            _specLine('Kilometraje', '${formatThousands(b.kilometraje)} km'),
            _specLine('Próximo mantenimiento', b.proximoMantenimiento),
            _specLine('Estado', b.estado.label),
          ],
        ),
      ),
    );
  }

  /// Línea clave: valor dentro de la ficha técnica.
  Widget _specLine(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$message (demostración)')));
  }
}

/// Color asociado al estado mecánico del bus.
Color busStatusColor(BusStatus s) => switch (s) {
      BusStatus.enRuta => AppColors.success,
      BusStatus.enGaraje => AppColors.info,
      BusStatus.mantenimiento => AppColors.warning,
      BusStatus.fueraDeServicio => AppColors.guindo,
    };

/// Formatea miles con separador de punto (128450 → 128.450).
String formatThousands(int n) =>
    n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
