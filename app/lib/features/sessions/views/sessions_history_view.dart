import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/historial_provider.dart';
import '../../../../shared/providers/usuario_provider.dart';

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

    // ── KPIs ──
    final total = registros.length;
    double promFC = 0, promSpo2 = 0;
    int durTotal = 0;
    if (total > 0) {
      double sFC = 0, sSpo2 = 0;
      for (final r in registros) {
        sFC += r.frecuenciaCardiaca;
        sSpo2 += r.nivelSpo2;
        durTotal += r.duracionSegundos;
      }
      promFC = sFC / total;
      promSpo2 = sSpo2 / total;
    }

    String fmtDur(int s) {
      if (s < 60) return '${s}s';
      final m = s ~/ 60;
      if (m < 60) return '${m}m';
      return '${m ~/ 60}h ${m % 60}m';
    }

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

            // ── KPI strip ──
            SizedBox(
              height: 76,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _KpiChip(
                    titulo: 'Sesiones',
                    valor: '$total',
                    icono: LucideIcons.checkSquare,
                    color: const Color(0xFF8B5CF6),
                    theme: theme,
                    esOscuro: esOscuro,
                  ),
                  const SizedBox(width: 12),
                  _KpiChip(
                    titulo: 'Prom. FC',
                    valor: '${promFC.round()} LPM',
                    icono: LucideIcons.heart,
                    color: ColoresSensores.ecgVerde,
                    theme: theme,
                    esOscuro: esOscuro,
                  ),
                  const SizedBox(width: 12),
                  _KpiChip(
                    titulo: 'Prom. SpO2',
                    valor: '${promSpo2.round()}%',
                    icono: LucideIcons.droplets,
                    color: ColoresSensores.spo2Azul,
                    theme: theme,
                    esOscuro: esOscuro,
                  ),
                  const SizedBox(width: 12),
                  _KpiChip(
                    titulo: 'Tiempo Total',
                    valor: fmtDur(durTotal),
                    icono: LucideIcons.clock,
                    color: const Color(0xFFF59E0B),
                    theme: theme,
                    esOscuro: esOscuro,
                  ),
                ],
              ),
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

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Fila principal (clickeable)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _filaExpandida =
                                              expandida ? null : index;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            AnimatedRotation(
                                              turns: expandida ? 0.25 : 0,
                                              duration: const Duration(
                                                  milliseconds: 150),
                                              child: Icon(
                                                LucideIcons.chevronRight,
                                                size: 16,
                                                color: theme.colorScheme.onSurface
                                                    .withValues(alpha: 0.4),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                r.fechaFormateada,
                                                style: theme.textTheme.bodyMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w500),
                                              ),
                                            ),
                                            if (!esMobile) ...[
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  r.duracionFormateada,
                                                  style: theme
                                                      .textTheme.bodyMedium,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: ColoresSensores
                                                            .ecgVerde,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '${r.frecuenciaCardiaca} LPM',
                                                      style: theme.textTheme
                                                          .bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: ColoresSensores
                                                            .spo2Azul,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '${r.nivelSpo2}%',
                                                      style: theme.textTheme
                                                          .bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            // Botón eliminar
                                            SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: IconButton(
                                                icon: const Icon(
                                                    LucideIcons.trash2,
                                                    size: 14),
                                                color: theme.colorScheme.error
                                                    .withValues(alpha: 0.6),
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (ctx) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          '¿Eliminar sesión?'),
                                                      content: const Text(
                                                          'Se eliminará permanentemente esta medición.'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  ctx),
                                                          child: const Text(
                                                              'Cancelar'),
                                                        ),
                                                        FilledButton(
                                                          onPressed: () {
                                                            Navigator.pop(ctx);
                                                            ref
                                                                .read(
                                                                    notificadorHistorialProvider
                                                                        .notifier)
                                                                .eliminarRegistro(
                                                                    r.id,
                                                                    usuarioActivo
                                                                        .id);
                                                          },
                                                          style: FilledButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                theme
                                                                    .colorScheme
                                                                    .error,
                                                            foregroundColor:
                                                                theme
                                                                    .colorScheme
                                                                    .onError,
                                                          ),
                                                          child: const Text(
                                                              'Eliminar'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Panel expandido con detalles completos
                                    AnimatedCrossFade(
                                      firstChild: const SizedBox.shrink(),
                                      secondChild: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.fromLTRB(
                                            44, 0, 16, 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Grid compacto de métricas
                                            Wrap(
                                              spacing: 16,
                                              runSpacing: 8,
                                              children: [
                                                _MetricaInline(
                                                  label: 'Frecuencia Cardíaca',
                                                  value:
                                                      '${r.frecuenciaCardiaca} LPM',
                                                  color:
                                                      ColoresSensores.ecgVerde,
                                                  theme: theme,
                                                  esOscuro: esOscuro,
                                                ),
                                                _MetricaInline(
                                                  label: 'SpO2',
                                                  value: '${r.nivelSpo2}%',
                                                  color:
                                                      ColoresSensores.spo2Azul,
                                                  theme: theme,
                                                  esOscuro: esOscuro,
                                                ),
                                                _MetricaInline(
                                                  label: 'CO2',
                                                  value: '${r.nivelCo2} ppm',
                                                  color: ColoresSensores
                                                      .co2Amarillo,
                                                  theme: theme,
                                                  esOscuro: esOscuro,
                                                ),
                                                _MetricaInline(
                                                  label: 'Amplitud Acústica',
                                                  value:
                                                      '${r.amplitudAcustica}%',
                                                  color:
                                                      const Color(0xFF06B6D4),
                                                  theme: theme,
                                                  esOscuro: esOscuro,
                                                ),
                                                _MetricaInline(
                                                  label: 'Duración',
                                                  value: r.duracionFormateada,
                                                  color:
                                                      const Color(0xFFF59E0B),
                                                  theme: theme,
                                                  esOscuro: esOscuro,
                                                ),
                                                if (r.alertasDisparadas > 0)
                                                  _MetricaInline(
                                                    label: 'Alertas',
                                                    value:
                                                        '${r.alertasDisparadas}',
                                                    color: theme
                                                        .colorScheme.error,
                                                    theme: theme,
                                                    esOscuro: esOscuro,
                                                  ),
                                              ],
                                            ),
                                            if (r.notasClinicas
                                                .isNotEmpty) ...[
                                              const Gap(12),
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: esOscuro
                                                      ? Colors.white.withValues(
                                                          alpha: 0.02)
                                                      : Colors.black.withValues(
                                                          alpha: 0.02),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: esOscuro
                                                        ? ColoresOscuros.border
                                                        : ColoresClaros.border,
                                                  ),
                                                ),
                                                child: Text(
                                                  r.notasClinicas,
                                                  style: theme
                                                      .textTheme.bodySmall,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      crossFadeState: expandida
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      sizeCurve: Curves.easeOut,
                                    ),
                                  ],
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

// ─────────────────────────────────────────────────────────────────────────────
// KPI horizontal chip (para el strip superior)
// ─────────────────────────────────────────────────────────────────────────────
class _KpiChip extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final ThemeData theme;
  final bool esOscuro;

  const _KpiChip({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    required this.theme,
    required this.esOscuro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: esOscuro ? ColoresOscuros.border : ColoresClaros.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titulo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: esOscuro
                      ? ColoresOscuros.mutedForeground
                      : ColoresClaros.mutedForeground,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                valor,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Métrica inline para el panel expandido
// ─────────────────────────────────────────────────────────────────────────────
class _MetricaInline extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;
  final bool esOscuro;

  const _MetricaInline({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    required this.esOscuro,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: esOscuro
                ? ColoresOscuros.mutedForeground
                : ColoresClaros.mutedForeground,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ],
    );
  }
}
