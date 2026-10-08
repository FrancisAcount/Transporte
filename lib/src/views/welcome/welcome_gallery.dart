import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/bus_illustration.dart';
import 'welcome_common.dart';
import 'welcome_data.dart';

/// Galería de la flota + objetivos del proyecto.
///
/// Comparte el bloque con los horarios: en pantallas anchas la galería ocupa la
/// columna izquierda y los objetivos la derecha.
class WelcomeGallerySection extends StatelessWidget {
  const WelcomeGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    return WelcomeSection(
      espaciadoSuperior: 30,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dosColumnas = constraints.maxWidth >= 860;
          const galeria = _GaleriaFlota();
          const objetivos = _Objetivos();

          if (!dosColumnas) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [galeria, SizedBox(height: 18), objetivos],
            );
          }

          // Sin `IntrinsicHeight`: la galería usa un `LayoutBuilder` interno y
          // las dimensiones intrínsecas no son compatibles con él.
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: galeria),
              SizedBox(width: 16),
              Expanded(flex: 2, child: objetivos),
            ],
          );
        },
      ),
    );
  }
}

/// Tres imágenes consecutivas de los vehículos escolares con su pie de foto.
class _GaleriaFlota extends StatelessWidget {
  const _GaleriaFlota();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const WelcomeSectionTitle(titulo: 'Galería de la flota'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final ancho = (constraints.maxWidth - 12 * (kWelcomeGallery.length - 1)) / kWelcomeGallery.length;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final foto in kWelcomeGallery)
                  SizedBox(
                    width: ancho,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BusIllustration(scene: foto.scene, height: 104, borderRadius: 12),
                        const SizedBox(height: 6),
                        Text(
                          foto.caption,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Lista de objetivos del proyecto con icono y descripción.
class _Objetivos extends StatelessWidget {
  const _Objetivos();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const WelcomeSectionTitle(titulo: 'Objetivos del proyecto'),
        const SizedBox(height: 12),
        WelcomeCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              for (var i = 0; i < kWelcomeObjectives.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                _FilaObjetivo(objective: kWelcomeObjectives[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Objetivo individual: icono en cuadro + título y descripción.
class _FilaObjetivo extends StatelessWidget {
  const _FilaObjetivo({required this.objective});

  final WelcomeObjective objective;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.navy.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Icon(objective.icon, size: 17, color: AppColors.navy),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                objective.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                objective.text,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
