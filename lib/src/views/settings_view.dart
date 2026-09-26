import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// ⚙️ Apartado 7: ajustes generales del sistema y perfil de usuario.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Estado local de los interruptores (simula la persistencia).
  bool _notificacionesPush = true;
  bool _alertasCriticas = true;
  bool _modoMantenimiento = false;
  double _capacidadMinima = 50;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        LayoutBuilder(builder: (context, c) {
          final isWide = c.maxWidth > 900;
          final perfil = _buildProfileCard();
          final general = _buildGeneralCard();
          return isWide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: perfil), const SizedBox(width: 16), Expanded(child: general)])
              : Column(children: [perfil, const SizedBox(height: 16), general]);
        }),
        const SizedBox(height: 16),
        _buildAboutCard(),
      ],
    );
  }

  /// Tarjeta de perfil del coordinador.
  Widget _buildProfileCard() {
    return SectionCard(
      title: 'Perfil del usuario',
      subtitle: 'Datos de la cuenta administrativa',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.guindo,
                child: Text('CM', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coordinador Maranata', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('coordinacion@maranata.edu.ec', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _toast('Edición de perfil'),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Editar'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _field('Nombre completo', 'Coordinador Maranata'),
          const SizedBox(height: 12),
          _field('Correo institucional', 'coordinacion@maranata.edu.ec'),
          const SizedBox(height: 12),
          _field('Teléfono', '+593 99 000 0000'),
        ],
      ),
    );
  }
  /// Tarjeta de ajustes generales (preferencias).
  Widget _buildGeneralCard() {
    return SectionCard(
      title: 'Ajustes generales',
      subtitle: 'Preferencias del sistema',
      icon: Icons.tune_rounded,
      child: Column(
        children: [
          _switch('Notificaciones push', 'Recibir avisos en el dispositivo', _notificacionesPush, (v) => setState(() => _notificacionesPush = v)),
          const Divider(height: 24),
          _switch('Alertas críticas', 'Avisar incidentemente de seguridad', _alertasCriticas, (v) => setState(() => _alertasCriticas = v)),
          const Divider(height: 24),
          _switch('Modo mantenimiento', 'Bloquear despacho de rutas', _modoMantenimiento, (v) => setState(() => _modoMantenimiento = v)),
          const Divider(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Capacidad mínima de aforo (%)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  Text('${_capacidadMinima.round()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.guindo)),
                ],
              ),
              Slider(
                value: _capacidadMinima,
                min: 0,
                max: 100,
                activeColor: AppColors.guindo,
                onChanged: (v) => setState(() => _capacidadMinima = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _toast('Configuración guardada correctamente'),
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de información del sistema.
  Widget _buildAboutCard() {
    return const SectionCard(
      title: 'Información del sistema',
      subtitle: 'Detalles de la plataforma',
      icon: Icons.info_outline_rounded,
      child: Wrap(
        spacing: 40,
        runSpacing: 12,
        children: [
          _Info(label: 'Versión', value: '1.0.0'),
          _Info(label: 'Entorno', value: 'Producción (demo)'),
          _Info(label: 'Última sincronización', value: 'Hoy, 14:30'),
          _Info(label: 'Módulos activos', value: '7 de 7'),
        ],
      ),
    );
  }

  /// Campo de texto de solo lectura (estilizado).
  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(initialValue: value, decoration: const InputDecoration(isDense: true)),
      ],
    );
  }

  /// Fila con interruptor y descripción.
  Widget _switch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ),
        ),
        Switch(value: value, activeThumbColor: AppColors.guindo, onChanged: onChanged),
      ],
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Dato informativo estático.
class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
