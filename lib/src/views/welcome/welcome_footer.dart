import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/social_icon.dart';
import 'welcome_common.dart';
import 'welcome_data.dart';

/// Bloque 7 — Pie de página institucional.
///
/// Tres capas: barra de suscripción azul, cuerpo con cuatro columnas y barra
/// inferior con los enlaces legales.
class WelcomeFooter extends StatefulWidget {
  const WelcomeFooter({super.key, required this.onSuscribirse});

  /// Callback con el correo validado de la barra de suscripción.
  final ValueChanged<String> onSuscribirse;

  @override
  State<WelcomeFooter> createState() => _WelcomeFooterState();
}

class _WelcomeFooterState extends State<WelcomeFooter> {
  /// Controlador del campo de correo de la barra de suscripción.
  final TextEditingController _correo = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    super.dispose();
  }

  /// Valida el correo antes de delegar la suscripción.
  void _enviar() {
    final valor = _correo.text.trim();
    // Expresión regular mínima: texto, arroba y dominio con punto.
    final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[a-zA-Z]{2,}$').hasMatch(valor);
    if (!valido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo electrónico válido')),
      );
      return;
    }
    widget.onSuscribirse(valor);
    _correo.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.surface,
        border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border)),
      ),
      child: Column(
        children: [
          _BarraSuscripcion(controlador: _correo, onEnviar: _enviar, isDark: isDark),
          Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: _CuerpoFooter(isDark: isDark),
              ),
            ),
          ),
          _BarraLegal(isDark: isDark),
        ],
      ),
    );
  }
}

/// Barra azul de suscripción al boletín informativo.
class _BarraSuscripcion extends StatelessWidget {
  const _BarraSuscripcion({required this.controlador, required this.onEnviar, required this.isDark});

  final TextEditingController controlador;
  final VoidCallback onEnviar;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      color: isDark ? AppColors.navyDeep : AppColors.navy,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textos = Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mantente informado sobre nuestro servicio',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Suscríbete y recibe las últimas novedades en tu correo.',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFFBFDBFE)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              // Formulario: input de correo + botón «Suscribirme». En móvil
              // el botón baja a una segunda línea para no desbordar.
              final formulario = LayoutBuilder(
                builder: (context, ancho) {
                  final boton = WelcomeButton(
                    texto: 'Suscribirme',
                    icon: Icons.send_rounded,
                    color: AppColors.crimson,
                    onPressed: onEnviar,
                  );
                  final campo = TextField(
                    controller: controlador,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => onEnviar(),
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Tu correo electrónico',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  );

                  // El campo + botón necesitan ~390 px; por debajo se apilan.
                  if (ancho.maxWidth < 400) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [campo, const SizedBox(height: 10), boton],
                    );
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 250, child: campo),
                      const SizedBox(width: 10),
                      boton,
                    ],
                  );
                },
              );

              // En móvil la barra se apila en dos filas.
              if (constraints.maxWidth < 860) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [textos, const SizedBox(height: 14), formulario],
                );
              }
              return Row(children: [Expanded(child: textos), const SizedBox(width: 20), formulario]);
            },
          ),
        ),
      ),
    );
  }
}
/// Cuerpo del footer en cuatro columnas.
///
/// 1) Logotipo y descripción · 2) Navegación · 3) Contacto · 4) Redes sociales.
class _CuerpoFooter extends StatelessWidget {
  const _CuerpoFooter({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = <Widget>[
          const _ColumnaMarca(),
          const _ColumnaNavegacion(),
          const _ColumnaContacto(),
          const _ColumnaRedes(),
        ];

        // Por debajo de 780 px cada columna ocupa su propia fila.
        if (constraints.maxWidth < 780) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < columnas.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                columnas[i],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // La marca necesita más espacio que el resto.
            Expanded(flex: 3, child: columnas[0]),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: columnas[1]),
            const SizedBox(width: 24),
            Expanded(flex: 3, child: columnas[2]),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: columnas[3]),
          ],
        );
      },
    );
  }
}

/// Columna 1 — Logotipo oficial de Transporte Maranata + descripción.
class _ColumnaMarca extends StatelessWidget {
  const _ColumnaMarca();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.navyDeep : AppColors.navy,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.directions_bus_filled_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 11),
            Flexible(
              child: Text(
                'Transporte Escolar Maranata',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Servicio de buses escolar con seguridad y confianza. Brindamos un '
          'servicio de calidad con recorridos exclusivos hacia los centros educativos.',
          style: TextStyle(fontSize: 12.5, height: 1.6, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Columna 2 — Enlaces de navegación rápida.
class _ColumnaNavegacion extends StatelessWidget {
  const _ColumnaNavegacion();

  @override
  Widget build(BuildContext context) {
    return _ColumnaFooter(
      titulo: 'Navegación',
      children: [
        for (final enlace in kWelcomeNavLinks)
          _LinkFooter(texto: enlace, onTap: () => _aviso(context, enlace)),
      ],
    );
  }
}

/// Columna 3 — Información de contacto institucional.
class _ColumnaContacto extends StatelessWidget {
  const _ColumnaContacto();

  @override
  Widget build(BuildContext context) {
    return const _ColumnaFooter(
      titulo: 'Contacto',
      children: [
        _DatoContacto(icono: Icons.mail_outline_rounded, texto: 'transporte@maranata.edu.pe'),
        _DatoContacto(icono: Icons.phone_outlined, texto: '+51 999 999 999'),
        _DatoContacto(icono: Icons.schedule_rounded, texto: 'Lun a Vie · 8:00 a 18:00'),
      ],
    );
  }
}

/// Columna 4 — Redes sociales oficiales (Facebook y TikTok).
class _ColumnaRedes extends StatelessWidget {
  const _ColumnaRedes();

  @override
  Widget build(BuildContext context) {
    return _ColumnaFooter(
      titulo: 'Síguenos',
      children: [
        Row(
          children: [
            SocialIcon(
              brand: SocialBrand.facebook,
              tooltip: 'Facebook',
              onTap: () => _aviso(context, 'Facebook'),
            ),
            const SizedBox(width: 10),
            SocialIcon(
              brand: SocialBrand.tiktok,
              tooltip: 'TikTok',
              onTap: () => _aviso(context, 'TikTok'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Encabezado común de las columnas del footer.
class _ColumnaFooter extends StatelessWidget {
  const _ColumnaFooter({required this.titulo, required this.children});

  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

/// Enlace de navegación del footer.
class _LinkFooter extends StatelessWidget {
  const _LinkFooter({required this.texto, required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12.5,
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/// Dato de contacto con icono a la izquierda.
class _DatoContacto extends StatelessWidget {
  const _DatoContacto({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 15, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra inferior con copyright y enlaces legales.
class _BarraLegal extends StatelessWidget {
  const _BarraLegal({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const legales = ['Términos', 'Privacidad', 'Cookies'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                '© 2026 Colegio Maranata · Todos los derechos reservados',
                style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              ),
              // `Wrap` para que los enlaces legales bajen de línea en pantallas
              // estrechas en lugar de desbordar.
              Wrap(
                spacing: 10,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final legal in legales)
                    InkWell(
                      onTap: () => _aviso(context, legal),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          legal,
                          style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aviso uniforme para los enlaces estáticos del footer.
void _aviso(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$mensaje · enlace simulado')),
  );
}

