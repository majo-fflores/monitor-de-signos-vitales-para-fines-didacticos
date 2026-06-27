# DataVital - Monitor multiparametrico de signos vitales con fines didacticos

## 1. Resumen del proyecto

**DataVital** es un sistema de monitoreo multiparametrico de signos vitales orientado a la ensenanza de adquisicion, procesamiento, visualizacion y alarmado de senales fisiologicas en tiempo real blando.

El proyecto combina un modulo embebido de adquisicion con sensores reales, un backend local desarrollado en **Go con Echo**, una base de datos **SQLite** y una aplicacion de escritorio desarrollada en **Flutter**, donde se muestran curvas, valores numericos, alarmas configurables y registros historicos. El sistema esta pensado exclusivamente para actividades didacticas, demostraciones y validacion academica, no para uso clinico, diagnostico ni terapeutico.

## 2. Objetivo general

Desarrollar un monitor didactico capaz de adquirir senales de sensores biomedicos y ambientales, visualizarlas en tiempo real desde una aplicacion de escritorio, registrar muestras en almacenamiento local y generar alarmas configurables ante valores fuera de rango.

## 3. Objetivos especificos

- Implementar adquisicion periodica de senales provenientes de sensores reales.
- Visualizar curvas y parametros numericos en una interfaz grafica de escritorio.
- Registrar muestras en memoria microSD usando una referencia temporal basada en `millis`.
- Configurar umbrales de alarma desde la aplicacion.
- Activar un ciclo de alarma de 30 segundos ante mediciones fuera de rango.
- Permitir silenciar o postergar alarmas desde la interfaz de usuario.
- Descargar datos registrados a pedido del usuario desde la aplicacion.
- Persistir sesiones, pacientes, mediciones, umbrales y eventos de alarma en SQLite.
- Mantener una visualizacion local simple en OLED con valores numericos y alerta visual.

## 4. Alcance del sistema

El sistema contempla el monitoreo de las siguientes senales y variables:

| Modulo | Variable asociada | Tipo de dato | Uso en el sistema |
| --- | --- | --- | --- |
| AD8232 | ECG | Analogico | Curva electrocardiografica y deteccion de electrodos desconectados |
| MAX30100 / HW-827 | Frecuencia cardiaca y SpO2 | Digital I2C / pulso | Valores numericos y curva pletismografica |
| MQ-135 | Calidad de aire / CO2 estimado | Analogico y digital | Medicion ambiental y alarma por umbral |
| LM386 | Sonido cardiaco o respiratorio amplificado | Analogico | Fonocardiograma o referencia acustica |
| microSD | Registro de muestras | SPI | Datalogger local |
| OLED SSD1306 | Visualizacion local | I2C | Tres valores numericos y alerta visual |

Por indicacion docente, no se requiere almacenar fecha y hora reales en la SD. Cada muestra debe incluir una marca temporal relativa generada con `millis`, suficiente para reconstruir el orden y la separacion temporal entre mediciones.

## 5. Restricciones y consideraciones

- Los sensores definidos para el grupo son **LM386**, **MQ-135**, **HW-827 / MAX30100** y **AD8232**.
- Es conveniente contar con un programa separado por sensor para facilitar la revision individual.
- La SD debe registrar una marca de tiempo relativa con `millis`, no un timestamp real.
- La descarga de datos se inicia a pedido desde la aplicacion de escritorio.
- Opcionalmente, la aplicacion puede indicar el nombre del paciente antes de descargar o asociar registros.
- El OLED debe mostrar aproximadamente tres datos numericos.
- El OLED debe incluir una alerta visual, por ejemplo un texto `PELIGRO` parpadeante.
- La visualizacion compleja queda en la app de escritorio: graficos, historiales, tendencias y paneles.
- No se definio un periodo obligatorio de muestreo; se debe justificar en funcion de cada sensor.
- Las alarmas deben ser configurables desde la app mediante umbrales.
- Cuando un valor queda fuera del umbral, se inicia un ciclo de alarma de 30 segundos.
- La alarma puede implementarse con un pin de salida para buzzer o reproducirse en la computadora.
- La alarma se debe poder postergar o apagar desde la interfaz.

## 6. Stack tecnico

El sistema se implementara con las siguientes tecnologias:

| Capa | Tecnologia | Responsabilidad |
| --- | --- | --- |
| Aplicacion de escritorio | Flutter | Interfaz grafica, dashboard, historial, configuracion y acciones del usuario |
| Backend local | Go + Echo | API REST, WebSocket/SSE, integracion con microcontrolador, reglas de negocio |
| Base de datos | SQLite | Persistencia local de pacientes, sesiones, mediciones, umbrales y alarmas |
| Firmware | Arduino/ESP32 segun placa final | Adquisicion de sensores, SD, OLED y alarma fisica opcional |
| Almacenamiento embebido | microSD | Datalogger local con `millis` como referencia temporal |

La separacion entre Flutter y Go permite que la interfaz se mantenga enfocada en visualizacion e interaccion, mientras el backend concentra comunicacion, persistencia y procesamiento de datos.

## 7. Arquitectura general

La arquitectura propuesta se divide en cinco capas:

1. **Capa de adquisicion embebida**  
   Lee sensores analogicos y digitales, procesa valores basicos y genera paquetes de datos.

2. **Capa de almacenamiento local**  
   Registra las muestras en una tarjeta microSD con una marca `millis`, identificador de sesion y valores medidos.

3. **Capa de comunicacion**  
   Envia datos al backend local y recibe comandos de configuracion, descarga, silenciado y cambios de umbrales. La comunicacion con el microcontrolador puede realizarse por USB serial, Bluetooth, Wi-Fi o WebSocket segun el hardware final.

4. **Capa de backend local**  
   Implementada en Go con Echo. Expone endpoints REST para operaciones de consulta/configuracion, canal en tiempo real para muestras, integracion con SQLite y puente con el firmware.

5. **Capa de aplicacion de escritorio**  
   Implementada en Flutter. Presenta dashboard en tiempo real, configuracion de umbrales, historial de mediciones, estado de alarmas y acciones de descarga.

Flujo general:

```text
Sensores -> Microcontrolador -> microSD
                         |
                         v
               Backend Go + Echo
                         |
                         v
                    SQLite local
                         |
                         v
        Aplicacion DataVital en Flutter
```

En tiempo real, el backend recibe muestras del microcontrolador y las reenvia a Flutter mediante WebSocket o Server-Sent Events. Para acciones puntuales, Flutter utiliza endpoints REST expuestos por Echo.

## 8. Modulo embebido

El modulo embebido es responsable de:

- Inicializar sensores y perifericos.
- Leer entradas analogicas y digitales.
- Calcular o recibir valores derivados como BPM y SpO2.
- Escribir muestras en SD.
- Enviar muestras en tiempo real hacia el backend local.
- Recibir umbrales configurados desde el backend.
- Activar una salida de alarma si se utiliza buzzer externo.
- Actualizar el OLED con tres valores principales y estado de alarma.

### Programas individuales sugeridos

Para facilitar la validacion incremental, se propone preparar sketches separados:

| Sketch | Objetivo |
| --- | --- |
| `test_ad8232.ino` | Leer ECG crudo y estados `LOD+` / `LOD-` |
| `test_max30100.ino` | Leer frecuencia cardiaca, SpO2 y PPG si la libreria lo permite |
| `test_mq135.ino` | Leer salida analogica, salida digital y estimacion de calidad de aire |
| `test_lm386.ino` | Leer amplitud acustica o envolvente de audio |
| `test_sd.ino` | Escribir y leer registros CSV en microSD |
| `test_oled.ino` | Mostrar valores numericos y alerta visual |

Luego, estos programas se integran en un firmware principal que se comunicara con el backend local.

## 9. Sensores

### AD8232 - Electrocardiografia

El AD8232 permite adquirir una senal analogica relacionada con la actividad electrica del corazon. Tambien dispone de salidas digitales para detectar electrodos desconectados.

Datos esperados:

- `ecg_raw`: lectura analogica del ADC.
- `lod_plus`: estado digital del electrodo.
- `lod_minus`: estado digital del electrodo.

Uso en la app:

- Grafico de linea de alta frecuencia para ECG.
- Indicador de conexion de electrodos.
- Posible calculo o visualizacion de frecuencia cardiaca si se implementa deteccion de picos.

#### Procesamiento y filtrado de la señal de ECG

La visualización del ECG en la aplicación incluye un pipeline de procesamiento digital en tiempo real para limpiar el ruido del sensor sin deformar la morfología de la señal:

1. **Estimación y remoción de línea base mediante filtro pasa-altos IIR de 1er orden**: Se estima la deriva lenta (baseline wander) mediante un filtro pasa-altos con una constante alfa (hpAlpha = 0.044, equivalente a ~0.5 Hz a una frecuencia de muestreo de ~70 Hz). Restar este componente a cada muestra elimina el baseline wander de manera estable y causal, evitando los saltos o vibraciones verticales en el trazado que ocurren con filtros no causales.
2. **Rechazo de outliers (limitador de picos extremos)**: Tras centrar la señal, se limita el valor a un rango de +/- 900 unidades. Esto previene que ruidos transitorios de alta tensión (provocados por el movimiento de cables o desprendimiento parcial de electrodos) disparen el trazado fuera de los límites visuales del gráfico, permitiendo además una recuperación inmediata de los filtros pasa-bajos.
3. **Suavizado mediante promedio móvil de 3 muestras (MA3)**: La frecuencia de muestreo efectiva del hardware es de aproximadamente 70 Hz. A esta frecuencia, el ruido eléctrico de 50/60 Hz sufre aliasing y se alinea en torno a los 30 Hz. Un promedio móvil corto de 3 muestras reduce significativamente este hum de alta frecuencia sin amortiguar la onda R (el pico QRS), que posee una duración muy corta (1 a 2 muestras).
4. **Filtro pasa-bajos recursivo EMA**: Se aplica un filtro de media móvil exponencial (IIR EMA) con un coeficiente alfa de 0.55 sobre el resultado del promedio móvil. Esta etapa alisa el trazado de la curva y mantiene la morfología de los latidos conservando cerca del 85% de la amplitud del pico QRS.
5. **Escala y visualización con zoom fijo**: El gráfico se representa sobre una escala simétrica fija de +/- 170 unidades. Esto amplía la curva de ECG para que el complejo QRS real (de unos 100-120 unidades de amplitud) ocupe cerca del 70%-80% de la altura vertical de la rejilla, garantizando una excelente visibilidad y permitiendo que picos de ruido extremos se recorten limpiamente sin desconfigurar la escala.

### MAX30100 / HW-827 - Frecuencia cardiaca y SpO2

El MAX30100 permite medir frecuencia cardiaca y saturacion de oxigeno usando fotopletismografia. El HW-827 puede utilizarse como sensor de pulso para frecuencia cardiaca.

Datos esperados:

- `bpm`: frecuencia cardiaca en latidos por minuto.
- `spo2`: saturacion de oxigeno en porcentaje.
- `ir_raw` y `red_raw`: muestras crudas si la libreria las expone.

Uso en la app:

- KPI numerico para BPM.
- KPI numerico para SpO2.
- Curva pletismografica cuando haya datos crudos disponibles.

### MQ-135 - Calidad de aire / CO2 estimado

El MQ-135 es un sensor de gases de amplio espectro. En este proyecto se usa como referencia didactica para calidad de aire o estimacion de CO2, no como instrumento calibrado de capnografia clinica.

Datos esperados:

- `mq135_raw`: lectura analogica del ADC.
- `mq135_digital`: estado del comparador del modulo.
- `co2_ppm`: valor estimado si se realiza calibracion.

Uso en la app:

- KPI numerico en ppm o valor relativo.
- Alarma por umbral maximo configurable.
- Tendencia historica de calidad de aire.

### LM386 - Acondicionamiento acustico

El LM386 se utiliza como etapa amplificadora para una senal acustica capturada por microfono o transductor. Puede emplearse para representar sonidos cardiacos o respiratorios con fines didacticos.

Datos esperados:

- `audio_raw`: lectura analogica instantanea.
- `audio_amp`: amplitud o envolvente calculada.

Uso en la app:

- Curva tipo waveform o fonocardiograma.
- KPI de amplitud acustica.

## 10. Backend local en Go con Echo

El backend local funciona como intermediario entre el firmware, la base de datos y la aplicacion Flutter.

Responsabilidades:

- Recibir muestras en tiempo real desde el microcontrolador.
- Validar y normalizar datos recibidos.
- Persistir sesiones, pacientes, mediciones y eventos en SQLite.
- Exponer API REST para historial, configuracion, descarga y control de alarmas.
- Exponer un canal en tiempo real para que Flutter actualice graficos y KPIs.
- Enviar al microcontrolador umbrales, nombre de paciente, pedidos de descarga y acciones de silenciado.
- Importar registros provenientes de la microSD cuando el usuario solicite la descarga.

Endpoints REST propuestos:

| Metodo | Ruta | Funcion |
| --- | --- | --- |
| `GET` | `/health` | Verificar estado del backend |
| `GET` | `/sessions` | Listar sesiones registradas |
| `POST` | `/sessions` | Crear nueva sesion de monitoreo |
| `GET` | `/sessions/:id/measurements` | Consultar mediciones de una sesion |
| `POST` | `/patients` | Registrar o actualizar paciente |
| `GET` | `/thresholds` | Obtener umbrales actuales |
| `PUT` | `/thresholds` | Actualizar umbrales de alarma |
| `POST` | `/alarms/silence` | Silenciar o postergar alarma |
| `POST` | `/device/download` | Solicitar descarga de datos desde microSD |
| `GET` | `/events` | Consultar eventos de alarma |

Canal en tiempo real propuesto:

| Canal | Funcion |
| --- | --- |
| `GET /ws/live` | Enviar a Flutter muestras, estado del dispositivo y alarmas |

## 11. Base de datos SQLite

SQLite se utilizara como persistencia local de la aplicacion. A diferencia de la microSD, que funciona como datalogger embebido, SQLite permite consultas historicas, filtros por paciente/sesion y reconstruccion de eventos desde la app.

Tablas sugeridas:

| Tabla | Contenido |
| --- | --- |
| `patients` | Datos basicos del paciente o sujeto de prueba |
| `sessions` | Inicio, fin, paciente asociado y observaciones |
| `measurements` | Mediciones normalizadas por sensor y metrica |
| `thresholds` | Umbrales activos o historicos |
| `alarm_events` | Eventos de alarma, valor critico y accion tomada |
| `device_status` | Estado de conexion, SD, sensores y firmware |

Modelo minimo de `measurements`:

```sql
CREATE TABLE measurements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  sensor TEXT NOT NULL,
  metric TEXT NOT NULL,
  value REAL NOT NULL,
  unit TEXT,
  millis INTEGER NOT NULL,
  received_at TEXT NOT NULL,
  extra_json TEXT
);
```

En SQLite si puede existir `received_at`, porque lo genera la PC/backend al recibir datos. Esto no contradice la consigna: la SD sigue usando `millis` y no requiere fecha/hora real.

## 12. Aplicacion de escritorio

La aplicacion se encuentra en `DataVital/app` y esta desarrollada con Flutter. El proyecto usa una organizacion por funcionalidades:

```text
lib/
├── core/
│   ├── router/
│   ├── theme/
│   └── constants/
├── features/
│   ├── dashboard/
│   ├── alerts/
│   ├── history/
│   └── settings/
└── shared/
    ├── providers/
    └── widgets/
```

### Pantallas principales

| Pantalla | Funcion |
| --- | --- |
| Dashboard | Visualizacion en tiempo real de curvas y KPIs |
| Alertas | Estado del sistema de alarmas |
| Historial | Consulta de registros almacenados |
| Configuracion | Ajuste de umbrales y parametros del sistema |

### Integracion con el backend

Flutter se comunicara con Go/Echo de dos maneras:

- **REST** para operaciones puntuales: crear sesiones, configurar umbrales, descargar registros, consultar historial y silenciar alarmas.
- **WebSocket o SSE** para recibir muestras y alarmas en tiempo real sin consultar permanentemente al servidor.

La aplicacion no deberia escribir directamente en SQLite. Esa responsabilidad queda en el backend para mantener validaciones y reglas de negocio en un unico lugar.

### Estado actual del frontend

El frontend ya contiene:

- Dashboard con curvas simuladas de ECG, SpO2/PPG y PCG.
- KPIs para frecuencia cardiaca, SpO2, CO2 y amplitud acustica.
- Gestion de estado con Riverpod.
- Simulacion periodica cada 100 ms.
- Umbrales configurables para frecuencia cardiaca, SpO2 y CO2.
- Persistencia local de umbrales con `shared_preferences`.
- Ciclo de alarma de 30 segundos.
- Navegacion con `go_router`.
- Tema claro/oscuro y estructura responsive.

## 13. Modelo de dominio

El modelo conceptual se encuentra en:

```text
DataVital/Docs/diagram.plantuml
```

Entidades principales:

- **User**: representa a la persona o paciente asociado a una medicion.
- **Session**: agrupa un conjunto de mediciones realizadas en una toma.
- **Medicion**: entidad base para cada muestra o conjunto de muestras.
- **SensorType**: identifica el sensor de origen.
- **MedicionECG**, **MedicionPPG**, **MedicionFrecuenciaCardiaca**, **MedicionSpO2**, **MedicionCalidadAire** y **MedicionFonocardiograma**: especializaciones por tipo de dato.

Para alinear el modelo con la consigna docente, cada medicion debe tener una referencia temporal relativa `millis`, mientras que la fecha real puede quedar asociada a la sesion si la app la conoce.

## 14. Formato de registro en SD

Se propone usar CSV por simplicidad y facilidad de descarga:

```csv
session_id,patient_name,millis,sensor,metric,value,unit,extra
S001,Paciente Demo,1200,MAX30100,bpm,72,lpm,
S001,Paciente Demo,1200,MAX30100,spo2,98,%,
S001,Paciente Demo,1210,AD8232,ecg_raw,512,adc,"lod_plus=0;lod_minus=0"
S001,Paciente Demo,2000,MQ135,co2,420,ppm,
S001,Paciente Demo,2010,LM386,audio_amp,13,%, 
```

Campos:

| Campo | Descripcion |
| --- | --- |
| `session_id` | Identificador de toma o sesion |
| `patient_name` | Nombre opcional ingresado desde la app |
| `millis` | Tiempo relativo desde el inicio del firmware o sesion |
| `sensor` | Sensor de origen |
| `metric` | Variable medida |
| `value` | Valor numerico |
| `unit` | Unidad o referencia |
| `extra` | Metadatos opcionales |

El campo `millis` permite reconstruir la distancia temporal entre muestras sin depender de reloj de tiempo real.

## 15. Comunicacion entre microcontrolador, backend y app

Para el intercambio entre microcontrolador y backend se propone un formato textual simple, por ejemplo JSON por linea:

```json
{"type":"sample","session_id":"S001","millis":1200,"sensor":"MAX30100","bpm":72,"spo2":98}
{"type":"sample","session_id":"S001","millis":1210,"sensor":"AD8232","ecg_raw":512,"lod_plus":false,"lod_minus":false}
{"type":"status","sd_ready":true,"oled_ready":true,"alarm_active":false}
```

Comandos minimos esperados entre backend y firmware:

| Comando | Origen | Funcion |
| --- | --- | --- |
| `alarm_config` | Backend | Enviar umbrales al microcontrolador |
| `download_request` | Backend | Solicitar datos guardados en SD |
| `patient_set` | Backend | Asociar nombre de paciente a la sesion |
| `alarm_ack` | Backend | Silenciar o postergar alarma |
| `sample` | Microcontrolador | Enviar muestra en tiempo real |
| `download_chunk` | Microcontrolador | Enviar registros almacenados |
| `status` | Microcontrolador | Informar conexion, SD, sensores y alarma |

Flujo de datos completo:

```text
Microcontrolador -> Go/Echo -> SQLite
Microcontrolador -> Go/Echo -> Flutter
Flutter -> Go/Echo -> Microcontrolador
```

## 16. Sistema de alarmas

Las alarmas se basan en umbrales configurables desde la app.

Umbrales iniciales sugeridos:

| Variable | Condicion de alarma |
| --- | --- |
| Frecuencia cardiaca | Menor a `fc_min` o mayor a `fc_max` |
| SpO2 | Menor a `spo2_min` |
| CO2 / calidad de aire | Mayor a `co2_max` |

Flujo:

1. El backend y/o el firmware evalua la muestra recibida.
2. Si una variable supera su umbral, se activa la alarma.
3. Comienza una ventana de 30 segundos.
4. Durante la alarma, el OLED muestra una advertencia visual.
5. La app muestra la metrica critica, el valor detectado y el contador.
6. El usuario puede silenciar o postergar la alarma.
7. Opcionalmente, el firmware activa un pin para buzzer.

La implementacion actual del frontend ya incluye umbrales configurables y un contador de alarma de 30 segundos en `notificadorAlarmaProvider`. En la version integrada, esa logica puede mantenerse en Flutter para visualizacion y replicarse o centralizarse en Go para persistencia y coordinacion con el firmware.

## 17. Visualizacion en OLED

El OLED no debe reemplazar al dashboard de escritorio. Su funcion es dar una lectura local minima.

Valores sugeridos:

- Frecuencia cardiaca en LPM.
- SpO2 en porcentaje.
- CO2 estimado o calidad de aire.

Ejemplo:

```text
FC:   72 LPM
SpO2: 98 %
CO2:  420 ppm
```

En caso de alarma:

```text
!!! PELIGRO !!!
FC:   132 LPM
SpO2: 98 %
CO2:  420 ppm
```

El texto de alarma puede parpadear alternando visible/no visible cada 500 ms.

## 18. Consideraciones de tiempo real

El proyecto se considera un sistema de **tiempo real blando**. Esto significa que una demora ocasional no genera un riesgo clinico, pero si afecta la calidad de visualizacion y la respuesta didactica del sistema.

Aspectos a analizar:

- Periodo de muestreo de cada sensor.
- Latencia desde la adquisicion hasta la visualizacion.
- Jitter entre muestras.
- Tiempo de respuesta ante eventos de alarma.
- Duracion real del ciclo de silenciado de 30 segundos.
- Perdida de muestras durante escritura en SD o descarga.

Frecuencias orientativas:

| Senal | Frecuencia sugerida |
| --- | --- |
| ECG | 100 Hz o superior si el microcontrolador lo permite |
| PPG | 25 Hz a 50 Hz |
| BPM / SpO2 procesados | 1 Hz |
| MQ-135 | 0.1 Hz a 1 Hz |
| LM386 / envolvente acustica | 100 Hz o mas, segun estrategia |
| OLED | 1 Hz a 2 Hz |

## 19. Seguridad y limitaciones

- El sistema es exclusivamente didactico.
- No debe usarse para diagnostico, monitoreo clinico ni toma de decisiones medicas.
- Los sensores utilizados no constituyen equipamiento medico certificado.
- Para pruebas con ECG en una persona, el sistema debe alimentarse de forma segura y aislada.
- Se recomienda usar laptop con bateria o aislamiento galvanico cuando haya conexion fisica al cuerpo.
- Las mediciones de MQ-135 requieren calibracion para aproximar ppm; sin calibracion deben interpretarse como valores relativos.
- El LM386 requiere acondicionamiento adecuado para evitar saturacion o recorte de la senal.

## 20. Plan de pruebas

| Prueba | Criterio de aceptacion |
| --- | --- |
| Lectura AD8232 | Se observa senal analogica variable y estados `LOD` |
| Lectura MAX30100 | Se obtienen BPM y SpO2 estables en reposo |
| Lectura MQ-135 | Cambia el valor analogico ante variaciones ambientales |
| Lectura LM386 | Se detecta amplitud acustica ante sonido o contacto |
| Escritura SD | Se genera archivo CSV con `millis` y valores |
| Descarga desde app | La app solicita y recibe registros guardados |
| API Go/Echo | Responde endpoints REST y canal en tiempo real |
| Persistencia SQLite | Registra sesiones, mediciones y alarmas |
| Configuracion de umbrales | Los cambios persisten y se aplican a nuevas muestras |
| Alarma por umbral | Se activa durante 30 segundos ante valor fuera de rango |
| Silenciado de alarma | La app cancela o posterga la alarma |
| OLED | Muestra tres valores y advertencia visual |

## 21. Estado de avance

Completado o avanzado:

- Frontend Flutter multiplataforma.
- Dashboard con senales simuladas.
- KPIs principales.
- Navegacion por secciones.
- Configuracion de umbrales.
- Ciclo de alarma de 30 segundos.
- Modelo de dominio preliminar en PlantUML.
- Documentacion tecnica de sensores.

Pendiente o a integrar:

- Backend Go con Echo.
- Esquema e implementacion SQLite.
- Firmware principal del microcontrolador.
- Programas separados de prueba por sensor.
- Conexion real entre microcontrolador, backend y app.
- Escritura y descarga desde microSD.
- Asociacion opcional de paciente.
- Visualizacion OLED.
- Salida fisica de alarma o reproduccion sonora en PC.
- Historial con datos reales descargados.

## 22. Futuras mejoras

- Implementar RTOS para planificacion de tareas de adquisicion, comunicacion y almacenamiento.
- Agregar autenticacion local o perfiles de usuario si el alcance academico lo requiere.
- Incorporar perfiles de paciente y sesiones.
- Exportar registros en CSV o JSON desde la app.
- Agregar app movil.
- Enviar alertas remotas.
- Incorporar filtros digitales para ECG, PPG y audio.
- Implementar deteccion automatica de picos R para calcular frecuencia cardiaca desde ECG.

## 23. Conclusion

DataVital propone una plataforma didactica completa para integrar sensores, adquisicion de datos, visualizacion en tiempo real, almacenamiento y alarmas configurables. El enfoque modular permite validar cada sensor por separado y luego integrarlo en un flujo comun, manteniendo una separacion clara entre adquisicion embebida, registro local en microSD, backend Go/Echo, persistencia SQLite y visualizacion en la app de escritorio.

La solucion cumple con el objetivo academico de estudiar sistemas en tiempo real aplicados a senales fisiologicas, sin pretender reemplazar equipamiento medico certificado.
