import 'package:flutter/material.dart';

import '../data/driver_data.dart';
import '../theme/app_colors.dart';
import 'driver_record.dart';

/// Estados de ubicación del alumno dentro del recorrido escolar.
enum StudentStatus { enEscuela, recogido, enRuta, ausente }

/// Ficha del alumno usada por el módulo de matrícula.
///
/// A diferencia del modelo [Student] global (que solo alimenta el Panel de
/// Inicio), este desglosa los tres nombres, guarda la unidad asignada como id
/// de bus y resuelve el chofer a través de [DriverData].
class StudentRecord {
  StudentRecord({
    required this.id,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.grado,
    required this.parada,
    required this.estado,
    required this.busId,
    this.telefonoRepresentante = '+593 99 000 0000',
  });

  final String id;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String grado;
  final String parada;
  final StudentStatus estado;

  /// Unidad asignada en formato `BUS-XX`. Es la clave de enlace con la flota.
  final String busId;

  /// Contacto del representante: destino del botón de WhatsApp.
  final String telefonoRepresentante;

  /// Chofer responsable de la unidad, resuelto desde la semilla compartida.
  ///
  /// Puede ser nulo si la unidad no tiene conductor registrado.
  DriverRecord? get conductor => DriverData.porBus[busId];

  /// Nombre completo en el orden habitual: nombres + apellidos.
  String get nombreCompleto => '$nombres $apellidoPaterno $apellidoMaterno';

  /// Iniciales para el avatar (primer nombre + apellido paterno).
  String get iniciales => '${nombres[0]}${apellidoPaterno[0]}'.toUpperCase();

  /// Texto del estado para chips y encabezados.
  String get estadoLabel => switch (estado) {
        StudentStatus.enEscuela => 'En la escuela',
        StudentStatus.recogido => 'Recogido',
        StudentStatus.enRuta => 'En ruta',
        StudentStatus.ausente => 'Ausente',
      };

  /// Color de la franja lateral de la tarjeta.
  ///
  /// Azul = En la escuela, Verde = Recogido, Naranja = En ruta y Gris = Ausente.
  Color get colorEstado => switch (estado) {
        StudentStatus.enEscuela => AppColors.navy,
        StudentStatus.recogido => AppColors.success,
        StudentStatus.enRuta => AppColors.warning,
        StudentStatus.ausente => AppColors.textMuted,
      };

  /// True cuando el alumno está ausente: el avatar usa el rojo institucional.
  bool get esAusente => estado == StudentStatus.ausente;

  /// Coincidencia del buscador por nombres o apellidos.
  ///
  /// También acepta la unidad para poder buscar "bus-7" y encontrar a todos
  /// los alumnos de esa unidad.
  bool coincide(String q) {
    final t = q.trim().toLowerCase();
    if (t.isEmpty) return true;
    return '$nombres $apellidoPaterno $apellidoMaterno $busId $grado'
        .toLowerCase()
        .contains(t);
  }
}