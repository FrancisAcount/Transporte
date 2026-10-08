import '../models/student_record.dart';

/// Semilla de matrícula: 28 unidades × 16 alumnos = 448 registros.
///
/// Cada alumno se enlaza con una unidad real del padrón de conductores a
/// través de `busId`: el nombre del chofer se resuelve con
/// [StudentRecord.conductor], de modo que la vista nunca duplica datos.
class StudentData {
  StudentData._();

  /// Alumnos que muestra la lista tipo Excel de cada unidad.
  static const int alumnosPorBus = 16;

  /// Unidades del registro (el mismo padrón que DriverData: BUS-1 … BUS-28).
  static const int totalBuses = 28;

  static final List<StudentRecord> seed = _build();

  /// Paradas del recorrido, en orden, para asignarlas en ciclo a los alumnos.
  static const List<String> paradas = [
    'Av. Los Pinos',
    'Av. 6 de Diciembre',
    'Calle Las Acacias',
    'Av. Francisco de Orellana',
    'Urbanización El Carmen',
    'Av. Amazonas y NN.UU.',
    'Barrio La Dolorosa',
    'Av. República de Panamá',
    'Parque La Carolina',
    'Mercado Central',
    'Av. Juan Tanca Marengo',
    'Zona Valle Verde',
  ];

  /// Cursos del turno de la mañana (ciclo por alumno).
  ///
  /// Es público para que el panel administrativo ofrezca el mismo catálogo
  /// en el formulario de alta/edición de alumnos.
  static const List<String> grados = [
    '8vo A',
    '8vo B',
    '9no A',
    '9no B',
    '10mo A',
    '10mo B',
  ];

  /// Nombres propios (60 para variar la combinación en las 448 filas).
  static const List<String> _nombres = [
    'Mateo',
    'Valeria',
    'Sebastián',
    'Camila',
    'Josué',
    'Antonella',
    'Emiliano',
    'Katherine',
    'Dylan',
    'Isabella',
    'Bryan',
    'Génesis',
    'Daniela',
    'Iván',
    'Fernanda',
    'Nicolás',
    'Sarah',
    'Joaquín',
    'Alessandra',
    'Tomás',
    'Renata',
    'Gabriel',
    'Luciana',
    'Ángel',
    'Paulina',
    'Rodrigo',
    'Ma. Fernanda',
    'Esteban',
    'Ximena',
    'Kevin',
    'Alisson',
    'David',
    'Yomira',
    'Carlos',
    'Wilson',
    'Andrea',
    'Franklin',
    'Julia',
    'Erick',
    'Naomi',
    'Samuel',
    'María José',
    'Andrés',
    'Patricio',
    'José',
    'Marilú',
    'Edison',
    'Mercedes',
    'Jhon',
    'Dayana',
    'Brandon',
    'Fátima',
    'Diego',
    'Melany',
    'Josselyn',
    'Alejandro',
    'Sara',
    'Cristhian',
    'Evelyn',
    'Luis',
  ];

  /// Apellidos paternos (41).
  static const List<String> _paternos = [
    'Andrade',
    'Corozo',
    'Molina',
    'Reyes',
    'Bermúdez',
    'Zambrano',
    'Chuquimarca',
    'Quishpe',
    'Pincay',
    'Yánez',
    'Moncayo',
    'Páez',
    'Rocafuerte',
    'Cabrera',
    'Aguayo',
    'Escalante',
    'Villalva',
    'Maldonado',
    'Ulloa',
    'Guerrero',
    'Cedeño',
    'Naranjo',
    'Ochoa',
    'Zapata',
    'Cisneros',
    'Farfán',
    'Villavicencio',
    'Ordóñez',
    'Saltos',
    'Betancourt',
    'Montero',
    'Alarcón',
    'Tello',
    'Morocho',
    'Caicedo',
    'Uyaguari',
    'Panchana',
    'Cumbicus',
    'Intriago',
    'Vélez',
    'Sánchez',
  ];

  /// Apellidos maternos (43).
  static const List<String> _maternos = [
    'Quiñónez',
    'Naranjo',
    'Pazos',
    'Vega',
    'Cifuentes',
    'Mero',
    'Torre',
    'Londoño',
    'Tomalá',
    'Cedeño',
    'Salazar',
    'Intriago',
    'Mendieta',
    'Villavicencio',
    'Tenesaca',
    'Vinueza',
    'Chimborazo',
    'Pincay',
    'Caicedo',
    'Fajardo',
    'Ayoví',
    'Sarmiento',
    'Burbano',
    'Morocho',
    'Cumbicus',
    'Bravo',
    'Mendoza',
    'Rivas',
    'Cornejo',
    'Loor',
    'Paladín',
    'Reasco',
    'Vayas',
    'Bailón',
    'Vera',
    'Rengifo',
    'Chicaiza',
    'Carrión',
    'Arias',
    'Montalvo',
    'Delgado',
    'Zamora',
    'Herrera',
  ];

  /// Estados del ciclo (el ausente es el menos frecuente).
  static const List<StudentStatus> _estados = [
    StudentStatus.enEscuela,
    StudentStatus.recogido,
    StudentStatus.enRuta,
    StudentStatus.enEscuela,
    StudentStatus.enEscuela,
    StudentStatus.ausente,
  ];

  /// Genera los 448 alumnos: 16 por cada una de las 28 unidades.
  static List<StudentRecord> _build() {
    final alumnos = <StudentRecord>[];
    for (var u = 1; u <= totalBuses; u++) {
      for (var i = 0; i < alumnosPorBus; i++) {
        final j = (u - 1) * alumnosPorBus + i;
        alumnos.add(StudentRecord(
          id: 'STU-${(j + 1).toString().padLeft(3, '0')}',
          nombres: _nombres[j % _nombres.length],
          apellidoPaterno: _paternos[j % _paternos.length],
          apellidoMaterno: _maternos[j % _maternos.length],
          grado: grados[j % grados.length],
          parada: paradas[j % paradas.length],
          estado: _estados[j % _estados.length],
          busId: 'BUS-$u',
          telefonoRepresentante: _telefono(j),
        ));
      }
    }
    return alumnos;
  }

  /// Teléfono del representante en formato `+593 9X XXX XXXX` (determinista).
  static String _telefono(int j) =>
      '+593 9${(j * 7) % 90 + 10} ${(j * 37) % 900 + 100} ${(j * 97) % 9000 + 1000}';
}
