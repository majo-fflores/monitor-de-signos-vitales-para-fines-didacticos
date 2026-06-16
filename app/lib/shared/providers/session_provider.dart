import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/measurement_api_service.dart';
import '../../core/services/session_api_service.dart';
import 'connection_provider.dart';

part 'session_provider.g.dart';

@riverpod
SessionApiService sessionApiService(SessionApiServiceRef ref) {
  final conexionState = ref.watch(notificadorConexionProvider);
  String httpUrl = 'http://localhost:8080';
  final wsUrl = conexionState.wsUrl;

  if (wsUrl.startsWith('ws://')) {
    httpUrl = wsUrl
        .replaceFirst('ws://', 'http://')
        .replaceAll('/ws/sensors', '');
  } else if (wsUrl.startsWith('wss://')) {
    httpUrl = wsUrl
        .replaceFirst('wss://', 'https://')
        .replaceAll('/ws/sensors', '');
  }

  return SessionApiService(baseUrl: httpUrl);
}

@riverpod
MeasurementApiService measurementApiService(MeasurementApiServiceRef ref) {
  final conexionState = ref.watch(notificadorConexionProvider);
  String httpUrl = 'http://localhost:8080';
  final wsUrl = conexionState.wsUrl;

  if (wsUrl.startsWith('ws://')) {
    httpUrl = wsUrl
        .replaceFirst('ws://', 'http://')
        .replaceAll('/ws/sensors', '');
  } else if (wsUrl.startsWith('wss://')) {
    httpUrl = wsUrl
        .replaceFirst('wss://', 'https://')
        .replaceAll('/ws/sensors', '');
  }

  return MeasurementApiService(baseUrl: httpUrl);
}
