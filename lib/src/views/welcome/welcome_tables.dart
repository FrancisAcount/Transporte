import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'welcome_common.dart';
import 'welcome_data.dart';

/// Bloque 6 — Bloque responsive de dos columnas.
///
/// Izquierda: tabla «Salidas de mañana» + lista «Últimos avisos».
/// Derecha: cuadro «Estado del servicio» + tabla «Paraderos principales».
class WelcomeTablesSection extends StatelessWidget {
  const WelcomeTablesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return WelcomeSection(
      espaciadoSuperior: 30,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const izquierda = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SalidasManana(),
              SizedBox(height: 18),
              _UltimosAvisos(),
            ],
          );

          const derecha = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _EstadoServicio(),
              SizedBox(height: 18),
              _ParaderosPrincipales(),
            ],
          );

          // Dos columnas a partir de 860 px; por debajo se apilan.
          if (constraints.maxWidth < 860) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [izquierda, SizedBox(height: 18), derecha],
            );
          }

          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: izquierda),
              SizedBox(width: 16),
              Expanded(flex: 2, child: derecha),
            ],
          );
        },
      ),
    );
  }
}

/// Encabezado «Próxima salida» + tabla de horarios de la mañana.
class _SalidasManana extends StatelessWidget {
  const _SalidasManana();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: WelcomeSectionTitle(eyebrow: 'Próxima salida', titulo: 'Salidas de mañana'),
            ),
            // Chip con la hora de la próxima salida.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.rosadoLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '06:30 hs',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.rosado),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _TablaSalidas(),
      ],
    );
  }
}

/// Tabla simple de salidas: hora · ruta · bus asignado.
class _TablaSalidas extends StatelessWidget {
  const _TablaSalidas();

  @override
  Widget build(BuildContext context) {
    return WelcomeCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < kWelcomeDepartures.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _FilaSalida(departure: kWelcomeDepartures[i]),
          ],
        ],
      ),
    );
  }
}

/// Fila de la tabla de salidas.
class _FilaSalida extends StatelessWidget {
  const _FilaSalida({required this.departure});

  final WelcomeDeparture departure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Hora destacada a la izquierda.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              departure.time,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              departure.route,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              departure.bus,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
/// Lista «Últimos avisos» con iconos informativos y de advertencia.
class _UltimosAvisos extends StatelessWidget {
  const _UltimosAvisos();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const WelcomeSectionTitle(titulo: 'Últimos avisos'),
        const SizedBox(height: 12),
        WelcomeCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              for (var i = 0; i < kWelcomeNotices.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                _FilaAviso(notice: kWelcomeNotices[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Fila de aviso: icono con tinte propio + título, texto y fecha.
class _FilaAviso extends StatelessWidget {
  const _FilaAviso({required this.notice});

  final WelcomeNotice notice;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: notice.tint, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Icon(notice.icon, size: 18, color: notice.color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notice.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                notice.text,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(notice.date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
/// Cuadro consolidado «Estado del servicio» con los tres totales.
class _EstadoServicio extends StatelessWidget {
  const _EstadoServicio();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: WelcomeSectionTitle(eyebrow: 'Resumen', titulo: 'Estado del servicio'),
            ),
            // Chip de estado con punto verde.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 7, color: AppColors.green),
                  SizedBox(width: 5),
                  Text(
                    'Servicio',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        WelcomeCard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Row(
            children: [
              // Los tres totales separados por líneas verticales.
              for (var i = 0; i < kServiceTotals.length; i++) ...[
                if (i > 0) Container(width: 1, height: 38, color: AppColors.border),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        kServiceTotals[i].value,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kServiceTotals[i].label,
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
            ],
          ),
        ),
      ],
    );
  }
}
/// Tabla «Paraderos principales» con el estado «Activo» en verde.
class _ParaderosPrincipales extends StatelessWidget {
  const _ParaderosPrincipales();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const WelcomeSectionTitle(titulo: 'Paraderos principales'),
        const SizedBox(height: 12),
        WelcomeCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < kWelcomeStops.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _FilaParadero(stop: kWelcomeStops[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Fila de paradero: nombre, ruta, hora y estado activo.
class _FilaParadero extends StatelessWidget {
  const _FilaParadero({required this.stop});

  final WelcomeStop stop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              stop.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              stop.route,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              stop.time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
          // Estado fijo en verde (referencia).
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Activo',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }
}
