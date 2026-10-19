import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/admin_store.dart';
import '../models/driver_record.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Filtros rápidos disponibles en la cabecera.
enum DriverFilter { todos, enRuta, disponible, ausente }

/// 👨‍✈️ Apartado 4: gestión dinámica de conductores y asistentes.
class DriversView extends StatefulWidget {
  const DriversView({super.key});

  @override
  State<DriversView> createState() => _DriversViewState();
}

class _DriversViewState extends State<DriversView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  DriverFilter _filter = DriverFilter.todos;

  /// Lista viva del panel administrativo: los registros del formulario se
  /// guardan en el [AdminStore] para que también los vean Estudiantes y el
  /// panel (y se sincronicen con Firebase).
  List<DriverRecord> get _drivers => AdminStore.instance.conductores;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Conductores que pasan el filtro rápido y la búsqueda por texto.
  List<DriverRecord> get _visible => _drivers.where((d) {
        final okEstado = switch (_filter) {
          DriverFilter.todos => true,
          DriverFilter.enRuta => d.estado == DriverStatus.enRuta,
          DriverFilter.disponible => d.estado == DriverStatus.disponible,
          DriverFilter.ausente => d.estado == DriverStatus.ausente,
        };
        return okEstado && d.coincide(_query);
      }).toList();

  int _count(DriverStatus s) => _drivers.where((d) => d.estado == s).length;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStore.instance,
      builder: (context, _) {
        final visibles = _visible;
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
              children: [
                AppSearchBar(
                  hintText: 'Buscar conductor por nombre o número de bus...',
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 16),
                _buildFilters(visibles.length),
                const SizedBox(height: 20),
                if (visibles.isEmpty)
                  _buildEmptyState()
                else
                  AdaptiveGrid(
                    maxColumns: 3,
                    children:
                        visibles.map((d) => _buildProfile(context, d)).toList(),
                  ),
              ],
            ),
            // Botón flotante de registro.
            Positioned(
              right: 24,
              bottom: 24,
              child: FloatingActionButton.extended(
                onPressed: _openRegisterForm,
                backgroundColor: AppColors.guindo,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Nuevo conductor'),
              ),
            ),
          ],
        );
      },
    );
  }
/// Métricas rápidas + chips de filtro por estado.
  Widget _buildFilters(int visibles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MetricGrid(
          children: [
            StatCard(label: 'Total personal', value: '${_drivers.length}', icon: Icons.groups_rounded, caption: 'Conductores y asistentes'),
            StatCard(label: 'En ruta', value: '${_count(DriverStatus.enRuta)}', icon: Icons.directions_bus_rounded, color: AppColors.navy, caption: 'Realizando recorrido'),
            StatCard(label: 'Disponibles', value: '${_count(DriverStatus.disponible)}', icon: Icons.check_circle_outline, color: AppColors.success, caption: 'Listos para asignar'),
            StatCard(label: 'Ausentes', value: '${_count(DriverStatus.ausente)}', icon: Icons.person_off_outlined, color: AppColors.guindo, caption: 'Permisos e incapacidades'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.filter_list_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            // Etiqueta flexible: en móvil estrecho cede espacio al contador.
            const Flexible(
              child: Text(
                'Filtrar por estado',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Text('$visibles de ${_drivers.length}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip(DriverFilter.todos, 'Todos', _drivers.length),
            _chip(DriverFilter.enRuta, 'En Ruta', _count(DriverStatus.enRuta)),
            _chip(DriverFilter.disponible, 'Disponibles', _count(DriverStatus.disponible)),
            _chip(DriverFilter.ausente, 'Ausentes', _count(DriverStatus.ausente)),
          ],
        ),
      ],
    );
  }
/// Un chip de filtro; se resalta con el guindo corporativo si está activo.
  Widget _chip(DriverFilter f, String label, int count) {
    final activo = _filter == f;
    return FilterChip(
      selected: activo,
      onSelected: (_) => setState(() => _filter = f),
      showCheckmark: false,
      avatar: Icon(
        activo ? Icons.check_circle_rounded : Icons.circle_outlined,
        size: 15,
        color: activo ? AppColors.guindo : AppColors.textMuted,
      ),
      label: Text(
        '$label ($count)',
        style: TextStyle(fontSize: 12, fontWeight: activo ? FontWeight.w700 : FontWeight.w500, color: activo ? AppColors.guindo : AppColors.textSecondary),
      ),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.guindo.withValues(alpha: 0.10),
      side: BorderSide(color: activo ? AppColors.guindo : AppColors.border, width: activo ? 1.4 : 1),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }

  /// Estado vacío cuando ningún conductor coincide con los filtros.
  Widget _buildEmptyState() => Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            const Icon(Icons.person_search_rounded, size: 42, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Sin resultados para "${_query.trim()}"',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => setState(() {
                _query = '';
                _searchController.clear();
                _filter = DriverFilter.todos;
              }),
              child: const Text('Limpiar filtros'),
            ),
          ],
        ),
      );
/// Tarjeta de ficha del conductor (clic abre el detalle).
  Widget _buildProfile(BuildContext context, DriverRecord d) {
    // Contenedor con sombra suave y borde redondeado: da el volumen
    // "premium" sin recurrir a un elevation de Material demasiado fuerte.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.sidebarBg.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(context, d),
          // El degradado de la franja lateral es el indicador de estado.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: d.colorEstado),
                Expanded(
                  child: Padding(
                    // Padding interno ampliado: antes las filas iban pegadas.
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            _avatarCorporativo(d),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.nombre,
                                    // Tipografía robusta con tracking negativo.
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${d.cargo} · ${d.ruta}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusChip(label: d.estadoLabel, color: d.colorEstado),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, thickness: 1, color: AppColors.border),
                        const SizedBox(height: 16),
                        _line(Icons.badge_outlined, 'ID ${d.id} · Cédula ${d.cedula}', d.colorEstado),
                        _line(Icons.directions_bus_filled_outlined, 'Bus ${d.bus}', d.colorEstado),
                        _line(Icons.phone_iphone_rounded, d.telefono, d.colorEstado),
                        _line(Icons.workspace_premium_outlined, d.licencia, d.colorEstado),
                        _line(Icons.history_rounded, '${d.aniosExperiencia} años de experiencia', d.colorEstado, ultimo: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Avatar circular con degradado corporativo (azul de marca, o guindo si el
  /// conductor está ausente) en lugar de los tonos apagados anteriores.
  Widget _avatarCorporativo(DriverRecord d) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: d.esAusente
                ? const [AppColors.guindo, AppColors.guindoDark]
                : const [AppColors.navy, AppColors.navyDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: d.colorEstado.withValues(alpha: 0.32),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          d.iniciales,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      );

  /// Línea de dato dentro de la ficha.
  ///
  /// [acento] tiñe el icono con el color del estado; [ultimo] quita el
  /// margen inferior en la última fila para equilibrar el bloque.
  Widget _line(IconData icon, String text, Color acento, {bool ultimo = false}) => Padding(
        padding: EdgeInsets.only(bottom: ultimo ? 0 : 11),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: acento.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 14, color: acento),
            ),
            // Más aire entre el icono y su texto.
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
/// Diálogo con la ficha completa del conductor.
  ///
  /// Usa un [Dialog] a medida (en lugar de [AlertDialog]) para poder colocar
  /// un header corporativo con degradado azul institucional y avatar
  /// estilizado y los datos personales con alto contraste.
  void _openDetail(BuildContext context, DriverRecord d) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: AppColors.surface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _headerDetalle(d),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: StatusChip(label: d.estadoLabel, color: d.colorEstado),
                      ),
                      const SizedBox(height: 18),
                      _detailRow(Icons.badge_outlined, 'Identificación', d.id),
                      _detailRow(Icons.credit_card_rounded, 'Cédula', d.cedula),
                      _detailRow(Icons.phone_iphone_rounded, 'Teléfono', d.telefono),
                      _detailRow(Icons.directions_bus_filled_outlined, 'Bus asignado', d.bus),
                      _detailRow(Icons.route_rounded, 'Ruta asignada', d.ruta),
                      _detailRow(Icons.workspace_premium_outlined, 'Tipo de licencia', d.licencia),
                      _detailRow(Icons.history_rounded, 'Experiencia', '${d.aniosExperiencia} años'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _llamar(ctx, d),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.guindo,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.call_rounded, size: 18),
                              label: const Text('Llamar'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _abrirWhatsApp(ctx, d),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.whatsappGreen,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.chat_rounded, size: 18),
                              label: const Text('Mensaje'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _barraAcciones(ctx),
            ],
          ),
        ),
      ),
    );
  }

  /// Fila etiqueta/valor del diálogo de detalle, con icono corporativo.
  Widget _detailRow(IconData icon, String label, String value) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.azulCorporativo),
            const SizedBox(width: 10),
            SizedBox(
              width: 118,
              child: Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );

  /// Cabecera con degradado azul institucional y avatar estilizado.
  Widget _headerDetalle(DriverRecord d) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.azulCorporativo, AppColors.azulCorporativoOscuro],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              child: Text(
                d.iniciales,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.cargo} · ${d.bus}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  /// Barra inferior de acciones del diálogo de detalle.
  Widget _barraAcciones(BuildContext ctx) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: const Text('Cerrar ficha'),
        ),
      );

  /// Abre la aplicación de teléfono con el número del conductor.
  Future<void> _llamar(BuildContext ctx, DriverRecord d) async {
    final numero = _soloDigitos(d.telefono);
    final uri = Uri(scheme: 'tel', path: numero);
    if (!await launchUrl(uri)) {
      _aviso('No se pudo abrir el teléfono en este dispositivo');
    }
  }

  /// Abre WhatsApp (web o app móvil) con un mensaje predeterminado.
  Future<void> _abrirWhatsApp(BuildContext ctx, DriverRecord d) async {
    final numero = _soloDigitos(d.telefono);
    final mensaje = Uri.encodeComponent(
      'Hola, me comunico desde la administración de Transporte Maranata. '
      'Necesito comunicarme contigo sobre tu asignación de ruta.',
    );
    final uri = Uri.parse('https://wa.me/$numero?text=$mensaje');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _aviso('No se pudo abrir WhatsApp. Verifica la conexión o la app.');
    }
  }

  /// Deja solo dígitos del teléfono (formato Ecuador / internacional).
  String _soloDigitos(String tel) => tel.replaceAll(RegExp(r'[^0-9]'), '');

  void _aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }
/// Abre el formulario y, si confirma, agrega el conductor a la lista.
  ///
  /// El formulario vive en su propio [StatefulWidget] para que sus
  /// [TextEditingController] se liberen con el widget y no mientras la
  /// animación de cierre del diálogo todavía está reconstruyéndose.
  Future<void> _openRegisterForm() async {
    final registro = await showDialog<DriverRecord>(
      context: context,
      builder: (_) => const _RegisterDriverDialog(),
    );
    if (registro == null || !mounted) return;

    // Alta en el almacén compartido: persiste en Firebase y aparece en
    // Estudiantes y en el panel administrativo.
    final store = AdminStore.instance;
    final id = store.nuevoId('DRV', store.conductores.map((d) => d.id));
    store.agregarConductor(DriverRecord(
      id: id,
      nombre: registro.nombre,
      cedula: registro.cedula.isEmpty ? 'Pendiente' : registro.cedula,
      telefono: registro.telefono,
      bus: registro.bus,
      licencia: registro.licencia.isEmpty ? '—' : registro.licencia,
      ruta: registro.ruta,
      cargo: registro.cargo,
      aniosExperiencia: registro.aniosExperiencia,
      estado: registro.estado,
    ));
    setState(() {
      _filter = DriverFilter.todos;
      _query = '';
      _searchController.clear();
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${registro.nombre} registrado correctamente')));
  }
}

/// Diálogo de alta de conductor. Devuelve el [DriverRecord] confirmado.
class _RegisterDriverDialog extends StatefulWidget {
  const _RegisterDriverDialog();

  @override
  State<_RegisterDriverDialog> createState() => _RegisterDriverDialogState();
}

class _RegisterDriverDialogState extends State<_RegisterDriverDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _bus = TextEditingController();
  final _licencia = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _bus.dispose();
    _licencia.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      DriverRecord(
        id: 'DRV-NUEVO',
        nombre: _nombre.text.trim(),
        cedula: 'Pendiente',
        telefono: _telefono.text.trim(),
        bus: _bus.text.trim().toUpperCase(),
        licencia: _licencia.text.trim(),
        ruta: 'Sin asignar',
        cargo: 'Conductor',
        aniosExperiencia: 0,
        estado: DriverStatus.disponible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // NOTA: este formulario es una vista rápida para el Coordinador.
    // En una fase posterior se migrará al módulo de Configuración,
    // restringido al perfil exclusivo del Administrador.
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _headerRegistro(),
            Flexible(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 8), child: _formulario())),
            _barraAcciones(),
          ],
        ),
      ),
    );
  }

  /// Cuerpo del formulario de alta.
  Widget _formulario() => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'DATOS DEL CONDUCTOR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            _campo(_nombre, 'Nombre completo', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _campo(_telefono, 'Teléfono', Icons.phone_iphone_rounded, teclado: TextInputType.phone),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _campo(_bus, 'Número de bus', Icons.directions_bus_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _campo(_licencia, 'Tipo de licencia', Icons.workspace_premium_outlined)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.azulCorporativo.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.azulCorporativo.withValues(alpha: 0.18)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 15, color: AppColors.azulCorporativo),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cédula, ruta y años de experiencia se completarán en la ficha técnica del conductor.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  /// Cabecera corporativa del formulario de alta.
  Widget _headerRegistro() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.azulCorporativo, AppColors.azulCorporativoOscuro],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.badge_outlined, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Registrar conductor',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Alta de personal · Transporte Escolar Maranata',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  /// Barra inferior de confirmación del formulario.
  Widget _barraAcciones() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBg : AppColors.background,
          border: Border(top: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextMuted : AppColors.textSecondary,
                  side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _guardar,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.guindo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      );

  /// Campo de formulario con validación.
  Widget _campo(TextEditingController ctrl, String label, IconData icon, {TextInputType? teclado}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: ctrl,
      keyboardType: teclado,
      textInputAction: TextInputAction.next,
      style: TextStyle(fontSize: 13.5, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        prefixIcon: Icon(icon, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.guindo, width: 1.4)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null,
    );
  }
}

