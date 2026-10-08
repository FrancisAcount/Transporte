// Copyright 2026 Transporte Escolar Maranata.
// Fuente única de verdad editable del panel administrativo.
//
// Mantiene copias vivas (mutables) de las semillas estáticas y las expone
// como [ChangeNotifier] para que todos los módulos se actualicen en vivo.
// Cada mutación intenta persistirse en Realtime Database (`panel/...`) y
// degrada a modo local cuando Firebase no está disponible (p. ej. tests).
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/bus.dart';
import '../models/driver_record.dart';
import '../models/foto_galeria.dart';
import '../models/route.dart' as modelos;
import '../models/safety_alert.dart';
import '../models/student_record.dart';
import 'driver_data.dart';
import 'mock_data.dart';
import 'student_data.dart';

/// Estado de la conexión de datos del panel administrativo.
enum EstadoSync { local, sincronizando, sincronizado, error }

/// Registro de una acción administrativa para la bitácora del panel.
class AccionAdmin {
  const AccionAdmin({required this.hora, required this.mensaje});

  final String hora;
  final String mensaje;
}

/// Almacén global editable: alumnos, conductores, flota, rutas y alertas.
///
/// Usa el patrón singleton ([instance]) para que el panel, los módulos y los
/// tests compartan la misma fuente. [restaurarSemilla] devuelve todo al
/// estado inicial de las semillas (se usa en `setUp` de los tests).
class AdminStore extends ChangeNotifier {
  AdminStore._() {
    restaurarSemilla(notificar: false);
  }

  static final AdminStore instance = AdminStore._();

  /// Alumnos activos (semilla inicial: 28 unidades × 16 = 448).
  late List<StudentRecord> alumnos;

  /// Conductores y asistentes (semilla inicial: 28 registros).
  late List<DriverRecord> conductores;

  /// Flota de vehículos (semilla inicial: 6 buses).
  late List<Bus> buses;

  /// Rutas del servicio (semilla inicial: 4 rutas).
  late List<modelos.Route> rutas;

  /// Bitácora de seguridad (la semilla recibe ids ALT-001…).
  late List<SafetyAlert> alertas;

  /// Fotos de la galería pública (subidas desde el panel, en base64).
  ///
  /// La vista de Galería muestra además las fotos fijas de `assets/images/`;
  /// esta lista guarda solo las que el administrador sube desde su dispositivo.
  late List<FotoGaleria> fotosGaleria;

  /// Últimas acciones del panel (máximo 40, sesión actual).
  final List<AccionAdmin> bitacora = <AccionAdmin>[];

  /// PIN de acceso al panel administrativo (cambiable en Ajustes).
  String pin = '2580';

  /// True cuando ya se leyó/escribió Firebase al menos una vez.
  bool sincronizado = false;

  /// Estado visible del chip de sincronización del panel.
  EstadoSync estadoSync = EstadoSync.local;

  /// True si la sesión administrativa ya superó el PIN (no se pide de nuevo).
  bool sesionAdmin = false;

  /// Vuelve a las semillas originales (datos de ejemplo) y limpia la sesión.
  ///
  /// No toca Firebase: es la base que `setUp` de los tests usa para aislar
  /// cada prueba. El botón «Restaurar» del panel llama a [restaurarTodo],
  /// que además re-sube la semilla a la nube.
  void restaurarSemilla({bool notificar = true}) {
    alumnos = List<StudentRecord>.from(StudentData.seed);
    conductores = List<DriverRecord>.from(DriverData.seed);
    buses = List<Bus>.from(MockData.buses);
    rutas = List<modelos.Route>.from(MockData.routes);
    alertas = [
      for (var i = 0; i < MockData.alerts.length; i++)
        _conId(MockData.alerts[i], 'ALT-${(i + 1).toString().padLeft(3, '0')}'),
    ];
    fotosGaleria = <FotoGaleria>[];
    bitacora.clear();
    sesionAdmin = false;
    _reindexarConductores();
    if (notificar) notifyListeners();
  }

  void _registrar(String mensaje) {
    final ahora = DateTime.now();
    final hora =
        '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
    bitacora.insert(0, AccionAdmin(hora: hora, mensaje: mensaje));
    if (bitacora.length > 40) bitacora.removeLast();
  }

  /// Genera un id libre del tipo `DRV-029` / `STU-449` / `ALT-007`.
  String nuevoId(String prefijo, Iterable<String> existentes) {
    final usados = existentes.toSet();
    var n = usados.length + 1;
    while (usados.contains('$prefijo-${n.toString().padLeft(3, '0')}')) {
      n++;
    }
    return '$prefijo-${n.toString().padLeft(3, '0')}';
  }

  /// Reconstruye `BUS-XX` → conductor para las vistas que resuelven el
  /// chofer por unidad ([StudentRecord.conductor]).
  void _reindexarConductores() {
    DriverData.porBus
      ..clear()
      ..addEntries(conductores.map((d) => MapEntry(d.bus, d)));
  }

  // ---------- Alumnos ----------
  bool agregarAlumno(StudentRecord a) {
    if (alumnos.any((x) => x.id == a.id)) return false;
    alumnos = [...alumnos, a];
    _registrar('Alumno agregado: ${a.nombreCompleto} (${a.busId})');
    _subir('alumnos', a.id, _alumnoJson(a));
    notifyListeners();
    return true;
  }

  bool actualizarAlumno(StudentRecord a) {
    final i = alumnos.indexWhere((x) => x.id == a.id);
    if (i < 0) return false;
    alumnos = [...alumnos..[i] = a];
    _registrar('Alumno editado: ${a.nombreCompleto}');
    _subir('alumnos', a.id, _alumnoJson(a));
    notifyListeners();
    return true;
  }

  bool eliminarAlumno(String id) {
    final i = alumnos.indexWhere((x) => x.id == id);
    if (i < 0) return false;
    final borrado = alumnos[i];
    alumnos = [...alumnos..removeAt(i)];
    _registrar('Alumno eliminado: ${borrado.nombreCompleto}');
    _borrar('alumnos', id);
    notifyListeners();
    return true;
  }

  // ---------- Conductores ----------
  bool agregarConductor(DriverRecord d) {
    if (conductores.any((x) => x.id == d.id)) return false;
    conductores = [d, ...conductores];
    _reindexarConductores();
    _registrar('Conductor agregado: ${d.nombre} (${d.bus})');
    _subir('conductores', d.id, _conductorJson(d));
    notifyListeners();
    return true;
  }

  bool actualizarConductor(DriverRecord d) {
    final i = conductores.indexWhere((x) => x.id == d.id);
    if (i < 0) return false;
    conductores = [...conductores..[i] = d];
    _reindexarConductores();
    _registrar('Conductor editado: ${d.nombre}');
    _subir('conductores', d.id, _conductorJson(d));
    notifyListeners();
    return true;
  }

  bool eliminarConductor(String id) {
    final i = conductores.indexWhere((x) => x.id == id);
    if (i < 0) return false;
    final borrado = conductores[i];
    conductores = [...conductores..removeAt(i)];
    _reindexarConductores();
    _registrar('Conductor eliminado: ${borrado.nombre}');
    _borrar('conductores', id);
    notifyListeners();
    return true;
  }

  // ---------- Flota ----------
  bool agregarBus(Bus b) {
    if (buses.any((x) => x.placa == b.placa)) return false;
    buses = [...buses, b];
    _registrar('Bus agregado: ${b.placa} (${b.marca} ${b.modelo})');
    _subir('buses', _clavePlaca(b.placa), _busJson(b));
    notifyListeners();
    return true;
  }

  bool actualizarBus(String placaOriginal, Bus b) {
    final i = buses.indexWhere((x) => x.placa == placaOriginal);
    if (i < 0) return false;
    if (b.placa != placaOriginal && buses.any((x) => x.placa == b.placa)) {
      return false;
    }
    buses = [...buses..[i] = b];
    _registrar('Bus editado: ${b.placa}');
    if (b.placa != placaOriginal) _borrar('buses', _clavePlaca(placaOriginal));
    _subir('buses', _clavePlaca(b.placa), _busJson(b));
    notifyListeners();
    return true;
  }

  bool eliminarBus(String placa) {
    final i = buses.indexWhere((x) => x.placa == placa);
    if (i < 0) return false;
    buses = [...buses..removeAt(i)];
    _registrar('Bus eliminado: $placa');
    _borrar('buses', _clavePlaca(placa));
    notifyListeners();
    return true;
  }

  // ---------- Rutas ----------
  bool agregarRuta(modelos.Route r) {
    if (rutas.any((x) => x.codigo == r.codigo)) return false;
    rutas = [...rutas, r];
    _registrar('Ruta agregada: ${r.codigo} (${r.nombre})');
    _subir('rutas', _claveCodigo(r.codigo), _rutaJson(r));
    notifyListeners();
    return true;
  }

  bool actualizarRuta(String codigoOriginal, modelos.Route r) {
    final i = rutas.indexWhere((x) => x.codigo == codigoOriginal);
    if (i < 0) return false;
    if (r.codigo != codigoOriginal &&
        rutas.any((x) => x.codigo == r.codigo)) {
      return false;
    }
    rutas = [...rutas..[i] = r];
    _registrar('Ruta editada: ${r.codigo}');
    if (r.codigo != codigoOriginal) {
      _borrar('rutas', _claveCodigo(codigoOriginal));
    }
    _subir('rutas', _claveCodigo(r.codigo), _rutaJson(r));
    notifyListeners();
    return true;
  }

  bool eliminarRuta(String codigo) {
    final i = rutas.indexWhere((x) => x.codigo == codigo);
    if (i < 0) return false;
    rutas = [...rutas..removeAt(i)];
    _registrar('Ruta eliminada: $codigo');
    _borrar('rutas', _claveCodigo(codigo));
    notifyListeners();
    return true;
  }

  // ---------- Alertas ----------
  bool agregarAlerta(SafetyAlert a) {
    if (alertas.any((x) => x.id == a.id)) return false;
    alertas = [a, ...alertas];
    _registrar('Alerta registrada: ${a.titulo}');
    _subir('alertas', a.id, _alertaJson(a));
    notifyListeners();
    return true;
  }

  bool marcarAtendida(String id) {
    final i = alertas.indexWhere((x) => x.id == id);
    if (i < 0) return false;
    final actual = alertas[i];
    final atendida = SafetyAlert(
      id: actual.id,
      hora: actual.hora,
      titulo: actual.titulo,
      detalle: actual.detalle,
      nivel: actual.nivel,
      ruta: actual.ruta,
      respondido: true,
    );
    alertas = [...alertas..[i] = atendida];
    _registrar('Alerta atendida: ${actual.titulo}');
    _subir('alertas', id, _alertaJson(atendida));
    notifyListeners();
    return true;
  }

  bool actualizarAlerta(SafetyAlert a) {
    final i = alertas.indexWhere((x) => x.id == a.id);
    if (i < 0) return false;
    alertas = [...alertas..[i] = a];
    _registrar('Alerta editada: ${a.titulo}');
    _subir('alertas', a.id, _alertaJson(a));
    notifyListeners();
    return true;
  }

  bool eliminarAlerta(String id) {
    final i = alertas.indexWhere((x) => x.id == id);
    if (i < 0) return false;
    final borrada = alertas[i];
    alertas = [...alertas..removeAt(i)];
    _registrar('Alerta eliminada: ${borrada.titulo}');
    _borrar('alertas', id);
    notifyListeners();
    return true;
  }

  // ---------- PIN y restauración ----------
  /// Cambia el PIN de acceso al panel y lo persiste en la nube.
  void cambiarPin(String nuevo) {
    pin = nuevo;
    _registrar('PIN del panel actualizado');
    try {
      _db?.ref('panel/config/pin').set(nuevo);
    } catch (_) {}
    notifyListeners();
  }

  /// Restaura la semilla en memoria y la vuelve a subir a Firebase.
  // ------------------------------------------------------------------
  // Galería (fotos subidas desde el panel, en base64)
  // ------------------------------------------------------------------

  /// Añade una foto a la galería pública. Devuelve `false` si el id ya existía.
  bool agregarFoto(FotoGaleria foto) {
    if (fotosGaleria.any((f) => f.id == foto.id)) return false;
    fotosGaleria.insert(0, foto);
    _registrar('Agregó foto «${foto.titulo}» a la galería');
    _subir('galeria', foto.id, _fotoJson(foto));
    notifyListeners();
    return true;
  }

  /// Actualiza título y descripción de una foto existente.
  void editarFoto(String id, {required String titulo, String descripcion = ''}) {
    final i = fotosGaleria.indexWhere((f) => f.id == id);
    if (i == -1) return;
    fotosGaleria[i] = fotosGaleria[i].copiarCon(titulo: titulo, descripcion: descripcion);
    _subir('galeria', id, _fotoJson(fotosGaleria[i]));
    notifyListeners();
  }

  /// Elimina una foto de la galería (y de la nube).
  void eliminarFoto(String id) {
    final i = fotosGaleria.indexWhere((f) => f.id == id);
    if (i == -1) return;
    final foto = fotosGaleria.removeAt(i);
    _registrar('Eliminó foto «${foto.titulo}» de la galería');
    _borrar('galeria', id);
    notifyListeners();
  }

  /// Siguiente id disponible para una nueva foto (FOTO-001, FOTO-002…).
  String siguienteIdFoto() {
    var max = 0;
    for (final f in fotosGaleria) {
      final n = int.tryParse(f.id.split('-').last) ?? 0;
      if (n > max) max = n;
    }
    return 'FOTO-${(max + 1).toString().padLeft(3, '0')}';
  }

  Future<void> restaurarTodo() async {
    restaurarSemilla();
    _registrar('Datos de ejemplo restaurados');
    await sincronizar(forzarSiembra: true);
  }

  // ---------- Sincronización con Firebase ----------
  /// Base de datos activa o `null` cuando Firebase no está inicializado
  /// (p. ej. en tests de widget): el panel funciona 100 % en local.
  FirebaseDatabase? get _db {
    try {
      return FirebaseDatabase.instance;
    } catch (_) {
      return null;
    }
  }

  bool _sincronizando = false;

  /// Carga las colecciones desde `panel/...`; si un nodo está vacío, lo
  /// siembra con los datos de ejemplo para que la nube quede inicializada.
  ///
  /// Es idempotente y segura de llamar varias veces: con [forzarSiembra] en
  /// true se re-sube la semilla (botón «Restaurar» del panel).
  Future<void> sincronizar({bool forzarSiembra = false}) async {
    final db = _db;
    if (db == null || _sincronizando) return;
    _sincronizando = true;
    estadoSync = EstadoSync.sincronizando;
    notifyListeners();
    try {
      final semillado = await _estaSemillado(db);
      if (!semillado || forzarSiembra) {
        await _sembrar(db);
        await db.ref('panel/meta/semillado').set(true);
      } else {
        await _cargar(db);
      }
      sincronizado = true;
      estadoSync = EstadoSync.sincronizado;
    } catch (_) {
      estadoSync = EstadoSync.error;
    } finally {
      _sincronizando = false;
      notifyListeners();
    }
  }

  Future<bool> _estaSemillado(FirebaseDatabase db) async {
    try {
      final snap = await db.ref('panel/meta/semillado').get();
      return snap.value == true;
    } catch (_) {
      return true; // Ante la duda no se sobrescribe la nube.
    }
  }

  Future<void> _sembrar(FirebaseDatabase db) async {
    await db.ref('panel/alumnos').set(_mapa(alumnos, (a) => a.id, _alumnoJson));
    await db
        .ref('panel/conductores')
        .set(_mapa(conductores, (d) => d.id, _conductorJson));
    await db.ref('panel/buses').set(_mapa(buses, (b) => b.placa, _busJson));
    await db.ref('panel/rutas').set(_mapa(rutas, (r) => r.codigo, _rutaJson));
    await db.ref('panel/alertas').set(_mapa(alertas, (a) => a.id, _alertaJson));
    await db.ref('panel/galeria').set(_mapa(fotosGaleria, (f) => f.id, _fotoJson));
    await db.ref('panel/config/pin').set(pin);
  }

  Map<String, Map<String, dynamic>> _mapa<T>(
    List<T> lista,
    String Function(T) clave,
    Map<String, dynamic> Function(T) json,
  ) {
    final mapa = <String, Map<String, dynamic>>{};
    for (final e in lista) {
      mapa[clave(e)] = json(e);
    }
    return mapa;
  }

  Future<void> _cargar(FirebaseDatabase db) async {
    final snapAlu = await db.ref('panel/alumnos').get();
    final listaAlu = _lista(snapAlu.value, _alumnoDe);
    if (listaAlu.isNotEmpty) alumnos = listaAlu;
    final snapCon = await db.ref('panel/conductores').get();
    final listaCon = _lista(snapCon.value, _conductorDe);
    if (listaCon.isNotEmpty) {
      conductores = listaCon;
      _reindexarConductores();
    }
    final snapBus = await db.ref('panel/buses').get();
    final listaBus = _lista(snapBus.value, _busDe);
    if (listaBus.isNotEmpty) buses = listaBus;
    final snapRut = await db.ref('panel/rutas').get();
    final listaRut = _lista(snapRut.value, _rutaDe);
    if (listaRut.isNotEmpty) rutas = listaRut;
    final snapAle = await db.ref('panel/alertas').get();
    final listaAle = _lista(snapAle.value, _alertaDe);
    if (listaAle.isNotEmpty) alertas = listaAle;
    try {
      final snapGal = await db.ref('panel/galeria').get();
      final listaGal = _lista(snapGal.value, _fotoDe);
      fotosGaleria = listaGal;
    } catch (_) {}
    try {
      final snapPin = await db.ref('panel/config/pin').get();
      final valorPin = snapPin.value;
      if (valorPin is String && valorPin.length >= 4) pin = valorPin;
    } catch (_) {}
  }

  List<T> _lista<T>(Object? valor, T Function(Map<String, dynamic>) parse) {
    if (valor is! Map) return <T>[];
    final salida = <T>[];
    for (final crudo in valor.values) {
      try {
        if (crudo is Map) {
          salida.add(parse(Map<String, dynamic>.from(crudo)));
        }
      } catch (_) {}
    }
    return salida;
  }

  // ---------- Escritura directa (por registro) ----------
  /// Escribe un registro en `panel/<coleccion>/<clave>`. Silencioso si no
  /// hay Firebase: el panel sigue funcionando en local.
  void _subir(
    String coleccion,
    String clave,
    Map<String, dynamic> datos,
  ) {
    final db = _db;
    if (db == null) return;
    try {
      db.ref('panel/$coleccion/$clave').set(datos);
    } catch (_) {}
  }

  /// Borra un registro de `panel/<coleccion>/<clave>`.
  void _borrar(String coleccion, String clave) {
    final db = _db;
    if (db == null) return;
    try {
      db.ref('panel/$coleccion/$clave').remove();
    } catch (_) {}
  }

  /// Las claves de Firebase no admiten `.` `#` `$` `[` `]` `/`.
  String _clavePlaca(String placa) =>
      placa.replaceAll(RegExp(r'[.#$/\[\]]'), '-');

  String _claveCodigo(String codigo) =>
      codigo.replaceAll(RegExp(r'[.#$/\[\]]'), '-');

  // ---------- Serialización ----------
  Map<String, dynamic> _alumnoJson(StudentRecord a) => {
        'id': a.id,
        'nombres': a.nombres,
        'apellidoPaterno': a.apellidoPaterno,
        'apellidoMaterno': a.apellidoMaterno,
        'grado': a.grado,
        'parada': a.parada,
        'estado': a.estado.name,
        'busId': a.busId,
        'telefonoRepresentante': a.telefonoRepresentante,
      };

  StudentRecord _alumnoDe(Map<String, dynamic> m) => StudentRecord(
        id: '${m['id'] ?? ''}',
        nombres: '${m['nombres'] ?? ''}',
        apellidoPaterno: '${m['apellidoPaterno'] ?? ''}',
        apellidoMaterno: '${m['apellidoMaterno'] ?? ''}',
        grado: '${m['grado'] ?? ''}',
        parada: '${m['parada'] ?? ''}',
        estado: _estadoAlumno('${m['estado'] ?? ''}'),
        busId: '${m['busId'] ?? ''}',
        telefonoRepresentante: '${m['telefonoRepresentante'] ?? ''}',
      );

  StudentStatus _estadoAlumno(String nombre) {
    try {
      return StudentStatus.values.byName(nombre);
    } catch (_) {
      return StudentStatus.enEscuela;
    }
  }

  Map<String, dynamic> _conductorJson(DriverRecord d) => {
        'id': d.id,
        'nombre': d.nombre,
        'cedula': d.cedula,
        'telefono': d.telefono,
        'bus': d.bus,
        'licencia': d.licencia,
        'ruta': d.ruta,
        'cargo': d.cargo,
        'aniosExperiencia': d.aniosExperiencia,
        'estado': d.estado.name,
      };

  DriverRecord _conductorDe(Map<String, dynamic> m) => DriverRecord(
        id: '${m['id'] ?? ''}',
        nombre: '${m['nombre'] ?? ''}',
        cedula: '${m['cedula'] ?? ''}',
        telefono: '${m['telefono'] ?? ''}',
        bus: '${m['bus'] ?? ''}',
        licencia: '${m['licencia'] ?? ''}',
        ruta: '${m['ruta'] ?? ''}',
        cargo: '${m['cargo'] ?? ''}',
        aniosExperiencia: int.tryParse('${m['aniosExperiencia'] ?? 0}') ?? 0,
        estado: _estadoConductor('${m['estado'] ?? ''}'),
      );

  DriverStatus _estadoConductor(String nombre) {
    try {
      return DriverStatus.values.byName(nombre);
    } catch (_) {
      return DriverStatus.disponible;
    }
  }

  Map<String, dynamic> _busJson(Bus b) => {
        'placa': b.placa,
        'marca': b.marca,
        'modelo': b.modelo,
        'capacidad': b.capacidad,
        'conductor': b.conductor,
        'ruta': b.ruta,
        'estado': b.estado.name,
        'kilometraje': b.kilometraje,
        'proximoMantenimiento': b.proximoMantenimiento,
      };

  Bus _busDe(Map<String, dynamic> m) => Bus(
        placa: '${m['placa'] ?? ''}',
        marca: '${m['marca'] ?? ''}',
        modelo: '${m['modelo'] ?? ''}',
        capacidad: int.tryParse('${m['capacidad'] ?? 0}') ?? 0,
        conductor: '${m['conductor'] ?? ''}',
        ruta: '${m['ruta'] ?? ''}',
        estado: _estadoBus('${m['estado'] ?? ''}'),
        kilometraje: int.tryParse('${m['kilometraje'] ?? 0}') ?? 0,
        proximoMantenimiento: '${m['proximoMantenimiento'] ?? ''}',
      );

  BusStatus _estadoBus(String nombre) {
    try {
      return BusStatus.values.byName(nombre);
    } catch (_) {
      return BusStatus.enGaraje;
    }
  }

  Map<String, dynamic> _rutaJson(modelos.Route r) => {
        'codigo': r.codigo,
        'nombre': r.nombre,
        'zona': r.zona,
        'bus': r.bus,
        'conductor': r.conductor,
        'estudiantes': r.estudiantes,
        'horaSalida': r.horaSalida,
        'horaRegreso': r.horaRegreso,
        'estado': r.estado,
        'primerPunto': r.primerPunto,
        'ultimoPunto': r.ultimoPunto,
      };

  modelos.Route _rutaDe(Map<String, dynamic> m) => modelos.Route(
        codigo: '${m['codigo'] ?? ''}',
        nombre: '${m['nombre'] ?? ''}',
        zona: '${m['zona'] ?? ''}',
        bus: '${m['bus'] ?? ''}',
        conductor: '${m['conductor'] ?? ''}',
        estudiantes: int.tryParse('${m['estudiantes'] ?? 0}') ?? 0,
        horaSalida: '${m['horaSalida'] ?? ''}',
        horaRegreso: '${m['horaRegreso'] ?? ''}',
        estado: '${m['estado'] ?? ''}',
        primerPunto: '${m['primerPunto'] ?? ''}',
        ultimoPunto: '${m['ultimoPunto'] ?? ''}',
      );

  Map<String, dynamic> _alertaJson(SafetyAlert a) => {
        'id': a.id,
        'hora': a.hora,
        'titulo': a.titulo,
        'detalle': a.detalle,
        'nivel': a.nivel.name,
        'ruta': a.ruta,
        'respondido': a.respondido,
      };

  Map<String, dynamic> _fotoJson(FotoGaleria f) => {
        'id': f.id,
        'titulo': f.titulo,
        'descripcion': f.descripcion,
        'datosBase64': f.datosBase64,
        if (f.fechaSubida != null) 'fechaSubida': f.fechaSubida,
      };

  FotoGaleria _fotoDe(Map<String, dynamic> m) => FotoGaleria.fromJson(m);

  SafetyAlert _alertaDe(Map<String, dynamic> m) => SafetyAlert(
        id: '${m['id'] ?? ''}',
        hora: '${m['hora'] ?? ''}',
        titulo: '${m['titulo'] ?? ''}',
        detalle: '${m['detalle'] ?? ''}',
        nivel: _nivelAlerta('${m['nivel'] ?? ''}'),
        ruta: '${m['ruta'] ?? ''}',
        respondido: m['respondido'] == true,
      );

  AlertLevel _nivelAlerta(String nombre) {
    try {
      return AlertLevel.values.byName(nombre);
    } catch (_) {
      return AlertLevel.info;
    }
  }

  SafetyAlert _conId(SafetyAlert a, String id) => SafetyAlert(
        id: id,
        hora: a.hora,
        titulo: a.titulo,
        detalle: a.detalle,
        nivel: a.nivel,
        ruta: a.ruta,
        respondido: a.respondido,
      );
}
