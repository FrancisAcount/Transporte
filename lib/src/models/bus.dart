/// Estados posibles de un autobús dentro de la flota.
enum BusStatus { enRuta, enGaraje, mantenimiento, fueraDeServicio }

extension BusStatusX on BusStatus {
  String get label => switch (this) {
        BusStatus.enRuta => 'En ruta',
        BusStatus.enGaraje => 'En garaje',
        BusStatus.mantenimiento => 'Mantenimiento',
        BusStatus.fueraDeServicio => 'Fuera de servicio',
      };
}

/// Bus-school con sus datos de control.
class Bus {
  const Bus({
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.capacidad,
    required this.conductor,
    required this.ruta,
    required this.estado,
    required this.kilometraje,
    required this.proximoMantenimiento,
  });

  final String placa;
  final String marca;
  final String modelo;
  final int capacidad;
  final String conductor;
  final String ruta;
  final BusStatus estado;
  final int kilometraje;
  final String proximoMantenimiento;
}
