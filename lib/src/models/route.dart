/// Ruta escolar con su trazado simulado.
class Route {
  const Route({
    required this.codigo,
    required this.nombre,
    required this.zona,
    required this.bus,
    required this.conductor,
    required this.estudiantes,
    required this.horaSalida,
    required this.horaRegreso,
    required this.estado,
    required this.primerPunto,
    required this.ultimoPunto,
  });

  final String codigo;
  final String nombre;
  final String zona;
  final String bus;
  final String conductor;
  final int estudiantes;
  final String horaSalida;
  final String horaRegreso;
  final String estado; // En curso / Programada / Finalizada
  final String primerPunto;
  final String ultimoPunto;
}
