import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tarjeta de unidad (BUS-XX) para el listado de buses.
///
/// Diseño compacto y profesional: sin sombras pesadas, con bordes sutiles
/// y jerarquía visual clara (número de bus, chofer, placa y acción).
class BusCard extends StatelessWidget {
  const BusCard({
    super.key,
    required this.busId,
    required this.studentCount,
    required this.conductor,
    required this.plate,
    required this.onTap,
  });

  final String busId;
  final int studentCount;
  final String conductor;
  final String plate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              _busBadge(),
              const SizedBox(width: 12),
              Expanded(
                child: _infoColumn(),
              ),
              _actionButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Badge del número de unidad en tono institucional.
  Widget _busBadge() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          busId,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
      ),
    );
  }

  /// Información del chofer y la placa.
  Widget _infoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          conductor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          plate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Botón de acceso a la ficha de estudiantes.
  Widget _actionButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Ver estudiantes',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
