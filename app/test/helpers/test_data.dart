import 'package:datavital_flutter/core/models/registro_medicion.dart';
import 'package:datavital_flutter/core/models/usuario.dart';
import 'package:datavital_flutter/core/models/ws_packet.dart';

class TestData {
  static final usuario1 = Usuario(
    id: 'user_123',
    nombre: 'John Doe',
    email: 'john@example.com',
    creadoEn: DateTime(2026, 6, 1, 12, 0),
  );

  static final usuario2 = Usuario(
    id: 'user_456',
    nombre: 'Jane Smith',
    email: 'jane@example.com',
    creadoEn: DateTime(2026, 6, 2, 12, 0),
  );

  static final registro1 = RegistroMedicion(
    id: 'reg_1',
    usuarioId: 'user_123',
    fechaRegistro: DateTime(2026, 6, 4, 10, 0),
    duracionSegundos: 45,
    frecuenciaCardiaca: 72,
    minFrecuenciaCardiaca: 60,
    maxFrecuenciaCardiaca: 90,
    ppgFrecuenciaCardiaca: 73,
    minPpgFrecuenciaCardiaca: 60,
    maxPpgFrecuenciaCardiaca: 90,
    nivelSpo2: 98,
    minSpo2: 95,
    maxSpo2: 100,
    nivelCo2: 380,
    minCo2: 350,
    maxCo2: 400,
    alertasDisparadas: 0,
    notasClinicas: 'Normal state',
  );

  static final registroCritico = RegistroMedicion(
    id: 'reg_critico',
    usuarioId: 'user_123',
    fechaRegistro: DateTime(2026, 6, 4, 10, 5),
    duracionSegundos: 120,
    frecuenciaCardiaca: 110,
    minFrecuenciaCardiaca: 90,
    maxFrecuenciaCardiaca: 130,
    ppgFrecuenciaCardiaca: 109,
    minPpgFrecuenciaCardiaca: 90,
    maxPpgFrecuenciaCardiaca: 130,
    nivelSpo2: 92,
    minSpo2: 85,
    maxSpo2: 95,
    nivelCo2: 900,
    minCo2: 800,
    maxCo2: 1000,
    alertasDisparadas: 3,
    notasClinicas: 'Critical patient readings',
  );

  static final wsPacketEcg = WsPacket(
    type: 'ecg',
    value: 0.5,
    timestamp: 1748383032000,
  );

  static final wsPacketSpo2 = WsPacket(
    type: 'spo2',
    value: 98.0,
    timestamp: 1748383032100,
  );

  static final wsPacketBpm = WsPacket(
    type: 'bpm',
    value: 75.0,
    timestamp: 1748383032200,
  );

  static final wsPacketCo2 = WsPacket(
    type: 'co2',
    value: 400.0,
    timestamp: 1748383032300,
  );
}
