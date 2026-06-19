import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/models/measurement_record.dart';
import 'session_provider.dart';

part 'history_provider.g.dart';

/// Estado inmutable del historial de mediciones del usuario activo.
@immutable
class HistoryState {
  final List<MeasurementRecord> records;
  final bool isLoading;
  final String? loadedUserId;

  const HistoryState({
    required this.records,
    required this.isLoading,
    this.loadedUserId,
  });

  factory HistoryState.inicial() {
    return const HistoryState(records: [], isLoading: false);
  }

  HistoryState copiarCon({
    List<MeasurementRecord>? records,
    bool? isLoading,
    String? loadedUserId,
  }) {
    return HistoryState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      loadedUserId: loadedUserId ?? this.loadedUserId,
    );
  }
}

/// Notifier reactivo para el historial de mediciones.
/// Los registros se guardan y cargan desde el backend.
@Riverpod(keepAlive: true)
class HistoryNotifier extends _$HistoryNotifier {
  @override
  HistoryState build() {
    return HistoryState.inicial();
  }

  /// Carga los registros de medición de un usuario específico desde el backend.
  Future<void> loadHistory(String userId) async {
    state = state.copiarCon(isLoading: true);
    List<MeasurementRecord> records = [];
    final uId = int.tryParse(userId);

    if (uId != null) {
      try {
        final sessionApi = ref.read(sessionApiServiceProvider);

        final summaries = await sessionApi.getSessionSummaries(uId);

        records = summaries
            .map((s) => MeasurementRecord.fromSessionWithSummary(s))
            .toList();

        // Ordenamos por fecha descendente (más reciente primero)
        records.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
      } catch (e) {
        debugPrint(
          '[HistoryNotifier] Error al cargar historial desde el backend: $e',
        );
        records = [];
      }
    }

    state = state.copiarCon(
      records: records,
      isLoading: false,
      loadedUserId: userId,
    );
  }

  /// Guarda un nuevo registro en memoria para visualización inmediata.
  Future<void> saveRecord(MeasurementRecord record) async {
    final newList = [record, ...state.records];
    state = state.copiarCon(records: newList);
  }

  /// Elimina un registro de medición específico (elimina la sesión del backend).
  Future<void> deleteRecord(String recordId, String userId) async {
    final newList = state.records.where((r) => r.id != recordId).toList();
    state = state.copiarCon(records: newList);

    final sessionId = int.tryParse(recordId);
    if (sessionId != null) {
      try {
        await ref.read(sessionApiServiceProvider).deleteSession(sessionId);
      } catch (e) {
        debugPrint(
          '[HistoryNotifier] Error al eliminar sesión $sessionId del backend: $e',
        );
      }
    }
  }

  /// Limpia el historial cargado (al cambiar de usuario).
  void clear() {
    state = HistoryState.inicial();
  }
}
