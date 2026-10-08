import 'package:flutter/material.dart';

import '../data/admin_store.dart';
import '../models/safety_alert.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// 🚨 Apartado 6: bitácora de retrasos, emergencias y notificaciones.
class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStore.instance,
      builder: (context, _) {
        final alertas = AdminStore.instance.alertas;
        final criticas =
            alertas.where((a) => a.nivel == AlertLevel.critical).length;
        final advertencias =
            alertas.where((a) => a.nivel == AlertLevel.warning).length;
        final pendientes = alertas.where((a) => !a.respondido).length;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            MetricGrid(
              children: [
                StatCard(
                    label: 'Alertas críticas',
                    value: '$criticas',
                    icon: Icons.report_gmailerrorred_rounded,
                    caption: 'Requieren acción inmediata'),
                StatCard(
                    label: 'Advertencias',
                    value: '$advertencias',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    caption: 'Seguimiento en curso'),
                StatCard(
                    label: 'Sin responder',
                    value: '$pendientes',
                    icon: Icons.mark_email_unread_rounded,
                    color: AppColors.info,
                    caption: 'Asignadas a coordinación'),
              ],
            ),
            const SizedBox(height: 20),

            // Bitácora
            SectionCard(
              title: 'Bitácora de seguridad',
              subtitle: 'Registro cronológico de eventos',
              icon: Icons.history_toggle_off_rounded,
              trailing: FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Usa el panel administrativo para registrar alertas'))),
                icon: const Icon(Icons.add_alert_rounded, size: 18),
                label: const Text('Registrar alerta'),
              ),
              child: Column(
                children: alertas.map((a) => _AlertTile(alert: a)).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Fila visual de una alerta con su nivel de severidad.
class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final SafetyAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = alert.nivel.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(
              alert.nivel == AlertLevel.critical
                  ? Icons.priority_high_rounded
                  : alert.nivel == AlertLevel.warning
                      ? Icons.warning_amber_rounded
                      : Icons.info_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(alert.titulo, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    ),
                    Text(alert.hora, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(alert.detalle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    StatusChip(label: alert.nivel.label, color: color),
                    const SizedBox(width: 8),
                    StatusChip(label: alert.ruta, color: AppColors.sidebarBg),
                    const Spacer(),
                    if (alert.respondido)
                      const Text('Atendida', style: TextStyle(fontSize: 11.5, color: AppColors.success, fontWeight: FontWeight.w600))
                    else
                      OutlinedButton(
                        onPressed: () {
                          AdminStore.instance.marcarAtendida(alert.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('«${alert.titulo}» marcada como atendida')));
                        },
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: const Text('Marcar atendida', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
