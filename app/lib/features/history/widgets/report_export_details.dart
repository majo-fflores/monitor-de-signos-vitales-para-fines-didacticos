import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';

class ReportExportDetails extends StatelessWidget {
  const ReportExportDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.02) 
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ColoresOscuros.border : ColoresClaros.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles de Exportación',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(12),
          Text(
            'Al hacer clic en generar, el sistema recopilará automáticamente las lecturas instantáneas de los biosensores activos (ECG, SpO2 y CO2) y creará un archivo PDF formalizado.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
              height: 1.5,
            ),
          ),
          const Gap(16),
          const Divider(),
          const Gap(16),
          _buildInfoRow(context, Icons.check_circle_outline, 'Formato Médico A4/Letter'),
          const Gap(12),
          _buildInfoRow(context, Icons.print_outlined, 'Listo para Impresión Física'),
          const Gap(12),
          _buildInfoRow(context, Icons.lock_outline, 'Datos locales privados'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon, 
          size: 16, 
          color: esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
        ),
        const Gap(8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
