import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/history_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../widgets/history_statistics_summary.dart';
import '../widgets/session_history_row.dart';

/// Vista del historial de mediciones.
/// Usa filas expandibles compactas para no ocupar demasiado espacio vertical.
class SessionsHistoryView extends ConsumerStatefulWidget {
  const SessionsHistoryView({super.key});

  @override
  ConsumerState<SessionsHistoryView> createState() =>
      _SessionsHistoryViewState();
}

class _SessionsHistoryViewState extends ConsumerState<SessionsHistoryView> {
  int? _expandedRowIndex;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final active = ref.read(usersNotifierProvider).activeUser;
      if (active != null) {
        ref.read(historyNotifierProvider.notifier).loadHistory(active.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final historyState = ref.watch(historyNotifierProvider);
    final activeUser = ref.watch(usersNotifierProvider).activeUser;

    if (activeUser == null) {
      return const Center(
        child: Text('No hay ningún usuario activo seleccionado.'),
      );
    }

    if (historyState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final records = historyState.records;

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMobile = constraints.maxWidth < Breakpoints.tablet;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Título ──
              Text(
                'Historial de Sesiones',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? DarkColors.foreground
                      : LightColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Historial clínico de ${activeUser.name}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? DarkColors.mutedForeground
                      : LightColors.mutedForeground,
                ),
              ),
              const Gap(24),

              // ── KPI strip componentizado ──
              HistoryStatisticsSummary(
                records: records,
                theme: theme,
                isDark: isDark,
              ),
              const Gap(24),

              // ── Tabla compacta con filas expandibles ──
              records.isEmpty
                  ? _buildEmptyState(theme, isDark)
                  : _buildTable(theme, isDark, esMobile, records),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.fileClock,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const Gap(16),
          Text(
            'No hay sesiones registradas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            'Inicie el monitoreo en el Dashboard para registrar mediciones.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? DarkColors.mutedForeground
                  : LightColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(
    ThemeData theme,
    bool isDark,
    bool esMobile,
    List records,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado de tabla — usa los mismos spacings que SessionHistoryRow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Mismo layout que el chevron en la fila: icon(16) + gap(12) = 28px
                const SizedBox(width: 28),
                Expanded(
                  flex: 2,
                  child: Text('Fecha', style: _headerStyle(theme, isDark)),
                ),
                if (!esMobile) ...[
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Duración',
                      style: _headerStyle(theme, isDark),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'MÍN | PROM | MÁX (FC)',
                      style: _headerStyle(theme, isDark),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'MÍN | PROM | MÁX (CO2)',
                      style: _headerStyle(theme, isDark),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                // Mismo ancho que los botones de acción en la fila.
                const SizedBox(width: 72),
              ],
            ),
          ),
          const Divider(height: 1),

          // Filas — shrinkWrap para que la tabla se ajuste al contenido
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final r = records[index];
              final isExpanded = _expandedRowIndex == index;

              return SessionHistoryRow(
                record: r,
                esMobile: esMobile,
                isExpanded: isExpanded,
                onTap: () {
                  setState(() {
                    _expandedRowIndex = isExpanded ? null : index;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  TextStyle? _headerStyle(ThemeData theme, bool isDark) {
    return theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 17,
      color: isDark
          ? DarkColors.foreground.withValues(alpha: 0.9)
          : LightColors.foreground.withValues(alpha: 0.9),
    );
  }
}
