import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../shared/providers/vital_signs_provider.dart';
import '../widgets/ecg_chart.dart';
import '../widgets/spo2_chart.dart';
import '../widgets/pcg_chart.dart';
import '../widgets/vital_kpi_card.dart';

/// Vista principal de monitoreo en tiempo real.
/// Se suscribe de manera selectiva a los flujos del NotificadorSignosVitales.
class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Ejecutamos la simulación al montar el componente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificadorSignosVitalesProvider.notifier).iniciarSimulacion();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;
    
    // Suscripción selectiva a cada signo vital para evitar re-pintados innecesarios
    final ecgDatos = ref.watch(notificadorSignosVitalesProvider.select((s) => s.ecgDatos));
    final spo2Datos = ref.watch(notificadorSignosVitalesProvider.select((s) => s.spo2Datos));
    final pcgDatos = ref.watch(notificadorSignosVitalesProvider.select((s) => s.pcgDatos));
    final frecuenciaCardiaca = ref.watch(notificadorSignosVitalesProvider.select((s) => s.frecuenciaCardiaca));
    final nivelSpo2 = ref.watch(notificadorSignosVitalesProvider.select((s) => s.nivelSpo2));
    final nivelCo2 = ref.watch(notificadorSignosVitalesProvider.select((s) => s.nivelCo2));
    final amplitudAcustica = ref.watch(notificadorSignosVitalesProvider.select((s) => s.amplitudAcustica));

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMobile = constraints.maxWidth < Breakpoints.tablet;

        final contenidoPrincipal = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la sección
            Text(
              'Dashboard de Bioseñales',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: esOscuro ? ColoresOscuros.foreground : ColoresClaros.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Visualización en tiempo real gestionada por store global de estado (Riverpod).',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),

            // Grid adaptativo
            Expanded(
              child: SingleChildScrollView(
                child: esMobile
                    ? Column(
                        children: [
                          // En móviles: KPI Cards primero en forma compacta
                          _buildPanelesKpi(
                            frecuenciaCardiaca: frecuenciaCardiaca,
                            nivelSpo2: nivelSpo2,
                            nivelCo2: nivelCo2,
                            amplitudAcustica: amplitudAcustica,
                            esMobile: true,
                          ),
                          const SizedBox(height: 24),
                          // Gráficos debajo
                          _buildGraficosOndas(
                            ecgDatos: ecgDatos, 
                            spo2Datos: spo2Datos,
                            pcgDatos: pcgDatos,
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En pantallas grandes: Gráficos a la izquierda (flex 3)
                          Expanded(
                            flex: 3,
                            child: _buildGraficosOndas(
                              ecgDatos: ecgDatos, 
                              spo2Datos: spo2Datos,
                              pcgDatos: pcgDatos,
                            ),
                          ),
                          const SizedBox(width: 24),
                          // KPI Cards a la derecha (flex 1)
                          Expanded(
                            flex: 1,
                            child: _buildPanelesKpi(
                              frecuenciaCardiaca: frecuenciaCardiaca,
                              nivelSpo2: nivelSpo2,
                              nivelCo2: nivelCo2,
                              amplitudAcustica: amplitudAcustica,
                              esMobile: false,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );

        return contenidoPrincipal;
      },
    );
  }

  Widget _buildGraficosOndas({
    required List<PuntoBiometrico> ecgDatos,
    required List<PuntoBiometrico> spo2Datos,
    required List<PuntoBiometrico> pcgDatos,
  }) {
    return Column(
      children: [
        // Card ECG (AD8232)
        Card(
          clipBehavior: Clip.antiAlias,
          child: GraficoEcg(datos: ecgDatos),
        ),
        const SizedBox(height: 16),
        // Card SpO2 (MAX30100)
        Card(
          clipBehavior: Clip.antiAlias,
          child: GraficoSpo2(datos: spo2Datos),
        ),
        const SizedBox(height: 16),
        // Card Fonocardiograma (LM386)
        Card(
          clipBehavior: Clip.antiAlias,
          child: GraficoPcg(datos: pcgDatos),
        ),
      ],
    );
  }

  Widget _buildPanelesKpi({
    required int frecuenciaCardiaca,
    required int nivelSpo2,
    required int nivelCo2,
    required int amplitudAcustica,
    required bool esMobile,
  }) {
    final listaKpis = [
      TarjetaKpiVital(
        titulo: 'AD8232 (Frecuencia Cardíaca)',
        valor: '$frecuenciaCardiaca',
        unidad: 'LPM',
        colorAcento: ColoresSensores.ecgVerde,
      ),
      const SizedBox(height: 16),
      TarjetaKpiVital(
        titulo: 'MAX30100 (Saturación SpO2)',
        valor: '$nivelSpo2',
        unidad: '%',
        colorAcento: ColoresSensores.spo2Azul,
      ),
      const SizedBox(height: 16),
      TarjetaKpiVital(
        titulo: 'MQ-135 (Dióxido de Carbono)',
        valor: '$nivelCo2',
        unidad: 'ppm',
        colorAcento: ColoresSensores.co2Amarillo,
      ),
      const SizedBox(height: 16),
      TarjetaKpiVital(
        titulo: 'LM386 (Amplitud de Audio)',
        valor: '$amplitudAcustica',
        unidad: '%',
        colorAcento: Colors.cyanAccent.shade400,
      ),
    ];

    if (esMobile) {
      return Column(
        children: [
          listaKpis[0],
          const SizedBox(height: 12),
          listaKpis[2],
          const SizedBox(height: 12),
          listaKpis[4],
          const SizedBox(height: 12),
          listaKpis[6],
        ],
      );
    } else {
      return Column(
        children: listaKpis,
      );
    }
  }
}
