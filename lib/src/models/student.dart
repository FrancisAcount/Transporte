/// Alumno asignado a una ruta escolar.
class Student {
  const Student({
    required this.nombre,
    required this.grado,
    required this.ruta,
    required this.parada,
    required this.estado,
  });

  final String nombre;
  final String grado;
  final String ruta;
  final String parada;
  final String estado; // En ruta / Recogido / En la escuela / Retirado
}
