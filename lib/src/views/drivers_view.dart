import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/driver.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/data_table.dart';

/// 👨‍✈️ Apartado 4: fichas técnicas de conductores y asistentes.
class DriversView extends StatelessWidget {
  const DriversView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Perfiles dimensionados por contenido (sin alturas fijas).
        AdaptiveGrid(
          maxColumns: 3,
          children: MockData.drivers.take(3).map(_buildProfile).toList(),
        ),
        const SizedBox(height: 20),

        SectionCard(
          title: 'Directorio de personal',
          subtitle: '${MockData.drivers.length} registros',
          icon: Icons.badge_outlined,
          trailing: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Exportar directorio (demostración)'))),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Exportar'),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTableSim(
              headers: const ['Nombre', 'Cédula', 'Teléfono', 'Cargo', 'Ruta', 'Experiencia', 'Licencia', 'Estado'],
              rows: MockData.drivers.map(_buildRow).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Fila de la tabla de personal.
  List<Widget> _buildRow(Driver d) => <Widget>[
        Text(d.nombre, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        Text(d.cedula, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(d.telefono, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(d.tipo, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(d.ruta, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text('${d.aniosExperiencia} años', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(
          d.licencia,
          style: TextStyle(
            fontSize: 12.5,
            color: d.licencia.contains('renovar') ? AppColors.warning : AppColors.textSecondary,
          ),
        ),
        StatusChip(
          label: d.estado ? 'Activo' : 'Inactivo',
          color: d.estado ? AppColors.success : AppColors.textMuted,
          icon: d.estado ? Icons.check_circle_outline : Icons.pause_circle_outline,
        ),
      ];

  /// Tarjeta de perfil con avatar e iniciales.
  Widget _buildProfile(Driver d) {
    final color = d.tipo == 'Conductor' ? AppColors.guindo : AppColors.info;
    final initials = d.nombre.split(' ').take(2).map((w) => w[0]).join();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withValues(alpha: 0.14),
                  child: Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.nombre, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                      Text('${d.tipo} · ${d.ruta}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                StatusChip(label: d.estado ? 'Activo' : 'Inactivo', color: d.estado ? AppColors.success : AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 14),
            _line(Icons.badge_outlined, 'Cédula: ${d.cedula}'),
            _line(Icons.phone_iphone_rounded, d.telefono),
            _line(Icons.workspace_premium_outlined, d.licencia),
            _line(Icons.history_rounded, '${d.aniosExperiencia} años de experiencia'),
          ],
        ),
      ),
    );
  }

  /// Línea de dato dentro del perfil.
  Widget _line(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
          ],
        ),
      );
}
