import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_state.dart';

part 'alarm_history_provider.g.dart';

@immutable
class AlarmRecord {
  final String id;
  final DateTime timestamp;
  final List<String> metrics;
  final Map<String, int> values;

  const AlarmRecord({
    required this.id,
    required this.timestamp,
    required this.metrics,
    required this.values,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': timestamp
          .toIso8601String(), // Mantener 'fecha' para compatibilidad local
      'metricas': metrics,
      'valores': values,
    };
  }

  factory AlarmRecord.fromJson(Map<String, dynamic> json) {
    return AlarmRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(
        json['fecha'] as String? ?? json['timestamp'] as String,
      ),
      metrics: List<String>.from(
        json['metricas'] as List? ?? json['metrics'] as List,
      ),
      values: Map<String, int>.from(
        json['valores'] as Map? ?? json['values'] as Map,
      ),
    );
  }
}

@riverpod
class AlarmHistory extends _$AlarmHistory {
  static const _historyKey = 'historial_alarmas_json';
  SharedPreferences? _prefs;

  @override
  List<AlarmRecord> build() {
    _loadHistory();
    return [];
  }

  Future<void> _loadHistory() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final listJson = _prefs?.getStringList(_historyKey);
      if (listJson != null) {
        state =
            listJson
                .map(
                  (item) => AlarmRecord.fromJson(
                    json.decode(item) as Map<String, dynamic>,
                  ),
                )
                .toList()
              ..sort(
                (a, b) => b.timestamp.compareTo(a.timestamp),
              ); // El más reciente primero
      }
    } catch (e) {
      debugPrint('Error cargando historial de alarmas: $e');
    }
  }

  Future<void> recordAlarm(List<CriticalAlert> alerts) async {
    if (alerts.isEmpty) return;

    final newRecord = AlarmRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      metrics: alerts.map((a) => a.metric).toList(),
      values: {for (var a in alerts) a.metric: a.value},
    );

    state = [newRecord, ...state];

    _prefs ??= await SharedPreferences.getInstance();
    final listJson = state.map((r) => json.encode(r.toJson())).toList();
    await _prefs?.setStringList(_historyKey, listJson);
  }

  Future<void> clearHistory() async {
    state = [];
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(_historyKey);
  }
}
