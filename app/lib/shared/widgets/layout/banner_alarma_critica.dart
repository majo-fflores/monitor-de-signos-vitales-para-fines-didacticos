import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../providers/alarma_state.dart';

/// Banner de alarma crítica extraído para rendimiento.
/// Solo se reconstruye cuando cambian sus campos específicos.
class BannerAlarmaCritica extends ConsumerWidget {
  const BannerAlarmaCritica({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertasActivas = ref.watch(
      notificadorAlarmaProvider.select((s) => s.alertasActivas),
    );
    final segundosRestantes = ref.watch(
      notificadorAlarmaProvider.select((s) => s.segundosRestantes),
    );
    final sonidoHabilitado = ref.watch(
      notificadorAlarmaProvider.select((s) => s.sonidoHabilitado),
    );
    final sonidoSilenciado = ref.watch(
      notificadorAlarmaProvider.select((s) => s.sonidoSilenciadoTemporalmente),
    );

    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, bannerConstraints) {
        final esMobileChico = bannerConstraints.maxWidth < 600;

        final infoAlarma = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 24,
            ),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ALARMA CRÍTICA',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    '${alertasActivas.map((a) => '${a.metrica}: ${a.valor}').join(' | ')} — Ciclo de seguridad en curso',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final controlesAlarma = Row(
          mainAxisAlignment: esMobileChico
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 12),
                  const Gap(4),
                  Text(
                    '${segundosRestantes}s',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
              ),
              onPressed: () {
                context.go('/alertas');
              },
              icon: const Icon(Icons.visibility, size: 14, color: Colors.white),
              label: const Text(
                'VER DETALLES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ),
            if (sonidoHabilitado) ...[
              const Gap(8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade900,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  if (sonidoSilenciado) {
                    ref
                        .read(notificadorAlarmaProvider.notifier)
                        .desactivarSilencioTemporal();
                  } else {
                    ref
                        .read(notificadorAlarmaProvider.notifier)
                        .silenciarAlarma();
                  }
                },
                icon: Icon(
                  sonidoSilenciado ? Icons.volume_up : Icons.volume_off,
                  size: 14,
                ),
                label: Text(
                  sonidoSilenciado ? 'ACTIVAR SONIDO' : 'SILENCIAR',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
            const Gap(8),
            IconButton(
              tooltip: 'Descartar Alarma',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
              ),
              icon: const Icon(Icons.close, size: 14),
              onPressed: () {
                ref.read(notificadorAlarmaProvider.notifier).descartarAlarma();
              },
            ),
          ],
        );

        if (esMobileChico) {
          return Container(
            width: double.infinity,
            color: Colors.red.shade900,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [infoAlarma, const Gap(8), controlesAlarma],
            ),
          );
        }

        return Container(
          width: double.infinity,
          color: Colors.red.shade900,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: infoAlarma),
              const Gap(16),
              controlesAlarma,
            ],
          ),
        );
      },
    );
  }
}
