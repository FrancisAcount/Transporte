/// Ficha técnica de un conductor o asistente.
class Driver {
  const Driver({
    required this.nombre,
    required this.cedula,
    required this.telefono,
    required this.tipo,
    required this.ruta,
    required this.aniosExperiencia,
    required this.estado,
    required this.licencia,
  });

  final String nombre;
  final String cedula;
  final String telefono;
  final String tipo; // Conductor / Asistente
  final String ruta;
  final int aniosExperiencia;
  final bool estado; // true = activo
  final String licencia;
}
