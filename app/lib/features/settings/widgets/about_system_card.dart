import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AboutSystemCard extends StatelessWidget {
  final Color subtitleColor;
  final Color borderColor;

  const AboutSystemCard({
    super.key,
    required this.subtitleColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.info, color: theme.colorScheme.primary),
              const Gap(10),
              Text(
                'Acerca del Sistema',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'Información técnica, de compilación y autoría del sistema de monitoreo en tiempo real.',
            style: theme.textTheme.bodySmall?.copyWith(color: subtitleColor),
          ),
          const Gap(24),

          // Logo / Marca del Proyecto
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.heartPulse,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Gap(12),
                Text(
                  'DataVital',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Monitoreo Multiparamétrico de Signos Vitales',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Gap(24),

          const Divider(),
          const Gap(16),

          // Tabla/Lista de Datos de Versión
          _buildInfoRow(
            context,
            'Versión de la Aplicación',
            'v1.0.0-estable',
            LucideIcons.appWindow,
          ),
          const Gap(12),
          _buildInfoRow(
            context,
            'Firmware Requerido',
            'DataVital-Arduino v1.0.3',
            LucideIcons.cpu,
          ),
          const Gap(12),
          _buildInfoRow(
            context,
            'Desarrollado por',
            'UNTDF - Sistemas de Tiempo Real',
            LucideIcons.graduationCap,
          ),
          const Gap(12),
          _buildInfoRow(
            context,
            'Licencia',
            'GPL v3 - Académica',
            LucideIcons.fileText,
          ),

          const Gap(20),
          const Divider(),
          const Gap(16),

          // Botón de Soporte o Documentación
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Documentación del proyecto cargada en el repositorio local.',
                    style: TextStyle(color: Colors.white),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(LucideIcons.externalLink, size: 16),
            label: const Text('Ver Documentación del Proyecto'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: borderColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const Gap(12),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
