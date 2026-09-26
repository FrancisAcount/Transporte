import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/student.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/data_table.dart';

/// 🧒 Apartado 5: lista de alumnos asignados a cada ruta.
class StudentsView extends StatelessWidget {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Métricas de matrícula
        const MetricGrid(
          children: [
            StatCard(label: 'Estudiantes activos', value: '119', icon: Icons.school_rounded),
            StatCard(label: 'En la escuela', value: '62', icon: Icons.apartment_rounded, color: AppColors.info),
            StatCard(label: 'Recogidos', value: '31', icon: Icons.how_to_reg_rounded, color: AppColors.success),
            StatCard(label: 'Retirados', value: '26', icon: Icons.logout_rounded, color: AppColors.textMuted),
          ],
        ),
        const SizedBox(height: 20),

        // Filtros
        SectionCard(
          title: 'Alumnos por ruta',
          subtitle: 'Listado simulado con filtros',
          icon: Icons.groups_rounded,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 6),
                ...['Todas', 'RT-01', 'RT-02', 'RT-03', 'RT-04'].map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: f == 'Todas',
                      selectedColor: AppColors.guindo,
                      labelStyle: TextStyle(color: f == 'Todas' ? Colors.white : AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
                      onSelected: (_) {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Tabla de estudiantes
        SectionCard(
          title: 'Listado de estudiantes',
          subtitle: '${MockData.students.length} registros en pantalla',
          icon: Icons.table_rows_rounded,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTableSim(
              headers: const ['Estudiante', 'Grado', 'Ruta', 'Parada', 'Estado'],
              rows: MockData.students.map(_buildRow).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Fila con avatar, nombre, grado y estado de retiro.
  List<Widget> _buildRow(Student s) => <Widget>[
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.sidebarBg,
              child: Text(
                s.nombre.substring(0, 1),
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Text(s.nombre, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
        ),
        Text(s.grado, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(s.ruta, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(s.parada, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        StatusChip(label: s.estado, color: studentStatusColor(s.estado)),
      ];
}

/// Color asociado al estado del estudiante.
Color studentStatusColor(String estado) => switch (estado) {
      'En la escuela' => AppColors.info,
      'Recogido' => AppColors.success,
      'En ruta' => AppColors.warning,
      'Retirado' => AppColors.textMuted,
      _ => AppColors.textSecondary,
    };
