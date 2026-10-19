import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Anchos de referencia para adaptar la portada a móvil, tableta y escritorio.
class WelcomeBreakpoints {
  WelcomeBreakpoints._();

  /// Por debajo de este ancho el Header pasa a dos filas.
  static const double compacto = 720;

  /// Por debajo de este ancho las columnas laterales se apilan.
  static const double mediano = 980;
}

/// Envoltura estándar de cada bloque de la portada.
///
/// Aplica el mismo ritmo vertical, ancho máximo y color de fondo para que todas
/// las secciones se lean como una sola página.
class WelcomeSection extends StatelessWidget {
  const WelcomeSection({
    super.key,
    required this.child,
    this.espaciadoSuperior = 26,
    this.paddingHorizontal = 18,
  });

  final Widget child;
  final double espaciadoSuperior;
  final double paddingHorizontal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(paddingHorizontal, espaciadoSuperior, paddingHorizontal, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: child,
        ),
      ),
    );
  }
}

/// Tarjeta blanca base de la portada (borde suave + radio consistente).
class WelcomeCard extends StatelessWidget {
  const WelcomeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderRadius = 16,
    this.borde,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double borderRadius;
  final Color? borde;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.darkSurface : AppColors.surface),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borde ?? (isDark ? AppColors.darkBorder : AppColors.border)),
      ),
      child: child,
    );
  }
}

/// Encabezado de sección: título en azul institucional + subtítulo gris.
class WelcomeSectionTitle extends StatelessWidget {
  const WelcomeSectionTitle({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.eyebrow,
    this.centrado = false,
  });

  final String titulo;
  final String? subtitulo;

  /// Texto pequeño sobre el título (p. ej. «Próxima salida»).
  final String? eyebrow;
  final bool centrado;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: centrado ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          titulo,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        if (subtitulo != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitulo!,
            textAlign: centrado ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

/// Distintivo pequeño de color (p. ej. «Bienvenido», «Seguro y puntual»).
class WelcomeBadge extends StatelessWidget {
  const WelcomeBadge({
    super.key,
    required this.texto,
    required this.icon,
    required this.color,
    this.compacto = false,
  });

  final String texto;
  final IconData icon;
  final Color color;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compacto ? 9 : 11, vertical: compacto ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compacto ? 12 : 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compacto ? 11 : 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón sólido reutilizable de la portada (carmesí o azul institucional).
class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icon,
    this.color = AppColors.crimson,
    this.expandir = false,
  });

  final String texto;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool expandir;

  @override
  Widget build(BuildContext context) {
    final boton = FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        minimumSize: Size(expandir ? double.infinity : 0, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 16),
      label: Text(texto),
    );

    return expandir ? SizedBox(width: double.infinity, child: boton) : boton;
  }
}

/// Mensaje estándar cuando una lista no tiene coincidencias.
class WelcomeEmptyState extends StatelessWidget {
  const WelcomeEmptyState({super.key, required this.texto, this.onLimpiar});

  final String texto;
  final VoidCallback? onLimpiar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 28, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary),
          ),
          if (onLimpiar != null) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: onLimpiar, child: const Text('Limpiar búsqueda')),
          ],
        ],
      ),
    );
  }
}

