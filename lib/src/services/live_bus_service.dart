import 'package:firebase_database/firebase_database.dart';

import '../models/live_bus.dart';

/// Servicio que publica la posicion del bus en Realtime Database.
///
/// Ruta: `buses_en_vivo/BUS-XX` con campos:
/// latitud, longitud, velocidad, ruta_activa, ultima_actualizacion.
class LiveBusService {
  LiveBusService({FirebaseDatabase? database}) : _database = database;

  /// Instancia inyectada (tests); si es `null` se resuelve en tiempo de uso.
  final FirebaseDatabase? _database;

  /// Base de datos activa o `null` cuando Firebase no está inicializado.
  ///
  /// `FirebaseDatabase.instance` lanza `[core/no-app]` si `initializeApp`
  /// aún no corrió (p. ej. en tests de widget), así que se captura el error
  /// y la interfaz degrada a estado vacío en lugar de romper la app.
  FirebaseDatabase? get _db {
    if (_database != null) return _database;
    try {
      return FirebaseDatabase.instance;
    } catch (_) {
      return null;
    }
  }

  /// Base que exige Firebase activo (rutas de escritura).
  FirebaseDatabase get _requireDb {
    final db = _db;
    if (db == null) {
      throw StateError('Firebase no está inicializado (LiveBusService).');
    }
    return db;
  }

  DatabaseReference refFor(String busId) =>
      _requireDb.ref('buses_en_vivo/$busId');

  DatabaseReference get liveRoot => _requireDb.ref('buses_en_vivo');

  /// Stream de toda la flota: emite lista BUS-1..BUS-50 en cada cambio.
  ///
  /// Sin Firebase emite una única tanda de buses offline para que la cuadrícula
  /// siga renderizando.
  Stream<List<LiveBus>> watchFleet({int total = 50}) {
    final db = _db;
    if (db == null) {
      return Stream.value(
        List<LiveBus>.generate(total, (i) => LiveBus.offline('BUS-${i + 1}')),
      );
    }
    return db.ref('buses_en_vivo').onValue.map((event) {
      final raw = event.snapshot.value;
      final map = raw is Map ? raw : <dynamic, dynamic>{};
      return List<LiveBus>.generate(total, (i) {
        final id = 'BUS-${i + 1}';
        final node = map[id];
        if (node is Map) {
          return LiveBus.fromSnapshot(id, Map<dynamic, dynamic>.from(node));
        }
        return LiveBus.offline(id);
      });
    });
  }

  /// Stream de un solo bus para el visor del mapa (marcador suave).
  ///
  /// Escucha `buses_en_vivo/BUS-XX` y emite solo cuando hay coordenadas
  /// validas distintas (filtra ruido/jitter menor a ~5 m) para que el
  /// Marker no tiemble y la camara no salte.
  ///
  /// Sin Firebase emite un único bus offline para que la vista muestre su
  /// empty-state en lugar de lanzar.
  Stream<LiveBus> watchBus(String busId, {double minMoveMeters = 5}) {
    final db = _db;
    if (db == null) return Stream.value(LiveBus.offline(busId));
    LiveBus? lastEmitted;
    return db.ref('buses_en_vivo/$busId').onValue.map((event) {
      final v = event.snapshot.value;
      if (v is Map) {
        return LiveBus.fromSnapshot(busId, Map<dynamic, dynamic>.from(v));
      }
      return LiveBus.offline(busId);
    }).where((bus) {
      if (!bus.hasPosition) return true; // deja pasar offline para el empty-state
      final prev = lastEmitted;
      if (prev == null || !prev.hasPosition) {
        lastEmitted = bus;
        return true;
      }
      final moved = LiveBus.distanceMeters(
        prev.latitud!,
        prev.longitud!,
        bus.latitud!,
        bus.longitud!,
      );
      if (moved >= minMoveMeters) {
        lastEmitted = bus;
        return true;
      }
      return false;
    });
  }

  /// Publica (o actualiza) la posicion en vivo. No lanza: el GPS local
  /// debe seguir funcionando aunque falle la red.
  Future<bool> publishPosition({
    required String busId,
    required double latitud,
    required double longitud,
    required double velocidadKmh,
    bool rutaActiva = true,
  }) async {
    try {
      await refFor(busId).set({
        'latitud': latitud,
        'longitud': longitud,
        'velocidad': double.parse(velocidadKmh.toStringAsFixed(1)),
        'ruta_activa': rutaActiva,
        'ultima_actualizacion': ServerValue.timestamp,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Marca ruta_activa=false al finalizar, conservando ultima posicion.
  Future<bool> markRouteFinished(String busId) async {
    try {
      await refFor(busId).update({
        'ruta_activa': false,
        'ultima_actualizacion': ServerValue.timestamp,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
