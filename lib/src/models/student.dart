/// Alumno asignado a una ruta escolar.
///
/// Modelo ligero que alimenta el Panel de Inicio y el resto de pantallas
/// heredadas. El módulo "Registro de Estudiantes" usa [StudentRecord], que
/// añade los tres nombres desglosados y el enlace con la unidad.
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
