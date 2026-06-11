import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/models/measurement.dart';
import '../../../shared/providers/session_provider.dart';

/// Widget que carga bajo demanda y muestra en tablas scrollables los datos crudos
/// de BPM, ECG y AIR para una sesión en particular.
class SessionRawDataTable extends ConsumerStatefulWidget {
  final int sessionId;

  const SessionRawDataTable({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<SessionRawDataTable> createState() => _SessionRawDataTableState();
}

class _SessionRawDataTableState extends ConsumerState<SessionRawDataTable> {
  bool _cargando = true;
  String? _error;
  List<Sample> _bpmSamples = [];
  List<Sample> _ecgSamples = [];
  List<Sample> _airSamples = [];

  late final ScrollController _bpmScrollController;
  late final ScrollController _ecgScrollController;
  late final ScrollController _airScrollController;

  @override
  void initState() {
    super.initState();
    _bpmScrollController = ScrollController();
    _ecgScrollController = ScrollController();
    _airScrollController = ScrollController();
    _cargarDatos();
  }

  @override
  void dispose() {
    _bpmScrollController.dispose();
    _ecgScrollController.dispose();
    _airScrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final measApi = ref.read(measurementApiServiceProvider);

      final results = await Future.wait([
        measApi.obtenerMedicionesPorSesion('bpm', widget.sessionId),
        measApi.obtenerMedicionesPorSesion('ecg', widget.sessionId),
        measApi.obtenerMedicionesPorSesion('air', widget.sessionId),
      ]);

      final bpmMeasurements = results[0];
      final ecgMeasurements = results[1];
      final airMeasurements = results[2];

      final bpmSamples = bpmMeasurements.expand((m) => m.datos).toList();
      final ecgSamples = ecgMeasurements.expand((m) => m.datos).toList();
      final airSamples = airMeasurements.expand((m) => m.datos).toList();

      // Ordenar por timestamp cronológicamente
      bpmSamples.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      ecgSamples.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      airSamples.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (mounted) {
        setState(() {
          _bpmSamples = bpmSamples;
          _ecgSamples = ecgSamples;
          _airSamples = airSamples;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar datos crudos: $e';
          _cargando = false;
        });
      }
    }
  }

  String _formatearTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      timestamp < 1000000000000 ? timestamp * 1000 : timestamp
    ).toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.alertTriangle, color: Colors.red),
              const Gap(8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              TextButton.icon(
                onPressed: _cargarDatos,
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.hintColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.heart, size: 16),
                      SizedBox(width: 6),
                      Text('BPM'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.activity, size: 16),
                      SizedBox(width: 6),
                      Text('ECG'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.wind, size: 16),
                      SizedBox(width: 6),
                      Text('Aire'),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            SizedBox(
              height: 220,
              child: TabBarView(
                children: [
                  _buildSensorTable(_bpmSamples, 'BPM', (val) => val < 60 || val > 100, 'LPM', _bpmScrollController),
                  _buildSensorTable(_ecgSamples, 'ECG', (_) => false, 'mV', _ecgScrollController),
                  _buildSensorTable(_airSamples, 'AIR', (val) => val > 1000, 'ppm', _airScrollController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorTable(List<Sample> samples, String label, bool Function(double) isOutOfRange, String unit, ScrollController scrollController) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (samples.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.database, size: 32, color: theme.disabledColor),
            const Gap(8),
            Text(
              'No hay muestras registradas para $label',
              style: TextStyle(color: theme.disabledColor),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Encabezado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[200],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hora de Registro',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Valor ($unit)',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        // Listado
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            child: ListView.builder(
              controller: scrollController,
              itemCount: samples.length,
              itemExtent: 36,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final sample = samples[index];
                final outOfRange = isOutOfRange(sample.value);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatearTimestamp(sample.timestamp),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                      Row(
                        children: [
                          if (outOfRange) ...[
                            const Icon(LucideIcons.alertCircle, color: Colors.orange, size: 14),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            '${sample.value.toStringAsFixed(1)} $unit',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: outOfRange ? FontWeight.bold : FontWeight.normal,
                              color: outOfRange ? Colors.orange : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // Pie de tabla
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Text(
            'Total: ${samples.length} muestras',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
