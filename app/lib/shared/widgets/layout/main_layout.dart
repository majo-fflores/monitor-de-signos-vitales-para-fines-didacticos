import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/services/audio_service.dart';
import '../../providers/alarm_state.dart';
import 'animated_alarm_banner.dart';
import 'app_header.dart';
import 'app_sidebar.dart';
import 'critical_alarm_banner.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _borderAnimationController;
  late Animation<double> _borderOpacityAnimation;

  @override
  void initState() {
    super.initState();
    // El controller se crea detenido; solo se activa cuando la alarma lo requiere
    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _borderOpacityAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _borderAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _borderAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Selectores granulares: solo nos suscribimos a lo que necesitamos
    final alarmActive = ref.watch(
      alarmNotifierProvider.select((s) => s.alarmActive),
    );

    // Escuchar cambios de alarma a nivel global para reproducir o detener el sonido
    ref.listen<AlarmState>(alarmNotifierProvider, (prev, next) {
      if (next.alarmActive &&
          next.isSoundEnabled &&
          next.isEnabled &&
          !next.isSoundTemporarilyMuted) {
        AudioService.instance.startAlarm(next.selectedSound);
      } else {
        AudioService.instance.stopAlarm();
      }
    });

    // Controlar AnimationController solo cuando la alarma cambia de estado
    if (alarmActive) {
      if (!_borderAnimationController.isAnimating) {
        _borderAnimationController.repeat(reverse: true);
      }
    } else {
      if (_borderAnimationController.isAnimating) {
        _borderAnimationController.stop();
        _borderAnimationController.value = 0.0;
      }
    }

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
              // BANNER DE ALERTA MÉDICA CRÍTICA (animado y sin saltos abruptos)
              AnimatedAlarmBanner(
                visible: alarmActive,
                child: const CriticalAlarmBanner(),
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

    final esMobile = MediaQuery.of(context).size.width < Breakpoints.mobile;

    if (!alarmActive) {
      // Sin alarma, no necesitamos el AnimatedBuilder costoso
      return buildLayout(esMobile);
    }

    return AnimatedBuilder(
      animation: _borderOpacityAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red.withValues(
                alpha: _borderOpacityAnimation.value,
              ),
              width: 4,
            ),
          ),
          child: child,
        );
      },
      child: buildLayout(esMobile),
    );
  }
}
