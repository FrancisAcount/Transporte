import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/live_bus.dart';
import '../services/live_bus_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_settings.dart';

/// Pantalla de seguimiento en vivo de un bus escolar.
///
/// Escucha `buses_en_vivo/<busId>` en Firebase y mueve el marcador en el mapa
/// cada vez que el conductor actualiza su posición desde su celular.
class LiveBusTrackingView extends StatefulWidget {
  const LiveBusTrackingView({super.key, required this.busId});

  final String busId;

  @override
  State<LiveBusTrackingView> createState() => _LiveBusTrackingViewState();
}

class _LiveBusTrackingViewState extends State<LiveBusTrackingView> {
  static const LatLng fallbackCenter = LatLng(14.6349, -90.5069);

  late final MapController _mapController;
  LiveBus? lastBus;
  bool followBus = true;
  final LiveBusService _service = LiveBusService();

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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.busId} — En vivo'),
        backgroundColor: AppColors.guindo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<LiveBus>(
        stream: _service.watchBus(widget.busId),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(
              child: Text('Sin conexión a Firebase.'),
            );
          }
          final bus = snap.data ?? LiveBus.offline(widget.busId);
          if (snap.hasData) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => _applyBus(bus));
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
      ),
    );
  }
}