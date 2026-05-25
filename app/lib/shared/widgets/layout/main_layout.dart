import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/breakpoints.dart';
import '../../providers/alarma_state.dart';
import 'app_sidebar.dart';
import 'app_header.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _borderAnimationController;
  late Animation<double> _borderOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _borderOpacityAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _borderAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _borderAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estadoAlarma = ref.watch(notificadorAlarmaProvider);
    final theme = Theme.of(context);

    final warningBorder = estadoAlarma.alarmaActiva
        ? Border.all(
            color: Colors.red.withValues(alpha: _borderOpacityAnimation.value),
            width: 4,
          )
        : null;

    Widget buildLayout(bool esMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: esMobile
            ? Drawer(
                width: 96,
                child: AppSidebar(
                  onClose: () => _scaffoldKey.currentState?.closeDrawer(),
                ),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              // BANNER DE ALERTA MÉDICA CRÍTICA (Ciclo de 30 segundos)
              if (estadoAlarma.alarmaActiva)
                LayoutBuilder(
                  builder: (context, bannerConstraints) {
                    final esMobileChico = bannerConstraints.maxWidth < 600;
                    
                    final infoAlarma = Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
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
                                '${estadoAlarma.metricaCritica}: ${estadoAlarma.valorCritico} — Ciclo de seguridad en curso',
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
                      mainAxisAlignment: esMobileChico ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                                '${estadoAlarma.segundosRestantes}s',
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
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red.shade900,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: () {
                            ref.read(notificadorAlarmaProvider.notifier).silenciarAlarma();
                          },
                          icon: const Icon(Icons.volume_off, size: 14),
                          label: const Text(
                            'SILENCIAR',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
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
                          children: [
                            infoAlarma,
                            const Gap(8),
                            controlesAlarma,
                          ],
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
                ),
              Expanded(
                child: Row(
                  children: [
                    if (!esMobile) const AppSidebar(),
                    Expanded(
                      child: Column(
                        children: [
                          AppHeader(
                            mostrarBotonMenu: esMobile,
                            onMenuClick: esMobile
                                ? () => _scaffoldKey.currentState?.openDrawer()
                                : null,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(esMobile ? 24.0 : 32.0),
                              child: widget.child,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMobile = constraints.maxWidth < Breakpoints.mobile;
        
        return AnimatedBuilder(
          animation: _borderOpacityAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                border: warningBorder,
              ),
              child: child,
            );
          },
          child: buildLayout(esMobile),
        );
      },
    );
  }
}
