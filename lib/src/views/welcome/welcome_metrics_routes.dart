import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/bus_illustration.dart';
import 'welcome_common.dart';
import 'welcome_data.dart';

/// Bloque 5 — Métricas clave (círculos de color) + tarjetas de rutas.
///
/// Recibe la consulta del buscador del header para filtrar las rutas sin que
/// ambas secciones tengan que conocerse entre sí.
class WelcomeMetricsRoutes extends StatelessWidget {
  const WelcomeMetricsRoutes({
    super.key,
    required this.onVerRuta,
    this.metrics = kWelcomeMetrics,
    this.routes = kWelcomeRoutes,
    this.consulta = '',
    this.onLimpiarConsulta,
  });

  final void Function(WelcomeRoute ruta) onVerRuta;
  final List<WelcomeMetric> metrics;
  final List<WelcomeRoute> routes;

  /// Texto escrito en el buscador del header.
  final String consulta;
  final VoidCallback? onLimpiarConsulta;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final termino = consulta.trim().toLowerCase();
    final filtradas = termino.isEmpty
        ? routes
        : routes
            .where(
              (r) =>
                  r.name.toLowerCase().contains(termino) ||
                  r.summary.toLowerCase().contains(termino),
            )
            .toList();

    return WelcomeSection(
      espaciadoSuperior: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilaMetricas(metrics: metrics, isDark: isDark),
          const SizedBox(height: 16),
          if (filtradas.isEmpty)
            WelcomeEmptyState(
              texto: 'No encontramos rutas con «$consulta».',
              onLimpiar: onLimpiarConsulta,
            )
          else
            _FilaRutas(routes: filtradas, onVerRuta: onVerRuta, isDark: isDark),
        ],
      ),
    );
  }
}

/// Fila de tres métricas con círculo de color e icono.
class _FilaMetricas extends StatelessWidget {
  const _FilaMetricas({required this.metrics, required this.isDark});

  final List<WelcomeMetric> metrics;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Por debajo de 560 px el valor pequeño no cabe: el círculo sube arriba.
        final apilado = constraints.maxWidth < 560;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final m in metrics)
              SizedBox(
                width: apilado
                    ? (constraints.maxWidth - 14) / 2
                    : (constraints.maxWidth - 28) / 3,
                child: _TarjetaMetrica(metric: m, apilado: apilado, isDark: isDark),
              ),
          ],
        );
      },
    );
  }
}

/// Métrica con círculo de color a la izquierda y etiqueta + valor a la derecha.
class _TarjetaMetrica extends StatelessWidget {
  const _TarjetaMetrica({required this.metric, required this.apilado, required this.isDark});

  final WelcomeMetric metric;
  final bool apilado;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final circulo = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: metric.tint, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(metric.icon, size: 22, color: metric.color),
    );

    final textos = Column(
      crossAxisAlignment: apilado
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          metric.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: apilado ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          metric.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: apilado ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );

    return WelcomeCard(
      padding: const EdgeInsets.all(14),
      child: apilado
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [circulo, const SizedBox(height: 10), textos],
            )
          : Row(
              children: [
                circulo,
                const SizedBox(width: 12),
                Expanded(child: textos),
              ],
            ),
    );
  }
}

/// Fila de tarjetas verticales con una imagen frontal del bus por ruta.
class _FilaRutas extends StatelessWidget {
  const _FilaRutas({required this.routes, required this.onVerRuta, required this.isDark});

  final List<WelcomeRoute> routes;
  final void Function(WelcomeRoute ruta) onVerRuta;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Una columna en móvil, dos en tableta y tres en escritorio.
        final columnas = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
                ? 2
                : 1;
        final ancho = (constraints.maxWidth - 14 * (columnas - 1)) / columnas;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final ruta in routes)
              SizedBox(
                width: ancho,
                child: _TarjetaRuta(route: ruta, onVerRuta: onVerRuta, isDark: isDark),
              ),
          ],
        );
      },
    );
  }
}

/// Tarjeta vertical de ruta: imagen frontal, distintivo de color y botón.
class _TarjetaRuta extends StatelessWidget {
  const _TarjetaRuta({required this.route, required this.onVerRuta, required this.isDark});

  final WelcomeRoute route;
  final void Function(WelcomeRoute ruta) onVerRuta;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imagen frontal del bus, con las esquinas superiores redondeadas.
          const Padding(
            padding: EdgeInsets.all(8),
            child: BusIllustration(scene: BusScene.frontal, height: 112, borderRadius: 12),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Distintivo con el color propio de cada ruta.
                Align(
                  alignment: Alignment.centerLeft,
                  child: WelcomeBadge(
                    texto: route.name,
                    icon: Icons.directions_bus_filled_rounded,
                    color: route.color,
                    compacto: true,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  route.summary,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // Detalles de horario y paraderos principales.
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 13, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      route.schedule,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.location_on_outlined, size: 13, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${route.stops} paraderos',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => onVerRuta(route),
                  style: FilledButton.styleFrom(
                    backgroundColor: route.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Ver ruta'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
