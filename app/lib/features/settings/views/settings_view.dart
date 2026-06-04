import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/alarm_monitoring_card.dart';
import '../widgets/backend_connection_card.dart';
import '../widgets/display_preferences_card.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? ColoresOscuros.foreground : ColoresClaros.foreground;
    final subtitleColor = isDark ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground;
    final borderColor = isDark ? ColoresOscuros.border : ColoresClaros.border;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Sistema',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const Gap(4),
          Text(
            'Ajustes de umbrales médicos, conexión al backend y calibración de sensores.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subtitleColor,
            ),
          ),

          // ═══ TARJETA DE CONEXIÓN AL BACKEND ══════════════════════════
          const Gap(24),
          BackendConnectionCard(
            subtitleColor: subtitleColor,
            borderColor: borderColor,
          ),
          const Gap(24),

          // ═══ TARJETA DE ACTIVACIÓN DE ALARMA ══════════════════════════
          AlarmMonitoringCard(
            subtitleColor: subtitleColor,
            borderColor: borderColor,
          ),
          const Gap(24),

          // ═══ TARJETA DE PREFERENCIAS DE VISUALIZACIÓN ════════════════
          DisplayPreferencesCard(
            subtitleColor: subtitleColor,
            borderColor: borderColor,
          ),
          const Gap(40),
        ],
      ),
    );
  }
}
