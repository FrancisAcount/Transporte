import 'dart:math' as math;

/// Snapshot de un bus en Realtime Database (`buses_en_vivo/BUS-XX`).
class LiveBus {
  const LiveBus({
    required this.id,
    this.latitud,
    this.longitud,
    this.velocidadKmh = 0,
    this.rutaActiva = false,
    this.ultimaActualizacion,
  });

  final String id;
  final double? latitud;
  final double? longitud;
  final double velocidadKmh;
  final bool rutaActiva;
  final DateTime? ultimaActualizacion;

  bool get hasPosition => latitud != null && longitud != null;

  /// Distancia Haversine en metros (para filtrar jitter del GPS).
  static double distanceMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * r * math.asin(math.sqrt(a));
  }

  factory LiveBus.offline(String id) => LiveBus(id: id);

  factory LiveBus.fromSnapshot(String id, Map<dynamic, dynamic>? data) {
    if (data == null) return LiveBus.offline(id);
    double? toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    DateTime? ts;
    final rawTs = data['ultima_actualizacion'];
    if (rawTs is int) {
      ts = DateTime.fromMillisecondsSinceEpoch(rawTs);
    }
    return LiveBus(
      id: id,
      latitud: toDouble(data['latitud']),
      longitud: toDouble(data['longitud']),
      velocidadKmh: toDouble(data['velocidad']) ?? 0,
      rutaActiva: data['ruta_activa'] == true,
      ultimaActualizacion: ts,
    );
  }
}
