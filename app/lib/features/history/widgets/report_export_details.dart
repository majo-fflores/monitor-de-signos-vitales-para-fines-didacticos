import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class ReportExportDetails extends StatelessWidget {
  final bool esMobile;

  const ReportExportDetails({super.key, this.esMobile = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (esMobile) {
      return _buildMobileLayout(theme, isDark);
    }

    return _buildDesktopLayout(theme, isDark);
  }

  Widget _buildDesktopLayout(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
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
            'Al hacer clic en generar, el sistema recopilará automáticamente las lecturas instantáneas de los biosensores activos (ECG y CO2) y creará un archivo PDF formalizado o un archivo CSV con datos crudos.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? DarkColors.mutedForeground
                  : LightColors.mutedForeground,
              height: 1.5,
            ),
          ),
          const Gap(16),
          const Divider(),
          const Gap(16),
          _buildInfoRow(
            theme,
            isDark,
            Icons.check_circle_outline,
            'Formato Médico A4/Letter',
          ),
          const Gap(12),
          _buildInfoRow(
            theme,
            isDark,
            Icons.print_outlined,
            'Listo para Impresión Física',
          ),
          const Gap(12),
          _buildInfoRow(
            theme,
            isDark,
            Icons.lock_outline,
            'Datos locales privados',
          ),

          // Spacer + ícono decorativo para llenar el espacio en desktop
          const Spacer(),
          const Gap(24),
          Center(
            child: Icon(
              LucideIcons.fileText,
              size: 64,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.03),
            ),
          ),
          const Gap(8),
          Center(
            child: Text(
              'PDF / CSV • Reporte Clínico',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
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
          const Gap(8),
          Text(
            'El sistema recopilará las lecturas de los biosensores activos y creará un PDF formalizado o un CSV crudo.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? DarkColors.mutedForeground
                  : LightColors.mutedForeground,
              height: 1.4,
            ),
          ),
          const Gap(12),
          // En mobile, los 3 ítems en fila compacta
          Row(
            children: [
              Expanded(
                child: _buildCompactInfoItem(
                  theme,
                  isDark,
                  Icons.check_circle_outline,
                  'A4/Letter',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactInfoItem(
                  theme,
                  isDark,
                  Icons.print_outlined,
                  'Imprimible',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactInfoItem(
                  theme,
                  isDark,
                  Icons.lock_outline,
                  'Privado',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoItem(
    ThemeData theme,
    bool isDark,
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark
                ? DarkColors.mutedForeground
                : LightColors.mutedForeground,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    bool isDark,
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? DarkColors.mutedForeground
              : LightColors.mutedForeground,
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
