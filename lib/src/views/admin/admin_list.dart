// Copyright 2026 Transporte Escolar Maranata.
// Sección genérica de lista CRUD del panel administrativo.
//
// [AdminListSection] renderiza el buscador, el contador, el botón «Nuevo» y
// la lista de tarjetas con editar/eliminar de cada apartado (alumnos,
// conductores, flota, rutas y alertas).
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import 'admin_form.dart';

/// Configuración de una tarjeta de registro dentro de la lista.
class TarjetaAdmin {
  const TarjetaAdmin({
    required this.titulo,
    required this.subtitulo,
    required this.avatar,
    this.chipTexto,
    this.chipColor,
  });

  final String titulo;
  final String subtitulo;
  final String avatar;
  final String? chipTexto;
  final Color? chipColor;
}

/// Lista con buscador + alta + edición + borrado para un tipo de registro.
class AdminListSection<T> extends StatefulWidget {
  const AdminListSection({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.hintBusqueda,
    required this.etiquetaNuevo,
    required this.items,
    required this.coincide,
    required this.clave,
    required this.tarjeta,
    required this.onNuevo,
    required this.onEditar,
    required this.onEliminar,
    this.nombreEliminar,
    this.mostrarChipConteo = true,
  });

  final String titulo;
  final String subtitulo;
  final IconData icono;
  final String hintBusqueda;
  final String etiquetaNuevo;
  final List<T> Function() items;
  final bool Function(T item, String consulta) coincide;
  final String Function(T item) clave;
  final TarjetaAdmin Function(T item) tarjeta;
  final Future<void> Function(BuildContext context) onNuevo;
  final Future<void> Function(BuildContext context, T item) onEditar;
  final Future<void> Function(BuildContext context, T item) onEliminar;
  final String Function(T item)? nombreEliminar;
  final bool mostrarChipConteo;

  @override
  State<AdminListSection<T>> createState() => _AdminListSectionState<T>();
}

class _AdminListSectionState<T> extends State<AdminListSection<T>> {
  final TextEditingController _busqueda = TextEditingController();
  String _consulta = '';

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<T> get _visibles {
    final todos = widget.items();
    final q = _consulta.trim().toLowerCase();
    if (q.isEmpty) return todos;
    return todos.where((e) => widget.coincide(e, q)).toList();
  }

  Future<void> _eliminar(BuildContext context, T item) async {
    final nombre = widget.nombreEliminar?.call(item) ?? 'este registro';
    final ok = await confirmarEliminacion(
      context,
      titulo: 'Eliminar registro',
      detalle: '¿Eliminar "$nombre"? Esta acción no se puede deshacer.',
    );
    if (!ok || !context.mounted) return;
    await widget.onEliminar(context, item);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$nombre" eliminado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibles = _visibles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppSearchBar(
                hintText: widget.hintBusqueda,
                controller: _busqueda,
                onChanged: (v) => setState(() => _consulta = v),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => widget.onNuevo(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(widget.etiquetaNuevo),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.guindo,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.titulo,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (widget.mostrarChipConteo)
              StatusChip(
                label: '${visibles.length} registros',
                color: AppColors.navy,
                icon: widget.icono,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitulo,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        if (visibles.isEmpty)
          _vacio()
        else
          ...visibles.map(_tarjeta),
      ],
    );
  }

  Widget _tarjeta(T item) {
    final t = widget.tarjeta(item);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: AppColors.navy.withValues(alpha: 0.10),
              child: Text(
                t.avatar,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.subtitulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (t.chipTexto != null) ...[
                    const SizedBox(height: 6),
                    StatusChip(
                      label: t.chipTexto!,
                      color: t.chipColor ?? AppColors.navy,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_outlined, size: 19),
              color: AppColors.textSecondary,
              onPressed: () => widget.onEditar(context, item),
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
              color: AppColors.guindo,
              onPressed: () => _eliminar(context, item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vacio() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 44,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 10),
              const Text(
                'Sin resultados',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Prueba con otra búsqueda o crea un registro nuevo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () {
                  _busqueda.clear();
                  setState(() => _consulta = '');
                },
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Limpiar búsqueda'),
              ),
            ],
          ),
        ),
      );
}

