# Sistemas de Tiempo Real

## DataVital

Monitor multiparamétrico de signos vitales con fines didácticos

| Campo | Contenido |
| --- | --- |
| Integrantes | |
| Motivo por el que queda vacío | No se pudo completar porque el repositorio y la documentación disponible no incluyen la nómina de integrantes del grupo. |
| Repositorio | <https://github.com/UNTDF-Sistemas-de-Tiempo-Real/DataVital> |
| Docente | Leonel Ezequiel Viera |
| Año de cursada | 2026 |

## Índice sugerido

1. Resumen del proyecto
   1. Descripción inicial
   2. Comparación con el anteproyecto
   3. Cambios significativos respecto de la propuesta original
   4. Síntesis de cumplimiento
2. Hardware y conexiones
   1. Fotos del hardware conectado
   2. Tabla de componentes utilizados
   3. Tabla de conexiones
   4. Diagrama esquemático
3. Funcionamiento general del sistema
   1. Descripción funcional y flujo de trabajo
   2. Arquitectura
   3. Estados principales del sistema
   4. Formato de mensajes seriales enviados por ESP32
   5. Formato normalizado WebSocket enviado a Flutter
   6. Formato REST para guardar mediciones
4. Estructura del código
   1. Estructura general del repositorio
   2. Frontend Flutter
   3. Backend Go
   4. Firmware ESP32
   5. Comandos de desarrollo y build
5. Instalación y puesta en marcha
   1. Requisitos generales
   2. Configuración del ESP32
   3. Configuración del backend
   4. Configuración del frontend
   5. Puesta en marcha completa
6. Manual de usuario
   1. Capturas de pantalla
   2. Selección o creación de usuario
   3. Dashboard de bioseñales
   4. Grabación de una sesión
   5. Historial de sesiones
   6. Reportes
   7. Alertas
   8. Configuración
   9. Recomendaciones de uso seguro
7. Datos que quedaron pendientes por falta de información

### 1. Resumen del proyecto

#### 1.1. Descripción inicial

DataVital es un sistema didáctico de monitoreo de signos vitales y variables ambientales, orientado a la enseñanza de adquisición de señales, visualización en tiempo real, registro de datos y respuesta ante eventos de alarma. El proyecto combina un módulo embebido con sensores, una aplicación de escritorio y una capa intermedia local para organizar la comunicación y la persistencia de datos.

La idea general mantiene el espíritu del anteproyecto: construir una herramienta accesible para actividades académicas, demostraciones y prácticas de sistemas de tiempo real blando. El sistema permite observar señales y valores numéricos en una interfaz gráfica, registrar sesiones de medición, revisar historiales, generar reportes y configurar alarmas por umbrales.

El uso previsto sigue siendo exclusivamente educativo. No se trata de un dispositivo médico certificado y no debe utilizarse para diagnóstico, monitoreo clínico ni toma de decisiones terapéuticas.

#### 1.2. Comparación con el anteproyecto

El anteproyecto proponía un monitor multiparamétrico amplio, capaz de trabajar con señales simuladas y sensores reales, visualizar curvas en PC, almacenar datos, configurar umbrales y generar alarmas con silenciado temporal. En términos generales, la implementación final conserva esa arquitectura conceptual, pero reduce el alcance fisiológico y concreta algunas funciones de una manera distinta a la propuesta inicial.

Comparación general:

| Aspecto planteado en el anteproyecto | Resultado en la implementación final | Evaluación |
| --- | --- | --- |
| Monitor didáctico de signos vitales en tiempo real | Se desarrolló un sistema funcional con adquisición, visualización en vivo, registro de sesiones, historiales y alarmas. | Cumplido en términos generales |
| Interfaz gráfica en PC con curvas y parámetros numéricos | Se implementó una aplicación de escritorio con dashboard, gráficos, KPIs, historial, reportes y configuración. | Cumplido |
| Trabajo con sensores reales y señales simuladas | El sistema puede operar con sensores reales y también cuenta con datos simulados para pruebas sin hardware. | Cumplido |
| Registro de datos y valores mínimos/máximos | Las sesiones se guardan y luego se calculan mínimos, máximos y promedios para el historial y reportes. | Cumplido parcialmente |
| Alarmas configurables por umbrales | Se implementaron umbrales configurables para frecuencia cardíaca y CO2/calidad de aire. | Cumplido parcialmente |
| Silenciador de alarmas por 30 segundos | Existe control de alarma visual/sonora y posibilidad de silenciar sonido, pero no se conserva exactamente la temporización de 30 segundos propuesta. | Parcial |
| Análisis de aspectos de tiempo real | El sistema usa adquisición periódica y actualización continua, pero no se registraron mediciones formales de latencia, jitter o tiempo de respuesta. | Parcial |

Comparación de variables medidas:

| Variable prevista en el anteproyecto | Situación en la implementación final | Evaluación |
| --- | --- | --- |
| ECG de 3 derivaciones | Se incorporó lectura de ECG y detección de electrodos desconectados, pero no una implementación completa de 3 derivaciones. | Parcial |
| SpO2 | Quedó prevista a nivel de estructura general, pero no integrada en el flujo funcional principal. | Pendiente |
| Temperatura corporal | No quedó incorporada en la versión desarrollada. | Pendiente |
| Capnografía | Se reemplazó por una medición didáctica de CO2/calidad de aire, no equivalente a capnografía clínica. | Parcial |
| Frecuencia respiratoria | No se calcula como parámetro numérico independiente. | Pendiente |
| Frecuencia cardíaca | Se incorporó como parámetro numérico principal. | Cumplido |
| Visualización local en pantalla | Se agregó una pantalla local para valores principales y alertas. | Cumplido |

#### 1.3. Cambios significativos respecto de la propuesta original

Si bien el objetivo didáctico general se mantiene, sí hubo cambios significativos respecto del anteproyecto:

1. Reducción del alcance multiparamétrico.
   El anteproyecto planteaba ECG, SpO2, temperatura corporal, capnografía y frecuencia respiratoria. La implementación final se enfoca principalmente en ECG, frecuencia cardíaca y CO2/calidad de aire.

2. Cambio en la interpretación de capnografía.
   En lugar de una capnografía propiamente dicha, se utiliza una medición aproximada de CO2/calidad de aire con fines didácticos. Esto permite mostrar una tendencia respiratoria o ambiental, pero no reemplaza una medición clínica de CO2 espirado.

3. Persistencia orientada a la aplicación de escritorio.
   El anteproyecto mencionaba datalogger como registro de datos. En la versión desarrollada, el registro principal se concentra en la aplicación y la base de datos local, con sesiones, historiales, resúmenes y exportación. El almacenamiento embebido en tarjeta microSD no quedó incorporado en la versión revisada.

4. Mayor separación entre adquisición, lógica local e interfaz.
   La propuesta original hablaba de un módulo embebido y una HMI en PC. La implementación final agrega una capa local intermedia que ordena la comunicación, normaliza los datos, permite persistencia y facilita que la interfaz se mantenga enfocada en visualización e interacción.

5. Alarmas implementadas, pero no idénticas a la consigna inicial.
   Hay alarmas configurables, aviso visual, sonido y acciones de usuario. Sin embargo, el comportamiento no coincide completamente con el silenciado temporal de 30 segundos especificado inicialmente.

#### 1.4. Síntesis de cumplimiento

El proyecto final puede considerarse una implementación funcional y didáctica del concepto planteado en el anteproyecto, pero no una reproducción completa de todo su alcance original. La base del sistema está lograda: adquisición periódica, visualización en tiempo real, registro de sesiones, historiales, reportes y alarmas.

La diferencia principal es que el anteproyecto definía un monitor multiparamétrico más completo, mientras que la implementación final priorizó un subconjunto de señales y funcionalidades alcanzables con los sensores y el desarrollo disponible. Por ese motivo, el cambio más importante no está en el objetivo general, que se mantiene, sino en el alcance concreto de variables medidas y en la forma de resolver el registro de datos y las alarmas.

### 2. Hardware y conexiones

#### Fotos del hardware conectado

Espacio para insertar fotos del montaje físico.

No se pudo completar con imágenes porque el repositorio no contiene fotografías del hardware conectado y este entorno no tiene acceso físico al dispositivo.

#### Tabla de componentes utilizados

| Componente | Modelo | Cantidad | Función |
| --- | --- | ---: | --- |
| Unidad de procesamiento | ESP32, modelo exacto no especificado | 1 | Adquisición de sensores, lectura analógica/digital, comunicación serial y control de pantalla OLED. |
| Sensor ECG | AD8232 | 1 | Lectura analógica de señal electrocardiográfica y detección de electrodos desconectados. |
| Sensor de pulso | HW-827 / Pulse Sensor compatible | 1 | Obtención de frecuencia cardíaca aproximada en BPM. |
| Sensor de calidad de aire | MQ-135 | 1 | Lectura analógica de gases/calidad de aire y estimación aproximada de CO2 en ppm. |
| Pantalla local | OLED SSD1306 128x64 I2C, dirección 0x3C | 1 | Visualización local de BPM, CO2 y alertas. |
| Módulo de almacenamiento |  |  |  |
| Motivo por el que queda vacío |  |  | No se pudo completar porque, aunque la documentación menciona microSD, el firmware actual no contiene inicialización SD, escritura de archivos ni pines de conexión para un módulo microSD. |
| Acondicionamiento acústico | LM386 |  |  |
| Motivo por el que queda parcialmente vacío |  |  | La documentación lo menciona como componente previsto, pero no hay integración en el firmware actual ni pines definidos. |

#### Tabla de conexiones

Conexiones extraídas del firmware sensors/sensores.ino:

| Pin ESP32 | Componente | Pin del componente | Tipo de señal | Nombre en el código | Observaciones |
| --- | --- | --- | --- | --- | --- |
| GPIO36 | AD8232 | OUTPUT | Analógica de entrada | ECG_PIN | Lectura ECG cruda. GPIO36 es pin de entrada analógica del ESP32. |
| GPIO33 | AD8232 | LO- | Digital de entrada | LO_MINUS_PIN | Detecta electrodo desconectado. |
| GPIO32 | AD8232 | LO+ | Digital de entrada | LO_PLUS_PIN | Detecta electrodo desconectado. |
| GPIO34 | HW-827 | Señal | Analógica de entrada | HRM_PIN | Usado por PulseSensorPlayground. GPIO34 es pin de entrada analógica. |
| GPIO14 | MQ-135 | AO | Analógica de entrada | MQ135_PIN | Lectura analógica mapeada aproximadamente de 350 a 5000 ppm. |
| I2C por defecto de Wire | OLED SSD1306 | SDA / SCL | I2C | display, OLED_ADDRESS | El código no define pines SDA/SCL; en muchas placas ESP32 se usan GPIO21 y GPIO22 por defecto, pero no se puede confirmar desde el repositorio. |
| 3V3 / 5V | Sensores y OLED | VCC | Alimentación | - | No se puede completar con certeza porque el repositorio no documenta el voltaje real usado por cada módulo. Verificar según módulo físico y placa ESP32. |
| GND | Todos los módulos | GND | Referencia común | - | Todos los sensores deben compartir masa con el ESP32. |

#### Diagrama esquemático

No se pudo completar con un diagrama eléctrico porque el repositorio no incluye un esquemático de conexiones físicas. Existe un diagrama PlantUML de modelo de dominio en docs/diagram.plantuml, pero no representa el cableado del hardware.

### 3. Funcionamiento general del sistema

#### Descripción funcional y flujo de trabajo

El funcionamiento general de DataVital se apoya en tres partes conectadas entre sí: el firmware del ESP32, el backend local y la aplicación de escritorio. El firmware está desarrollado sobre Arduino/ESP32 y se encarga de leer los sensores, detectar estados particulares como electrodos desconectados, actualizar la pantalla OLED y enviar las muestras por USB serial a 115200 baudios. Las lecturas principales que salen del dispositivo son ECG crudo desde el AD8232, frecuencia cardíaca aproximada desde el HW-827 y una estimación de CO2/calidad de aire desde el MQ-135.

El backend está desarrollado en Go con Echo y funciona como capa intermedia entre el hardware y la interfaz. Su tarea principal es abrir el puerto serial definido por SERIAL_PORT, recibir el flujo de datos del ESP32, extraer objetos JSON válidos, normalizar los paquetes y agregarles una marca temporal al momento de recepción. Si el puerto serial no está disponible, el backend puede usar un simulador interno para que la aplicación se pueda probar sin hardware conectado.

Una vez normalizadas, las muestras se publican hacia Flutter mediante WebSocket en /ws/sensors. La aplicación de escritorio, desarrollada en Flutter con Riverpod, GoRouter y fl_chart, mantiene esa conexión activa, actualiza los gráficos en tiempo real y permite iniciar grabaciones de sesión. Durante una grabación, la app bufferiza las muestras recibidas, crea y finaliza sesiones mediante la API REST del backend y guarda los bloques de mediciones en SQLite. A partir de esos datos se construyen historiales, resúmenes, exportaciones CSV y reportes PDF.

#### Arquitectura

La arquitectura queda organizada como un flujo local de adquisición, normalización, visualización y persistencia. El ESP32 no se comunica directamente con la interfaz, sino que envía los datos al backend, y el backend expone los canales necesarios para que Flutter consuma muestras en vivo y guarde información histórica.

```
Sensores -> ESP32 -> Serial USB -> Backend Go/Echo -> WebSocket -> App Flutter
                                      |
                                      +-> REST -> SQLite
```

Esta separación permite que cada capa tenga una responsabilidad clara: el ESP32 se concentra en adquirir señales, el backend en ordenar la comunicación y persistencia, y Flutter en la experiencia de usuario, visualización, alarmas, reportes e interacción con sesiones.

#### Estados principales del sistema

| Estado | Descripción | Condición de entrada | Condición de salida |
| --- | --- | --- | --- |
| Inicio | Arranque del ESP32, backend o aplicación. | Encendido, reset, ejecución del backend o apertura de la app. | Inicialización correcta de periféricos, base de datos y conexión. |
| Inicialización de sensores | Configuración de OLED, pines, ADC y PulseSensor. | Ejecución de setup() en el firmware. | Sensores listos o mensaje de error por serial. |
| Normal | Lectura y visualización de datos válidos. | Paquetes seriales válidos y WebSocket conectado. | Alarma, desconexión de sensor, error serial o cierre de app. |
| Electrodos desconectados | El AD8232 informa LO- o LO+ activo. | LO_MINUS_PIN o LO_PLUS_PIN en HIGH. | Electrodos conectados nuevamente. |
| Alarma | Valor fuera de umbral en BPM o CO2. | BPM menor/mayor que umbrales o CO2 mayor al umbral. | Normalización del valor, descarte manual, silenciado sonoro o fin del ciclo. |
| Grabación de sesión | La app está acumulando muestras en memoria para luego persistirlas. | Usuario presiona "Grabar sesión" en el dashboard. | Usuario detiene la grabación y guarda o descarta la sesión. |
| Error de comunicación | Backend sin puerto serial, WebSocket caído o app desconectada. | Falla de puerto, backend detenido, cable desconectado o error de red local. | Reconexión, reinicio del backend o uso del simulador. |

#### Formato de mensajes seriales enviados por ESP32

La comunicación ESP32-backend se realiza por USB serial a 115200 baudios usando JSON textual. El puerto se define mediante la variable SERIAL_PORT; los valores habituales son /dev/ttyUSB0 en Linux y COM3 en Windows. El firmware no envía un único paquete con todos los sensores, sino objetos JSON independientes para cada lectura. En cada ciclo pueden salir hasta tres mensajes: uno para AD8232, uno para HW-827 y uno para MQ-135.

El backend lee el flujo byte a byte y extrae objetos JSON completos usando conteo de llaves. Por eso puede tolerar ruido entre mensajes y no depende estrictamente del salto de línea. Luego valida el campo sensor; si falta el valor principal de ese sensor, descarta el paquete.

| Campo | Tipo | Descripción | Ejemplo |
| --- | --- | --- | --- |
| sensor | texto | Identificador del sensor que origina el mensaje. Define qué campos de valor deben interpretarse. | AD8232, HW827, MQ135 |
| ecg | número o null | Lectura ADC cruda del AD8232. Cuando los electrodos están desconectados puede llegar como null. | 2098 |
| leads_off | booleano | Indica si el AD8232 detecta electrodos desconectados. | false |
| bpm | número | Frecuencia cardíaca estimada por el sensor de pulso HW-827. | 72 |
| co2_ppm | número | Estimación aproximada de CO2/calidad de aire calculada desde el MQ-135. No es una medición clínica calibrada. | 1200 |
| alerta | booleano | Indica si el firmware considera que BPM o CO2 están fuera del rango definido. | true |

En la implementación actual, el mensaje {"sensor":"AD8232","ecg":null,"leads_off":true} informa la desconexión de electrodos por serial, pero al no traer un valor numérico de ECG no se transforma en una muestra normalizada para WebSocket. La interfaz puede detectar la pérdida de señal por ausencia de muestras recientes.

Ejemplos reales de mensajes seriales:

```
{"sensor":"AD8232","ecg":2098,"leads_off":false}
{"sensor":"AD8232","ecg":null,"leads_off":true}
{"sensor":"HW827","bpm":72,"alerta":false}
{"sensor":"MQ135","co2_ppm":1200,"alerta":true}
```

#### Formato normalizado WebSocket enviado a Flutter

El backend convierte cada mensaje serial válido en un paquete normalizado de un solo valor y lo publica por WebSocket en:

```
ws://localhost:8080/ws/sensors
```

| Campo | Tipo | Descripción | Ejemplo |
| --- | --- | --- | --- |
| type | texto | Tipo normalizado de señal. Puede ser ecg, bpm o air. | ecg |
| value | decimal | Valor numérico de la muestra normalizada. | 2098 |
| timestamp | entero | Unix epoch en milisegundos generado por el backend al recibir la muestra. | 1782840000000 |
| alerta | booleano opcional | Estado de alarma informado por firmware. Aparece principalmente en paquetes bpm y air. | false |
| leads_off | booleano opcional | Estado de electrodos informado por AD8232. El backend lo contempla, aunque el flujo principal de Flutter no lo usa como dato persistido. | false |

Ejemplos de paquetes enviados a Flutter:

```
{"type":"ecg","value":2098,"timestamp":1782840000000,"leads_off":false}
{"type":"bpm","value":72,"timestamp":1782840000010,"alerta":false}
{"type":"air","value":1200,"timestamp":1782840000020,"alerta":true}
```

#### Formato REST para guardar mediciones

El WebSocket se usa para visualización en vivo. Para persistir una sesión, Flutter acumula muestras en memoria y luego las envía por REST en bloques separados por tipo de medición. El mismo esquema se usa para /ecg, /bpm, /air y /spo2, aunque SpO2 no está integrado al firmware actual.

| Campo | Tipo | Descripción | Ejemplo |
| --- | --- | --- | --- |
| session_id | entero | Identificador de la sesión creada previamente. | 1 |
| datos | arreglo | Lista de muestras del mismo tipo de sensor. | [...] |
| datos[].timestamp | entero | Unix epoch en milisegundos asociado a la muestra. | 1782840000000 |
| datos[].value | decimal | Valor de la muestra. | 72 |
| datos[].alerta | booleano opcional | Estado de alarma asociado a la muestra, cuando corresponde. | false |

Ejemplo de bloque persistido:

```
{
  "session_id": 1,
  "datos": [
    {"timestamp":1782840000000,"value":72,"alerta":false},
    {"timestamp":1782840001000,"value":73,"alerta":false}
  ]
}
```

La API REST también se usa para operaciones puntuales: crear y listar usuarios, crear y finalizar sesiones, consultar historiales, obtener resúmenes y exportar CSV. Los endpoints principales son /users, /sessions, /sessions/:id/summary, /sessions/:id/export.csv y las rutas de mediciones /ecg, /bpm, /air y /spo2.

### 4. Estructura del código

#### Estructura general del repositorio

```
DataVital/
├── app/        Aplicación Flutter de escritorio/web.
├── backend/    Servidor Go/Echo, SQLite, WebSocket y API REST.
├── sensors/    Firmware Arduino/ESP32.
├── docs/       Documentación técnica, guías e informes.
├── just/       Recetas de automatización para backend, frontend y builds.
└── justfile    Punto de entrada para comandos Just.
```

#### Frontend Flutter (app/)

La aplicación de escritorio está desarrollada en Flutter. Su responsabilidad principal es presentar la interfaz de usuario, consumir los datos en tiempo real, permitir la grabación de sesiones y ofrecer vistas de historial, reportes, alertas y configuración.

El punto de entrada está en app/lib/main.dart, donde se inicializan Flutter, Riverpod, el tema visual y el router. La navegación se define en app/lib/core/router/app_router.dart; allí se controla que el usuario seleccione un perfil antes de acceder al dashboard.

El código común se concentra en app/lib/core/ y app/lib/shared/. En core/models/ están los modelos de usuario, sesión, medición, resumen y paquete WebSocket. En core/services/ están los clientes de comunicación con el backend: WebSocket para datos en vivo y REST para usuarios, sesiones y mediciones. En shared/providers/ se organiza el estado global con Riverpod: conexión, signos vitales, alarmas, historial y usuario activo.

Las funcionalidades visibles para el usuario están separadas por carpeta dentro de app/lib/features/:

- dashboard/: visualización en tiempo real, KPIs, gráficos y grabación de sesiones.
- users/: selección, creación y eliminación de usuarios.
- sessions/: historial de sesiones y acciones sobre registros guardados.
- history/: reportes PDF y exportación CSV.
- alerts/: vista de alertas e historial local de alarmas.
- settings/: configuración de umbrales, sonidos y tema visual.

Como decisión técnica importante, el WebSocket se procesa en un isolate para reducir carga en la interfaz. Los gráficos usan fl_chart y evitan interpolaciones visuales para que la señal se actualice de forma más directa. Durante una grabación, la app acumula muestras en memoria y al finalizar las envía al backend en bloques por tipo de sensor. Los umbrales y preferencias de alarma se guardan localmente con SharedPreferences.

#### Backend Go (backend/)

El backend está desarrollado en Go con Echo y funciona como intermediario entre el ESP32, la base de datos y la aplicación Flutter. Centraliza la lectura serial, normaliza las muestras, publica datos por WebSocket, expone endpoints REST y guarda usuarios, sesiones y mediciones en SQLite.

El punto de entrada es backend/cmd/app/main.go. Allí se carga la configuración, se inicializa la base de datos, se ejecutan migraciones, se intenta abrir el puerto serial y se registran las rutas HTTP. Si el puerto serial no está disponible, el backend utiliza un simulador interno para generar muestras de prueba.

La base de datos se configura desde backend/cmd/database/database.go. Por defecto usa SQLite y puede guardar el archivo en la ruta definida por DB_PATH; si no se indica una ruta, usa una ubicación local bajo el directorio del usuario.

La comunicación con sensores está agrupada en backend/internal/sensors/. Esa carpeta contiene los modelos de datos crudos y normalizados, la implementación de lectura serial, el simulador, el administrador de muestras y la ruta WebSocket /ws/sensors. El backend convierte los mensajes del firmware en paquetes normalizados de tipo ecg, bpm o air.

El resto del dominio se separa por módulo:

- users/: alta, consulta y eliminación de usuarios.
- sessions/: creación y cierre de sesiones, resúmenes, historial y exportación CSV.
- bpm/: persistencia y consulta de mediciones de frecuencia cardíaca.
- ecg/: persistencia y consulta de mediciones ECG.
- air/: persistencia y consulta de mediciones de calidad de aire/CO2.
- spo2/: estructura de persistencia para SpO2, aunque el firmware actual no envía datos de este sensor.

Las variables de entorno relevantes son PORT, DB_PATH y SERIAL_PORT. PORT define el puerto HTTP del backend, normalmente 8080. DB_PATH define la ubicación del archivo SQLite. SERIAL_PORT indica el puerto del ESP32, por ejemplo /dev/ttyUSB0 en Linux o COM3 en Windows.

#### Firmware ESP32 (sensors/)

El firmware se encuentra en sensors/sensores.ino y está escrito para ESP32 usando el entorno Arduino. Su función es adquirir las señales de los sensores, mostrar información básica en la pantalla OLED y enviar lecturas al backend por USB serial.

En setup() se inicializan el puerto serial, los pines, la resolución ADC, la pantalla OLED SSD1306 y el sensor de pulso. En loop() se ejecuta el ciclo principal: se revisa el estado de los electrodos del AD8232, se actualiza la frecuencia cardíaca del HW-827, se lee el MQ-135, se envían mensajes JSON por serial y se actualiza la pantalla local.

Las funciones auxiliares separan responsabilidades concretas. configurarPantalla() inicializa la OLED; configurarSensores() prepara PulseSensorPlayground; electrodosDesconectados() lee las salidas LO- y LO+ del AD8232; leerHW827() y actualizarHW827Cada2Segundos() gestionan el pulso; leerMQ135() toma la lectura analógica y la mapea a ppm aproximadas; enviarJSON() y enviarJSONNullECG() generan los mensajes seriales; y mostrarDatos() actualiza los valores visibles en la pantalla.

El firmware no implementa persistencia local en microSD. La persistencia de sesiones queda resuelta desde la app y el backend mediante SQLite.

#### Comandos de desarrollo y build

Desde la raíz del repositorio:

```
just --list
```

Backend:

```
just setup
just run-backend
just build
just test
```

Frontend:

```
just front-get
just front-gen
just front-run-linux
just front-run-windows
just front-test
```

Builds:

```
just build-linux-appimage
just build-windows-exe
just build-windows-installer
```

Observación: para generar el instalador Windows se requiere Inno Setup 6. Para compilar el backend con SQLite en Windows se requiere toolchain con CGO habilitado, por ejemplo MinGW/GCC.

### 5. Instalación y puesta en marcha

#### Requisitos generales

- Go 1.26 o compatible con el módulo del backend.
- Flutter estable con Dart 3.
- Just como command runner.
- Arduino IDE o Arduino CLI.
- Librerías Arduino:
  - Adafruit_GFX
  - Adafruit_SSD1306
  - PulseSensorPlayground
- Drivers USB-Serial según placa:
  - CP210x para placas con chip Silicon Labs.
  - CH340/CH341 para placas clonadas.
- En Linux, usuario con permisos sobre el puerto serial (dialout en Debian/Ubuntu o uucp en Arch).

#### Configuración del ESP32

1. Instalar Arduino IDE o Arduino CLI.
2. Agregar el soporte ESP32 en el gestor de tarjetas:

```
https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
```

3. Instalar las librerías necesarias desde el gestor de librerías.
4. Abrir el archivo:

```
sensors/sensores.ino
```

5. Seleccionar la placa ESP32 correspondiente.
6. Seleccionar el puerto serial del dispositivo.
7. Compilar y subir el sketch.
8. Verificar que el monitor serie muestre mensajes JSON como:

```
{"sensor":"AD8232","ecg":2098,"leads_off":false}
{"sensor":"HW827","bpm":72,"alerta":false}
{"sensor":"MQ135","co2_ppm":1200,"alerta":true}
```

Si la subida queda en Connecting..., mantener presionado el botón BOOT de la placa hasta que comience la carga.

#### Configuración del backend

1. Entrar al repositorio:

```
cd DataVital
```

2. Crear archivo .env a partir de la plantilla:

```
cp backend/.env.example backend/.env
```

3. Editar backend/.env según el puerto serial real:

```
PORT=8080
DB_PATH=./cmd/database/gorm.db
SERIAL_PORT=/dev/ttyUSB0
```

En Windows, un ejemplo común es:

```
SERIAL_PORT=COM3
```

4. Instalar dependencias y preparar backend:

```
just setup
```

5. Ejecutar backend:

```
just run-backend
```

Si el backend no puede abrir el puerto serial, inicia un simulador de Arduino. Esto permite probar la app sin hardware conectado.

#### Configuración del frontend

1. Instalar dependencias Flutter:

```
just front-get
```

2. Generar código Riverpod:

```
just front-gen
```

3. Ejecutar la aplicación:

Linux:

```
just front-run-linux
```

Windows:

```
just front-run-windows
```

Web:

```
just front-run-web
```

La app usa por defecto:

```
ws://localhost:8080/ws/sensors
```

Desde esa URL deduce la base REST:

```
http://localhost:8080
```

#### Puesta en marcha completa

1. Conectar el ESP32 por USB.
2. Cargar sensors/sensores.ino en la placa.
3. Confirmar el puerto serial del ESP32.
4. Configurar SERIAL_PORT en backend/.env.
5. Levantar el backend.
6. Abrir la app Flutter.
7. Crear o seleccionar un usuario.
8. Ingresar al dashboard y verificar:
   - indicador de conexión;
   - gráfico ECG;
   - KPI de frecuencia cardíaca;
   - gráfico y KPI de CO2.
9. Iniciar una grabación de sesión.
10. Detenerla, revisar resumen y guardar o descartar.
11. Consultar la sesión desde Historial o Reportes.

### 6. Manual de usuario

#### Capturas de pantalla

Espacio para insertar capturas de las pantallas principales.

No se pudo completar con capturas porque en este entorno no están instalados Flutter/Dart y no fue posible ejecutar la aplicación para tomar screenshots. Las capturas recomendadas para el DOCX final son:

- Pantalla de selección/creación de usuario.
- Dashboard con gráficos en vivo.
- Diálogo de guardado de sesión.
- Historial de sesiones.
- Vista de reportes.
- Vista de alertas.
- Vista de configuración.

#### Selección o creación de usuario

Al abrir la aplicación, el usuario debe seleccionar un perfil existente o registrar uno nuevo. La pantalla de usuarios permite:

- buscar usuarios por nombre o correo;
- crear un usuario con nombre, email y DNI;
- seleccionar un usuario activo;
- eliminar un usuario y sus sesiones asociadas.

La aplicación no permite acceder al dashboard sin usuario activo. Esta restricción está implementada en el router de Flutter.

#### Dashboard de bioseñales

El dashboard muestra la información en tiempo real recibida desde el backend:

- gráfico de electrocardiograma;
- frecuencia cardíaca en LPM;
- gráfico de respiración/calidad de aire basado en CO2;
- nivel de CO2 en ppm;
- estado de conexión con el backend/Arduino;
- botón para iniciar o detener grabación de sesión.

Cuando un sensor deja de enviar datos por más de unos segundos, la interfaz muestra el estado de sensor desconectado y limpia la visualización correspondiente.

#### Grabación de una sesión

Para registrar una medición:

1. Seleccionar un usuario.
2. Entrar al dashboard.
3. Presionar Grabar sesión.
4. La app crea una sesión en el backend y empieza a bufferizar muestras.
5. Presionar Detener.
6. La app finaliza la sesión, guarda las mediciones por sensor y pide confirmación.
7. En el diálogo final se puede:
   - revisar mínimos, promedios y máximos;
   - agregar notas u observaciones;
   - guardar la sesión;
   - descartar la sesión.

#### Historial de sesiones

La pantalla de historial lista las sesiones del usuario activo. Cada fila muestra:

- fecha;
- duración;
- valores mínimos, promedio y máximos de frecuencia cardíaca;
- valores mínimos, promedio y máximos de CO2;
- cantidad de alertas registradas.

Desde esta pantalla se pueden expandir filas, revisar detalles, eliminar sesiones y exportar datos cuando corresponda.

#### Reportes

La vista de reportes permite seleccionar una sesión histórica y generar un informe para el paciente. El formulario utiliza los datos de la sesión, el nombre del usuario activo, el DNI y notas clínicas ingresadas por el usuario.

Acciones disponibles:

- previsualizar reporte PDF;
- exportar CSV de la sesión.

El CSV se obtiene desde el endpoint:

```
GET /sessions/:id/export.csv
```

#### Alertas

La vista de alertas muestra:

- estado actual de frecuencia cardíaca;
- estado actual de CO2;
- umbrales configurables;
- historial local de alarmas recientes.

Cuando una lectura supera un umbral, la aplicación activa un banner global de alarma crítica. El banner permite:

- ver detalles;
- silenciar o reactivar sonido;
- descartar la alarma.

Las alarmas son locales al frontend: los umbrales y el historial de alarmas se guardan con SharedPreferences. No hay persistencia backend de eventos de alarma en el código actual.

#### Configuración

La pantalla de configuración permite:

- habilitar o deshabilitar alarmas de bioseñales;
- habilitar o deshabilitar sonido de alarma;
- seleccionar tono de alarma;
- probar el sonido seleccionado;
- cambiar el tema visual entre claro, oscuro o sistema.

Los umbrales actuales son:

| Umbral | Valor por defecto |
| --- | ---: |
| Frecuencia cardíaca mínima | 60 BPM |
| Frecuencia cardíaca máxima | 100 BPM |
| CO2 máximo | 3500 ppm |

#### Recomendaciones de uso seguro

- Usar el sistema solo con fines académicos.
- No utilizarlo para diagnóstico o monitoreo clínico real.
- Para pruebas con ECG en una persona, alimentar el sistema de forma segura y aislada.
- Evitar conectar el cuerpo a circuitos alimentados directamente desde la red eléctrica.
- Interpretar MQ-135 como referencia didáctica, no como medidor clínico calibrado.

### Datos que quedaron pendientes por falta de información

| Dato pendiente | Motivo |
| --- | --- |
| Integrantes del grupo | No aparecen en README, docs ni plantilla con datos completos. |
| Fotos del hardware | No hay imágenes del montaje físico en el repositorio. |
| Modelo exacto de ESP32 | El firmware usa ESP32 genérico, pero no documenta placa exacta. |
| Pines I2C reales de OLED | El código usa Wire sin definir SDA/SCL. |
| Alimentación exacta de cada módulo | No hay tabla eléctrica real ni esquemático del montaje. |
| microSD | Documentado como objetivo, pero no implementado en firmware actual. |
| LM386 | Documentado como componente previsto, pero no integrado en firmware actual. |
| SpO2 real | Hay backend para SpO2, pero no hay sensor MAX30100/HW-827 SpO2 integrado en firmware actual. |
| Diagrama esquemático del hardware | No existe en el repositorio. |
| Capturas de la app | No se pudieron generar porque el entorno no tiene Flutter/Dart instalado. |
