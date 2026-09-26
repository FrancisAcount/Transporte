import '../models/bus.dart';
import '../models/driver.dart';
import '../models/route.dart';
import '../models/safety_alert.dart';
import '../models/student.dart';

/// Datos simulados (mock) que alimentan todas las pantallas.
/// En producción se sustituirían por el consumo de una API o base de datos.
class MockData {
  MockData._();

  // ---------- Rutas ----------
  static const List<Route> routes = [
    Route(
      codigo: 'RT-01',
      nombre: 'Ruta Norte – Colegio Maranata',
      zona: 'Zona Norte',
      bus: 'ABC-123',
      conductor: 'Carlos Mendoza',
      estudiantes: 34,
      horaSalida: '06:30',
      horaRegreso: '13:30',
      estado: 'En curso',
      primerPunto: 'Av. Los Pinos',
      ultimoPunto: 'Colegio Maranata',
    ),
    Route(
      codigo: 'RT-02',
      nombre: 'Ruta Centro – Colegio Maranata',
      zona: 'Zona Centro',
      bus: 'XYZ-778',
      conductor: 'Lucía Ramírez',
      estudiantes: 28,
      horaSalida: '06:45',
      horaRegreso: '13:45',
      estado: 'En curso',
      primerPunto: 'Parque Central',
      ultimoPunto: 'Colegio Maranata',
    ),
    Route(
      codigo: 'RT-03',
      nombre: 'Ruta Sur Oriental',
      zona: 'Zona Sur',
      bus: 'JKL-450',
      conductor: 'Andrés Gómez',
      estudiantes: 31,
      horaSalida: '07:00',
      horaRegreso: '14:00',
      estado: 'Programada',
      primerPunto: 'Barrio El Encino',
      ultimoPunto: 'Colegio Maranata',
    ),
    Route(
      codigo: 'RT-04',
      nombre: 'Ruta Oeste – Turno tarde',
      zona: 'Zona Oeste',
      bus: 'MNP-909',
      conductor: 'Sofía Herrera',
      estudiantes: 26,
      horaSalida: '12:15',
      horaRegreso: '18:15',
      estado: 'Finalizada',
      primerPunto: 'Colonia Las Flores',
      ultimoPunto: 'Colegio Maranata',
    ),
  ];
  // ---------- Flota ----------
  static const List<Bus> buses = [
    Bus(placa: 'ABC-123', marca: 'Mercedes-Benz', modelo: 'LO 1118', capacidad: 40, conductor: 'Carlos Mendoza', ruta: 'RT-01', estado: BusStatus.enRuta, kilometraje: 128450, proximoMantenimiento: '18/10/2026'),
    Bus(placa: 'XYZ-778', marca: 'Volkswagen', modelo: 'Cobus 17', capacidad: 36, conductor: 'Lucía Ramírez', ruta: 'RT-02', estado: BusStatus.enRuta, kilometraje: 96320, proximoMantenimiento: '02/11/2026'),
    Bus(placa: 'JKL-450', marca: 'Scania', modelo: 'K230', capacidad: 42, conductor: 'Andrés Gómez', ruta: 'RT-03', estado: BusStatus.enGaraje, kilometraje: 210880, proximoMantenimiento: '25/09/2026'),
    Bus(placa: 'MNP-909', marca: 'Toyota', modelo: 'Coaster', capacidad: 30, conductor: 'Sofía Herrera', ruta: 'RT-04', estado: BusStatus.mantenimiento, kilometraje: 54730, proximoMantenimiento: 'Hoy'),
    Bus(placa: 'PQR-321', marca: 'Hino', modelo: 'D17C', capacidad: 38, conductor: 'Sin asignar', ruta: '—', estado: BusStatus.fueraDeServicio, kilometraje: 302115, proximoMantenimiento: '30/09/2026'),
    Bus(placa: 'STU-654', marca: 'Ford', modelo: 'Transit 350', capacidad: 28, conductor: 'Jorge Peña', ruta: 'Reserva', estado: BusStatus.enGaraje, kilometraje: 71420, proximoMantenimiento: '12/12/2026'),
  ];

  // ---------- Conductores y personal ----------
  static const List<Driver> drivers = [
    Driver(nombre: 'Carlos Mendoza', cedula: '0912345678', telefono: '+593 99 112 3344', tipo: 'Conductor', ruta: 'RT-01', aniosExperiencia: 12, estado: true, licencia: 'T1 – vigente'),
    Driver(nombre: 'Lucía Ramírez', cedula: '0923456789', telefono: '+593 98 887 2211', tipo: 'Conductor', ruta: 'RT-02', aniosExperiencia: 8, estado: true, licencia: 'T1 – vigente'),
    Driver(nombre: 'Andrés Gómez', cedula: '0934567890', telefono: '+593 97 445 6677', tipo: 'Conductor', ruta: 'RT-03', aniosExperiencia: 5, estado: true, licencia: 'T1 – vigente'),
    Driver(nombre: 'Sofía Herrera', cedula: '0945678901', telefono: '+593 96 334 8899', tipo: 'Conductor', ruta: 'RT-04', aniosExperiencia: 6, estado: true, licencia: 'T1 – vigente'),
    Driver(nombre: 'Jorge Peña', cedula: '0956789012', telefono: '+593 95 221 5566', tipo: 'Conductor', ruta: 'Reserva', aniosExperiencia: 3, estado: false, licencia: 'T1 – por renovar'),
    Driver(nombre: 'María Dolores Chiriaco', cedula: '1718192021', telefono: '+593 94 778 9900', tipo: 'Asistente', ruta: 'RT-01', aniosExperiencia: 9, estado: true, licencia: 'No aplica'),
    Driver(nombre: 'Rosa Villavicencio', cedula: '1314151617', telefono: '+593 93 660 5544', tipo: 'Asistente', ruta: 'RT-02', aniosExperiencia: 4, estado: true, licencia: 'No aplica'),
  ];
  // ---------- Estudiantes ----------
  static const List<Student> students = [
    Student(nombre: 'Daniela Ríos', grado: '8vo A', ruta: 'RT-01', parada: 'Av. Los Pinos', estado: 'En la escuela'),
    Student(nombre: 'Mateo Cárdenas', grado: '6to B', ruta: 'RT-01', parada: 'Calle 12', estado: 'Recogido'),
    Student(nombre: 'Valeria Ordóñez', grado: '10mo A', ruta: 'RT-02', parada: 'Parque Central', estado: 'En la escuela'),
    Student(nombre: 'Sebastián Lara', grado: '7mo A', ruta: 'RT-02', parada: 'Mercado Municipal', estado: 'En ruta'),
    Student(nombre: 'Camila Zambrano', grado: '9no B', ruta: 'RT-03', parada: 'Barrio El Encino', estado: 'Programado'),
    Student(nombre: 'Santiago Reasco', grado: '5to A', ruta: 'RT-03', parada: 'Av. Sur', estado: 'Programado'),
    Student(nombre: 'Isabella Tongoy', grado: '11mo A', ruta: 'RT-04', parada: 'Colonia Las Flores', estado: 'Retirado'),
    Student(nombre: 'Nicolás Vera', grado: '4to B', ruta: 'RT-04', parada: 'Av. Oeste', estado: 'Retirado'),
  ];

  // ---------- Alertas ----------
  static const List<SafetyAlert> alerts = [
    SafetyAlert(hora: '07:42', titulo: 'Retraso en ruta RT-03', detalle: 'Tráfico denso en la Av. Sur; llegada estimada 15 min más tarde.', nivel: AlertLevel.warning, ruta: 'RT-03', respondido: true),
    SafetyAlert(hora: '07:18', titulo: 'Freno con desgaste', detalle: 'Autobús MNP-909 retirado de servicio para revisión mecánica.', nivel: AlertLevel.critical, ruta: 'RT-04', respondido: true),
    SafetyAlert(hora: '06:58', titulo: 'Estudiante no reportado', detalle: 'Falta confirmación de recogida de Santiago Reasco.', nivel: AlertLevel.critical, ruta: 'RT-03', respondido: false),
    SafetyAlert(hora: '06:30', titulo: 'Salida de ruta RT-01', detalle: 'Salida puntual con 34 estudiantes a bordo.', nivel: AlertLevel.info, ruta: 'RT-01', respondido: true),
    SafetyAlert(hora: '13:40', titulo: 'Regreso completado', detalle: 'La ruta RT-04 finalizó sin incidencias.', nivel: AlertLevel.info, ruta: 'RT-04', respondido: true),
    SafetyAlert(hora: '14:05', titulo: 'Documento por vencer', detalle: 'Licencia T1 del conductor Jorge Peña próxima a vencer.', nivel: AlertLevel.warning, ruta: 'Reserva', respondido: false),
  ];
}
