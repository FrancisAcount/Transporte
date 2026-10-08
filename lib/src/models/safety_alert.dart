import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Niveles de severidad de la bitácora de alertas.
enum AlertLevel { critical, warning, info }

extension AlertLevelX on AlertLevel {
  String get label => switch (this) {
        AlertLevel.critical => 'Crítica',
        AlertLevel.warning => 'Advertencia',
        AlertLevel.info => 'Informativa',
      };

  Color get color => switch (this) {
        AlertLevel.critical => AppColors.guindo,
        AlertLevel.warning => AppColors.warning,
        AlertLevel.info => AppColors.info,
      };
}

/// Evento registrado en la bitácora de seguridad.
class SafetyAlert {
  const SafetyAlert({
    this.id = '',
    required this.hora,
    required this.titulo,
    required this.detalle,
    required this.nivel,
    required this.ruta,
    required this.respondido,
  });

  /// Identificador estable para editar/eliminar desde el panel administrativo.
  /// La semilla lo deja vacío y el [AdminStore] lo asigna al cargar.
  final String id;

  final String hora;
  final String titulo;
  final String detalle;
  final AlertLevel nivel;
  final String ruta;
  final bool respondido;
}
