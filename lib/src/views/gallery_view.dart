import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/admin_store.dart';
import '../models/foto_galeria.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// 🖼️ Apartado «Galería»: fotos reales de la flota (buses de 18 asientos).
///
/// Muestra las fotografías fijas incluidas en `assets/images/` y, debajo, las
/// que el administrador ha subido desde el panel (guardadas en Firebase en
/// base64). Al tocar cualquier foto se abre un visor a pantalla completa.
class GalleryView extends StatelessWidget {
  const GalleryView({super.key});

  /// Fotos institucionales embebidas en los assets del proyecto.
  static const List<_FotoAsset> _assets = [
    _FotoAsset(
      ruta: 'assets/images/bus-coaster-2016.jpg',
      titulo: 'Bus escolar de 18 asientos',
      descripcion: 'Minibús tipo Coaster, unidad principal del servicio.',
    ),
    _FotoAsset(
      ruta: 'assets/images/bus-coaster-escolar.jpg',
      titulo: 'Unidad escolar',
      descripcion: 'Vehículo de 18 asientos para rutas del centro.',
    ),
    _FotoAsset(
      ruta: 'assets/images/bus-foton-18.jpg',
      titulo: 'Minibús de la flota',
      descripcion: 'Bus de 18 asientos listo para el recorrido matutino.',
    ),
    _FotoAsset(
      ruta: 'assets/images/bus-ankai-minibus.jpg',
      titulo: 'Minibús Ankai',
      descripcion: 'Unidad de 18 asientos para rutas periféricas.',
    ),
    _FotoAsset(
      ruta: 'assets/images/flota-wetherby.jpg',
      titulo: 'Flota estacionada',
      descripcion: 'Vehículos listos antes de la salida.',
    ),
    _FotoAsset(
      ruta: 'assets/images/interior-asientos.jpg',
      titulo: 'Interior del bus',
      descripcion: 'Asientos y pasillo del bus escolar de 18 plazas.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStore.instance,
      builder: (context, _) {
        final subidas = AdminStore.instance.fotosGaleria;
        final total = _assets.length + subidas.length;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SectionCard(
              title: 'Galería de la flota',
              subtitle: 'Fotos reales de nuestros buses de 18 asientos',
              icon: Icons.photo_library_rounded,
              trailing: Chip(
                avatar: const Icon(Icons.photo_camera_rounded, size: 16),
                label: Text('$total fotos'),
                backgroundColor: AppColors.navy.withValues(alpha: 0.08),
                side: BorderSide.none,
              ),
              child: const Text(
                'Nuestra flota está conformada por minibuses de 18 asientos. '
                'Toca una foto para verla en pantalla completa. Las fotos '
                'subidas desde el panel administrativo aparecen al final.',
                style: TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
            _Rejilla(
              children: [
                for (final f in _assets)
                  _TarjetaFoto(
                    titulo: f.titulo,
                    descripcion: f.descripcion,
                    onTap: () => _visorAsset(context, f),
                    child: Image.asset(
                      f.ruta,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const _PlaceholderFoto(),
                    ),
                  ),
                for (final FotoGaleria f in subidas)
                  _TarjetaFoto(
                    titulo: f.titulo,
                    descripcion: f.descripcion,
                    onTap: () => _visorBase64(context, f),
                    child: _imagenBase64(f.datosBase64),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _imagenBase64(String datos) {
    try {
      return Image.memory(
        base64Decode(datos),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _PlaceholderFoto(),
      );
    } catch (_) {
      return const _PlaceholderFoto();
    }
  }

  /// Visor a pantalla completa para las fotos de los assets.
  void _visorAsset(BuildContext context, _FotoAsset f) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _DialogoFoto(
        titulo: f.titulo,
        descripcion: f.descripcion,
        child: Image.asset(
          f.ruta,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const _PlaceholderFoto(),
        ),
      ),
    );
  }

  /// Visor a pantalla completa para las fotos subidas (base64).
  void _visorBase64(BuildContext context, FotoGaleria f) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _DialogoFoto(
        titulo: f.titulo,
        descripcion: f.descripcion,
        child: _imagenBase64(f.datosBase64),
      ),
    );
  }
}

/// Datos de una foto fija incluida en los assets.
class _FotoAsset {
  const _FotoAsset({
    required this.ruta,
    required this.titulo,
    required this.descripcion,
  });

  final String ruta;
  final String titulo;
  final String descripcion;
}

/// Cuadrícula responsiva de fotos (2–4 columnas según el ancho).
class _Rejilla extends StatelessWidget {
  const _Rejilla({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final ancho = c.maxWidth;
        final columnas = ancho >= 1100
            ? 4
            : ancho >= 800
                ? 3
                : 2;
        return GridView.count(
          crossAxisCount: columnas,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.82,
          children: children,
        );
      },
    );
  }
}

/// Tarjeta individual: imagen arriba + pie de foto abajo.
class _TarjetaFoto extends StatelessWidget {
  const _TarjetaFoto({
    required this.titulo,
    required this.descripcion,
    required this.child,
    required this.onTap,
  });

  final String titulo;
  final String descripcion;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: child),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.3,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo con la foto ampliada y su pie.
class _DialogoFoto extends StatelessWidget {
  const _DialogoFoto({
    required this.titulo,
    required this.descripcion,
    required this.child,
  });

  final String titulo;
  final String descripcion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: child,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recuadro de respaldo cuando una imagen no se puede cargar.
class _PlaceholderFoto extends StatelessWidget {
  const _PlaceholderFoto();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy.withValues(alpha: 0.06),
      alignment: Alignment.center,
      child: const Icon(
        Icons.directions_bus_filled_rounded,
        size: 40,
        color: AppColors.textMuted,
      ),
    );
  }
}

