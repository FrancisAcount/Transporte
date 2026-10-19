import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/live_bus.dart';
import '../services/live_bus_service.dart';
import '../data/admin_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_settings.dart';
import '../widgets/common_widgets.dart';
import 'live_bus_tracking_view.dart';

/// Rutas y Monitoreo: cuadricula BUS-1..BUS-50 + visor OpenStreetMap en vivo.
class MonitoringView extends StatefulWidget {
  const MonitoringView({super.key});

  @override
  State<MonitoringView> createState() => _MonitoringViewState();
}

class _MonitoringViewState extends State<MonitoringView> {
  static const int totalBuses = 50;

  final LiveBusService liveService = LiveBusService();
  String? focusedBusId;

  void focusBus(String busId) => setState(() => focusedBusId = busId);

  /// Abre Google Maps (app del celular) en la posición del bus.
  /// Si el bus no tiene coordenadas, muestra un SnackBar informando.
  Future<void> _abrirEnGoogleMaps(BuildContext context, LiveBus bus) async {
    if (!bus.hasPosition) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sin ubicación disponible para este bus.'),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    final lat = bus.latitud!;
    final lng = bus.longitud!;
    final url =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir Google Maps.'),
          backgroundColor: AppColors.danger,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Muestra un diálogo para elegir entre abrir Google Maps (posición actual)
  /// o el seguimiento en vivo dentro de la app (marcador que se mueve solo).
  Future<void> _mostrarOpcionesMapa(BuildContext context, LiveBus bus) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ver ${bus.id} en el mapa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elige cómo quieres ver la ubicación del bus.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.open_in_new, color: isDark ? Colors.white : AppColors.navy),
              title: Text('Abrir en Google Maps', style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text('Posición actual del bus', style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                _abrirEnGoogleMaps(context, bus);
              },
            ),
            ListTile(
              leading: Icon(Icons.live_tv, color: isDark ? Colors.green : AppColors.success),
              title: Text('Seguimiento en vivo', style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: const Text(
                'El marcador se mueve solo mientras el conductor avanza',
              ),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveBusTrackingView(busId: bus.id),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStore.instance,
      builder: (context, _) {
        final stream = liveService.watchFleet(total: totalBuses);
        return StreamBuilder<List<LiveBus>>(
          stream: stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return const Text('Sin conexión a Firebase.',
                  style: TextStyle(color: AppColors.danger));
            }
            final buses = snap.data ??
                List<LiveBus>.generate(
                    totalBuses, (i) => LiveBus.offline('BUS-${i + 1}'));
            return LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth > 1100
                  ? 4 : c.maxWidth > 800 ? 3 : c.maxWidth > 520 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 190,
                ),
                itemCount: buses.length,
                itemBuilder: (context, i) => _BusCard(
                  bus: buses[i],
                  selected: buses[i].id == focusedBusId,
                  onViewOnMap: () => _mostrarOpcionesMapa(context, buses[i]),
                ),
              );
            });
          },
        );
      },
    );
  }
}

/// Tarjeta premium blanca con boxShadow por bus.
class _BusCard extends StatelessWidget {
  const _BusCard(
      {required this.bus, required this.selected,
      required this.onViewOnMap});
  final LiveBus bus;
  final bool selected;
  final VoidCallback onViewOnMap;

  @override
  Widget build(BuildContext context) {
    final active = bus.rutaActiva;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? AppColors.success
              : (isDark ? AppColors.darkBorder : AppColors.border),
          width: selected ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x0F0F172A),
              blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: (active ? AppColors.success : AppColors.textMuted)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.directions_bus_filled_rounded, size: 20,
                  color: active ? AppColors.success : AppColors.textMuted),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(bus.id,
                  style: const TextStyle(fontSize: 20,
                      fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
            StatusChip(
              label: active ? 'EN RUTA' : 'APAGADO',
              color: active ? AppColors.success : AppColors.textMuted,
              icon: active
                  ? Icons.satellite_alt_rounded
                  : Icons.satellite_alt_outlined,
            ),
          ]),
          const SizedBox(height: 8),
          Text(active ? '${bus.velocidadKmh.toStringAsFixed(1)} km/h'
              : 'Sin transmision',
              style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
          Text(bus.hasPosition
              ? '${bus.latitud!.toStringAsFixed(5)}, '
                  '${bus.longitud!.toStringAsFixed(5)}'
              : '-- , --',
              style: TextStyle(fontSize: 11.5,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onViewOnMap,
              style: FilledButton.styleFrom(
                backgroundColor:
                    selected ? AppColors.success : AppColors.sidebarBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ver en Mapa'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Visor OpenStreetMap que sigue un bus con Marcador en vivo.
class _LiveMapCard extends StatefulWidget {
  const _LiveMapCard({super.key, required this.busId,
    required this.service, required this.onClose});
  final String? busId;
  final LiveBusService service;
  final VoidCallback onClose;

  @override
  State<_LiveMapCard> createState() => _LiveMapCardState();
}

class _LiveMapCardState extends State<_LiveMapCard> {
  static const LatLng fallbackCenter = LatLng(14.6349, -90.5069);

  late final MapController _mapController;
  LiveBus? lastBus;
  bool followBus = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _applyBus(LiveBus bus) {
    lastBus = bus;
    if (!bus.hasPosition) return;
    final pos = LatLng(bus.latitud!, bus.longitud!);
    if (followBus) {
      _mapController.move(pos, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LiveBus>(
      stream: widget.service.watchBus(widget.busId!),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Sin conexión a Firebase.'));
        }
        final bus = snap.data ?? LiveBus.offline(widget.busId!);
        if (snap.hasData) {
          _applyBus(bus);
        }
        final center = lastBus?.hasPosition == true
            ? LatLng(lastBus!.latitud!, lastBus!.longitud!)
            : fallbackCenter;

        final markers = <Marker>[];
        if (lastBus?.hasPosition == true) {
          markers.add(
            Marker(
              point: LatLng(lastBus!.latitud!, lastBus!.longitud!),
              width: 40,
              height: 40,
              child: const Icon(
                Icons.directions_bus_filled_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 380,
            color: AppSettings.instance.isDarkMode
                ? AppColors.sidebarBg
                : AppColors.background,
            child: ListenableBuilder(
              listenable: AppSettings.instance,
              builder: (context, child) {
                final isDark = AppSettings.instance.isDarkMode;
                final tileUrl = isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: tileUrl,
                      userAgentPackageName: 'com.maranata.transporte',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
