import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/live_bus.dart';
import '../services/live_bus_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Rutas y Monitoreo: cuadricula BUS-1..BUS-50 + visor GoogleMap en vivo.
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SectionCard(
          title: 'Visor en vivo',
          subtitle: focusedBusId == null
              ? 'Elige "Ver en Mapa" en cualquier tarjeta'
              : 'Siguiendo $focusedBusId en tiempo real',
          icon: Icons.map_outlined,
          trailing: StreamBuilder<List<LiveBus>>(
            stream: liveService.watchFleet(total: totalBuses),
            builder: (context, snap) {
              final n = snap.hasData
                  ? snap.data!.where((b) => b.rutaActiva).length
                  : 0;
              return StatusChip(
                label: '$n en ruta',
                color: n > 0 ? AppColors.success : AppColors.textMuted,
                icon: Icons.sensors_rounded,
              );
            },
          ),
          child: _LiveMapCard(
            key: ValueKey(focusedBusId ?? 'empty'),
            busId: focusedBusId,
            service: liveService,
            onClose: () => setState(() => focusedBusId = null),
          ),
        ),
        const SizedBox(height: 20),

        SectionCard(
          title: 'Flota en monitoreo',
          subtitle: '$totalBuses unidades independientes',
          icon: Icons.directions_bus_filled_rounded,
          child: StreamBuilder<List<LiveBus>>(
            stream: liveService.watchFleet(total: totalBuses),
            builder: (context, snap) {
              if (snap.hasError) {
                return const Text('Sin conexion a Firebase.',
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
                    onViewOnMap: () => focusBus(buses[i].id),
                  ),
                );
              });
            },
          ),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.success : AppColors.border,
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
              style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          Text(bus.hasPosition
              ? '${bus.latitud!.toStringAsFixed(5)}, '
                  '${bus.longitud!.toStringAsFixed(5)}'
              : '-- , --',
              style:
                  const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onViewOnMap,
              icon: const Icon(Icons.map_rounded, size: 17),
              label: const Text('Ver en Mapa'),
              style: FilledButton.styleFrom(
                backgroundColor:
                    selected ? AppColors.success : AppColors.sidebarBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Visor GoogleMap que sigue un bus con Marker en vivo.
///
/// Stateful: el Set<Marker> y el GoogleMapController viven en el State,
/// asi el mapa NO se reconstruye en cada evento del Stream — solo se
/// actualiza el marcador y se anima la camara con animateCamera.
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
  static const double followZoom = 16;

  GoogleMapController? controller;
  Set<Marker> markers = {};
  LiveBus? lastBus;
  bool followBus = true;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void onMapCreated(GoogleMapController c) => controller = c;

  /// Aplica la nueva posicion: actualiza Set<Marker> y centra la camara
  /// solo si el padre aun quiere seguir al bus (followBus).
  Future<void> applyBus(LiveBus bus) async {
    lastBus = bus;
    if (!bus.hasPosition) {
      if (mounted) setState(() => markers = {});
      return;
    }
    final pos = LatLng(bus.latitud!, bus.longitud!);
    if (mounted) {
      setState(() {
        markers = {
          Marker(
            markerId: MarkerId(bus.id),
            position: pos,
            infoWindow: InfoWindow(
              title: bus.id,
              snippet: '${bus.velocidadKmh.toStringAsFixed(1)} km/h',
            ),
          ),
        };
      });
    }
    if (followBus && controller != null) {
      try {
        await controller!.animateCamera(
          CameraUpdate.newLatLngZoom(pos, followZoom),
        );
      } catch (_) {
        // Mapa aun no listo: el proximo evento lo centra.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 380,
        color: AppColors.background,
        child: widget.busId == null
            ? const Center(
                child: Text('Toca "Ver en Mapa" para enfocar un bus',
                    style: TextStyle(color: AppColors.textSecondary)))
            : StreamBuilder<LiveBus>(
                stream: widget.service.watchBus(widget.busId!),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const Center(
                      child: Text('Sin conexion a Firebase.',
                          style: TextStyle(color: AppColors.danger)),
                    );
                  }
                  final bus = snap.data ?? LiveBus.offline(widget.busId!);
                  if (snap.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) applyBus(bus);
                    });
                  }
                  final center = lastBus?.hasPosition == true
                      ? LatLng(lastBus!.latitud!, lastBus!.longitud!)
                      : fallbackCenter;
                  return Stack(children: [
                    GoogleMap(
                      initialCameraPosition:
                          CameraPosition(target: center, zoom: 14),
                      markers: markers,
                      onMapCreated: onMapCreated,
                      onCameraMoveStarted: () => followBus = false,
                      myLocationButtonEnabled: false,
                    ),
                    Positioned(
                      top: 10, left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                              '${widget.busId} - ${bus.velocidadKmh.toStringAsFixed(1)} km/h',
                              style: const TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 6),
                          InkWell(onTap: widget.onClose,
                              child: const Icon(Icons.close_rounded, size: 16)),
                        ]),
                      ),
                    ),
                    Positioned(
                      bottom: 10, left: 10,
                      child: InkWell(
                        onTap: () => setState(() => followBus = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: followBus
                                ? AppColors.success : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(
                              followBus
                                  ? Icons.navigation_rounded
                                  : Icons.navigation_outlined,
                              size: 15,
                              color: followBus
                                  ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(followBus ? 'Siguiendo' : 'Seguir bus',
                                style: TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: followBus ? Colors.white
                                        : AppColors.textSecondary)),
                          ]),
                        ),
                      ),
                    ),
                    if (kIsWeb)
                      const Positioned(bottom: 10, right: 10,
                          child: _WebKeyHint()),
                  ]);
                },
              ),
      ),
    );
  }
}

/// Aviso web: sin API Key de Maps el mapa muestra error de Google.
class _WebKeyHint extends StatelessWidget {
  const _WebKeyHint();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Web: agrega tu Maps API Key en web/index.html',
          style: TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}
