import 'package:flutter/material.dart';

import '../data/admin_store.dart';
import '../data/driver_data.dart';
import '../models/student_record.dart';
import '../theme/app_colors.dart';

/// Detalle de una unidad: cabecera con el bus y su chofer, resumen de
/// alumnos por estado y tabla estilo Excel con el listado completo.
///
/// Se renderiza **dentro** del módulo de estudiantes (no como ruta propia),
/// por lo que el botón «Volver» usa [onVolver] en lugar del `Navigator`.
class BusStudentDetailView extends StatelessWidget {
  const BusStudentDetailView({super.key, required this.busId, this.onVolver});

  /// Unidad a detalle (por ejemplo `BUS-07`).
  final String busId;

  /// Regresa a la cuadrícula de unidades; `null` si no hay dónde volver.
  final VoidCallback? onVolver;

  @override
  Widget build(BuildContext context) {
    final conductor = DriverData.porBus[busId]?.nombre ?? 'Sin asignar';
    final estudiantes = AdminStore.instance.alumnos
        .where((e) => e.busId == busId)
        .toList()
      ..sort((a, b) => a.nombres.compareTo(b.nombres));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            centerTitle: true,
            // Sin ruta propia: el botón «Volver» controla el estado del módulo.
            automaticallyImplyLeading: false,
            leading: onVolver == null
                ? null
                : IconButton(
                    tooltip: 'Volver a unidades',
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.navy,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: onVolver,
                  ),
            title: Text(
              '$busId · Estudiantes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
            pinned: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navy, AppColors.navyDeep],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_bus_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  busId,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  conductor,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildTotalLabel(context, estudiantes.length),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: estudiantes.isEmpty
            ? _buildVacio()
            : Column(
                children: [
                  _buildResumen(context, estudiantes),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: DataTableExcel(
                        headers: const [
                          'Nombre',
                          'Apellido Paterno',
                          'Apellido Materno',
                          'Curso',
                        ],
                        rows: _buildFilas(estudiantes),
                        showShadows: false,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Etiqueta con el total de alumnos de la unidad sobre la cabecera.
  Widget _buildTotalLabel(BuildContext context, int total) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              '$total estudiante${total == 1 ? '' : 's'}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );

  /// Tarjeta de resumen con los conteos por estado de la unidad.
  Widget _buildResumen(BuildContext context, List<StudentRecord> estudiantes) {
    final enEscuela =
        estudiantes.where((e) => e.estado == StudentStatus.enEscuela).length;
    final recogido =
        estudiantes.where((e) => e.estado == StudentStatus.recogido).length;
    final enRuta =
        estudiantes.where((e) => e.estado == StudentStatus.enRuta).length;
    final ausente =
        estudiantes.where((e) => e.estado == StudentStatus.ausente).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.navy,
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _estadoBadge('En la escuela', enEscuela, AppColors.navy),
                    _estadoBadge('Recogido', recogido, AppColors.success),
                    _estadoBadge('En ruta', enRuta, AppColors.warning),
                    _estadoBadge('Ausente', ausente, AppColors.textMuted),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Chip con el conteo de un estado; se oculta cuando el conteo es cero.
  Widget _estadoBadge(String label, int count, Color color) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Filas de la tabla: nombre, apellidos y curso de cada alumno.
  List<DataRow> _buildFilas(List<StudentRecord> estudiantes) => estudiantes
      .map(
        (e) => DataRow(
          cells: [
            _celda(
              Text(
                e.nombres,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _celda(
              Text(
                e.apellidoPaterno,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            _celda(
              Text(
                e.apellidoMaterno,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            _celda(
              Text(
                e.grado,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      )
      .toList();

  /// Celda con el texto centrado y aire vertical.
  DataCell _celda(Widget child) => DataCell(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: child,
        ),
      );

  /// Estado vacío cuando la unidad no tiene alumnos asignados.
  Widget _buildVacio() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'Esta unidad no tiene estudiantes asignados.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
}

/// Tabla estilo Excel corporativa: filas compactas, sin sombras pesadas y
/// columnas de ancho fijo.
class DataTableExcel extends StatelessWidget {
  const DataTableExcel({
    super.key,
    required this.headers,
    required this.rows,
    this.showShadows = true,
  });

  /// Títulos de cada columna.
  final List<String> headers;

  /// Filas ya construidas ([DataRow] funciona solo como contenedor).
  final List<DataRow> rows;

  /// Dibuja la sombra suave bajo el cuerpo de la tabla.
  final bool showShadows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ancho disponible de la tabla (sin contar el padding de 16 por lado).
        final tableWidth = constraints.maxWidth - 32;
        // Reparte el ancho entre las columnas por igual.
        final colWidth = tableWidth / headers.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _headerRow(colWidth),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border.fromBorderSide(
                  BorderSide(color: AppColors.border),
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: _DataTableBody(
                headers: headers,
                rows: rows,
                colWidth: colWidth,
                cellMargin: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            if (showShadows) const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  /// Fila de encabezado con degradado discreto.
  Widget _headerRow(double colWidth) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Row(
          children: [
            for (final header in headers)
              SizedBox(width: colWidth, child: _headerCell(header)),
          ],
        ),
      );

  /// Celda del encabezado.
  Widget _headerCell(String label) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      );
}

/// Cuerpo de la tabla sin sombras, solo bordes inferiores por fila.
class _DataTableBody extends StatelessWidget {
  const _DataTableBody({
    required this.headers,
    required this.rows,
    required this.colWidth,
    required this.cellMargin,
  });

  /// Títulos; definen la cantidad de columnas del cuerpo.
  final List<String> headers;

  /// Filas con las celdas ya construidas.
  final List<DataRow> rows;

  /// Ancho fijo de cada columna.
  final double colWidth;

  /// Aire vertical aplicado a cada celda.
  final EdgeInsets cellMargin;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 280),
        child: IntrinsicHeight(
          child: Table(
            columnWidths: {
              for (int i = 0; i < headers.length; i++)
                i: FixedColumnWidth(colWidth),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (int r = 0; r < rows.length; r++)
                TableRow(
                  children: [
                    for (int c = 0; c < headers.length; c++)
                      _cell(rows[r].cells[c].child, r: r),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Celda con fondo alternado y borde inferior.
  Widget _cell(Widget child, {required int r}) {
    final isEven = r.isEven;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12) + cellMargin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isEven ? AppColors.surface : AppColors.rowAlt,
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      child: child,
    );
  }
}
