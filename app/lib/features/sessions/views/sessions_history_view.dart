import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/historial_provider.dart';
import '../../../../shared/providers/usuario_provider.dart';
import '../widgets/session_history_row.dart';
import '../widgets/history_statistics_summary.dart';

/// Vista del historial de mediciones.
/// Usa filas expandibles compactas para no ocupar demasiado espacio vertical.
class SessionsHistoryView extends ConsumerStatefulWidget {
  const SessionsHistoryView({super.key});

  @override
  ConsumerState<SessionsHistoryView> createState() => _SessionsHistoryViewState();
}

class _SessionsHistoryViewState extends ConsumerState<SessionsHistoryView> {
  int? _filaExpandida;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final activo = ref.read(notificadorUsuariosProvider).usuarioActivo;
      if (activo != null) {
        ref.read(notificadorHistorialProvider.notifier).cargarHistorial(activo.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;
    final estadoHistorial = ref.watch(notificadorHistorialProvider);
    final usuarioActivo = ref.watch(notificadorUsuariosProvider).usuarioActivo;

    if (usuarioActivo == null) {
      return const Center(child: Text('No hay ningún usuario activo seleccionado.'));
    }

    if (estadoHistorial.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final registros = estadoHistorial.registros;

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMobile = constraints.maxWidth < Breakpoints.tablet;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Título ──
            Text(
              'Historial de Sesiones',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: esOscuro ? ColoresOscuros.foreground : ColoresClaros.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Historial clínico de ${usuarioActivo.nombre}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
              ),
            ),
            const Gap(24),

            // ── KPI strip componentizado ──
            HistoryStatisticsSummary(
              registros: registros,
              theme: theme,
              esOscuro: esOscuro,
            ),
            const Gap(24),

            // ── Tabla compacta con filas expandibles ──
            Expanded(
              child: registros.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.fileClock,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                          const Gap(16),
                          Text(
                            'No hay sesiones registradas',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Gap(8),
                          Text(
                            'Inicie el monitoreo en el Dashboard para registrar mediciones.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: esOscuro
                                  ? ColoresOscuros.mutedForeground
                                  : ColoresClaros.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: esOscuro ? ColoresOscuros.border : ColoresClaros.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Encabezado de tabla
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: esOscuro
                                  ? Colors.white.withValues(alpha: 0.02)
                                  : Colors.black.withValues(alpha: 0.02),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 32), // espacio para chevron
                                Expanded(
                                  flex: 3,
                                  child: Text('Fecha',
                                      style: _headerStyle(theme, esOscuro)),
                                ),
                                if (!esMobile) ...[
                                  Expanded(
                                    flex: 2,
                                    child: Text('Duración',
                                        style: _headerStyle(theme, esOscuro)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('FC',
                                        style: _headerStyle(theme, esOscuro)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('SpO2',
                                        style: _headerStyle(theme, esOscuro)),
                                  ),
                                ],
                                const SizedBox(width: 40),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          // Filas
                          Expanded(
                            child: ListView.separated(
                              itemCount: registros.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final r = registros[index];
                                final expandida = _filaExpandida == index;

                                return SessionHistoryRow(
                                  registro: r,
                                  esMobile: esMobile,
                                  expandida: expandida,
                                  onTap: () {
                                    setState(() {
                                      _filaExpandida = expandida ? null : index;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  TextStyle? _headerStyle(ThemeData theme, bool esOscuro) {
    return theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color:
          esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
      fontSize: 11,
      letterSpacing: 0.5,
    );
  }
}
