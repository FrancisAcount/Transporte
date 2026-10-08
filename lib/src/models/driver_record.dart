import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Estados operativos posibles de un conductor.
enum DriverStatus { enRuta, disponible, ausente }

/// Ficha enriquecida del conductor.
///
/// Añade los campos que exige el módulo (bus asignado y estado operativo)
/// sobre los datos ya existentes, sin alterar el modelo global para que el
/// resto de pantallas sigan intactas.
///
/// Vive en `models/` porque tanto el directorio de conductores como el de
/// estudiantes necesitan leer el bus y el nombre del chofer para vincular la
/// matrícula con la flota.
class DriverRecord {
  DriverRecord({
    required this.id,
    required this.nombre,
    required this.cedula,
    required this.telefono,
    required this.bus,
    required this.licencia,
    required this.ruta,
    required this.cargo,
    required this.aniosExperiencia,
    required this.estado,
  });

  final String id;
  final String nombre;
  final String cedula;
  final String telefono;
  final String bus;
  final String licencia;
  final String ruta;
  final String cargo;
  final int aniosExperiencia;
  final DriverStatus estado;

  /// Texto del estado, mostrado en chips y en el diálogo de detalle.
  String get estadoLabel => switch (estado) {
        DriverStatus.enRuta => 'En Ruta',
        DriverStatus.disponible => 'Disponible',
        DriverStatus.ausente => 'Ausente',
      };

  /// Color corporativo asociado al estado.
  ///
  /// Verde = Disponible, Azul institucional = En Ruta y Guindo = Ausente.
  /// Son los mismos tres tonos que usa la franja lateral de la tarjeta.
  Color get colorEstado => switch (estado) {
        DriverStatus.enRuta => AppColors.navy,
        DriverStatus.disponible => AppColors.success,
        DriverStatus.ausente => AppColors.guindo,
      };

  /// True cuando el conductor está ausente: el avatar usa el rojo
  /// institucional en lugar del azul de marca.
  bool get esAusente => estado == DriverStatus.ausente;

  /// Iniciales para el avatar circular.
  String get iniciales => nombre.split(' ').take(2).map((w) => w[0]).join().toUpperCase();

  /// Coincidencia del buscador por nombre, bus, cédula, ruta o licencia.
  bool coincide(String q) {
    final t = q.trim().toLowerCase();
    if (t.isEmpty) return true;
    return '$nombre $bus $cedula $ruta $licencia $cargo'.toLowerCase().contains(t);
  }
}