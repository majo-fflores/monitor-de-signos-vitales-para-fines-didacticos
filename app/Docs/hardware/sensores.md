# Especificación de Hardware y Sensores — DataVital

Este documento detalla los sensores analógicos y digitales que forman parte de la arquitectura de adquisición de bioseñales y monitorización de **DataVital**, especificando qué datos devuelven, cómo los interpreta la aplicación y qué tipos de visualización se recomiendan para cada uno en el dashboard en tiempo real.

---

## 🔌 Especificaciones de Sensores

### 1. Electrocardiografía (ECG) — AD8232
El **AD8232** es un circuito integrado de acondicionamiento de señal (Analog Front End - AFE) diseñado específicamente para extraer, amplificar y filtrar señales bioeléctricas muy débiles del corazón (biopotenciales) en presencia de ruido (como los movimientos musculares).

*   **¿Qué mide?:** La actividad eléctrica del corazón en milivoltios a través de 3 electrodos colocados en el cuerpo (Brazo Derecho - RA, Brazo Izquierdo - LA, Pierna Derecha - RL / Referencia).
*   **Datos que devuelve:** 
    *   **Señal Analógica Cruda (ECG):** Una señal de voltaje analógica que oscila continuamente. En un microcontrolador de 10 bits (como Arduino Uno), se lee como un valor entre `0` y `1023`.
    *   **Estado de los Electrodos (LOD- / LOD+):** Dos salidas digitales de detección de "leads-off" que indican si un electrodo se ha desconectado físicamente del paciente.
*   **Visualización Recomendada:**
    *   **Gráfico Principal:** Un **Gráfico de Líneas Continuas de Barrido de Alta Velocidad (ECG Sweeping Line Chart)** en tiempo real. La latencia de animación debe ser nula (`Duration.zero`) y debe graficarse a un muestreo de ~100-200 Hz para apreciar claramente la morfología del complejo QRS (picos P, Q, R, S, T).
    *   **Indicador Auxiliar:** Un LED de estado visual en la UI para la desconexión de electrodos (Leads-Off Detection), cambiando a rojo cuando `LOD-` o `LOD+` estén activos.

---

### 2. Oximetría de Pulso ($SpO_2$) y Pulso — MAX30100
El **MAX30100** es un sensor digital integrado de oximetría de pulso y monitor de frecuencia cardíaca. Utiliza dos LEDs (uno rojo de 660nm y otro infrarrojo de 880nm/940nm) y un fotodetector para medir la absorción de luz a través del tejido de un dedo (fotopletismografía - PPG).

*   **¿Qué mide?:** La concentración de oxígeno en la sangre capilar ($SpO_2$) y los cambios en el volumen de sangre capilar asociados a los latidos del corazón.
*   **Datos que devuelve (a través de I2C):**
    *   **Frecuencia Cardíaca (BPM):** Un valor entero procesado por la librería que indica los latidos por minuto (rango fisiológico típico: 30 - 250 BPM).
    *   **Saturación de Oxígeno ($SpO_2$):** Un valor porcentual de `0` a `100%` (rango normal saludable: 95% - 100%).
    *   **Onda Pletismográfica (PPG):** Datos de reflectancia infrarroja (IR) y roja (RED) cruda que muestran los pulsos de volumen sanguíneo con cada latido.
    *   **Temperatura:** Sensor de temperatura interno en el chip (utilizado comúnmente para compensación de deriva térmica).
*   **Visualización Recomendada:**
    *   **Gráficos Requeridos (¿Hacen falta dos?):** 
        *   **Sí, se recomiendan dos formatos complementarios:**
            1.  **Gráfico de Área PPG (Onda Pletismográfica):** Un gráfico de línea suavizada de alta frecuencia con un gradiente de relleno bajo la curva. Permite verificar visualmente la calidad de la señal capilar (muesca dicrota) antes de confiar en los valores numéricos procesados.
            2.  **Display Numérico Gigante y Sparkline:** Para los valores procesados ($SpO_2$ % y BPM), basta con un visualizador numérico de gran tamaño con fuentes monoespaciadas (`tabularFigures()`) acompañado de una mini línea de tendencia histórica (sparkline) de los últimos 5 minutos para observar la estabilidad del paciente. No hace falta un gráfico grande para cada uno; un solo gráfico dinámico para la onda PPG capilar es suficiente para la sección interactiva.

---

### 3. Calidad del Aire y Gases — MQ-135
El **MQ-135** es un sensor electroquímico semiconductor de gas con una resistencia interna que varía según la presencia de gases nocivos en el ambiente.

*   **¿Qué mide?:** Detecta cambios en la concentración de gases como Amoníaco ($NH_3$), Óxidos de Nitrógeno ($NOx$), Alcohol, Benceno, Humo y Dióxido de Carbono ($CO_2$). **Nota técnica:** Al ser de amplio espectro, no discrimina de forma nativa qué gas detecta, por lo que actúa como un sensor general de "Calidad del Aire". Con calibración previa en aire limpio ($R_0$), se puede aproximar la medición de $CO_2$ o gases nocivos.
*   **Datos que devuelve:**
    *   **Salida Analógica (AO):** Voltaje analógico de `0V` a `5V` (mapeado de `0` a `1023` en el microcontrolador). A mayor presencia de gases nocivos, menor es la resistencia interna del sensor y mayor es el voltaje de salida analógico.
    *   **Salida Digital (DO):** Una señal digital de nivel alto/bajo que se activa al superar un umbral de concentración preestablecido mediante un potenciómetro integrado en el módulo.
*   **Visualización Recomendada:**
    *   **Gráfico Principal:** Un **Gráfico de Aguja/Tacómetro (Gauge Chart)** o una barra de progreso circular segmentada. Esto permite clasificar visualmente el estado del aire en zonas intuitivas: Verde (Saludable / `< 600 ppm`), Amarillo (Precaución / `600 - 1000 ppm`) y Rojo (Crítico / `> 1000 ppm`).
    *   **Gráfico de Tendencia Histórica:** Un gráfico de línea estándar de baja velocidad (actualizado cada 5-10 segundos) para monitorear el comportamiento de la calidad del aire a lo largo de las horas en la habitación.

---

### 4. Acondicionamiento y Auscultación Digital — LM386
El **LM386** no es un sensor físico por sí mismo, sino un **amplificador de audio operacional de bajo voltaje** de alta eficiencia y bajo ruido en reposo.

*   **¿Qué hace en el sistema?:** Actúa como la etapa de **acondicionamiento de señal acústica (Auscultación Digital)**. Se empareja con un elemento receptor acústico (como un micrófono de condensador electret o un disco piezoeléctrico) sellado acústicamente dentro de una campana de estetoscopio. El LM386 amplifica los sonidos cardíacos y respiratorios corporales de muy baja frecuencia (típicamente entre 20 Hz y 200 Hz), que de otro modo serían imperceptibles para las entradas ADC del microcontrolador.
*   **Datos que devuelve (a través del circuito):**
    *   **Señal de Sonido Amplificada (Fonocardiograma - PCG):** Una señal analógica de audio fluctuante. Esta señal requiere un desplazamiento DC (bias) a la mitad de la escala de referencia (ej. 2.5V) para que la entrada analógica del microcontrolador pueda registrar los ciclos negativos de la onda sonora sin recortar la señal.
*   **Visualización Recomendada:**
    *   **Gráfico Recomendado:** Un **Fonocardiograma (PCG / Audio Waveform Chart)**. Se implementa como un gráfico de líneas simétricas tipo espejo (waveform de audio) o un gráfico de líneas oscilantes rápidas. Dado que el sonido tiene frecuencias más altas que los signos vitales, esta gráfica debe actualizarse a un ritmo mayor (~500 Hz - 1 kHz) o usar buffers de muestreo rápido para graficar envolventes de amplitud sonora en lugar de la señal de audio en tiempo real directamente, evitando saturar la interfaz.

---

## 📊 Matriz de Visualización en el Dashboard

| Sensor | Signo/Mapeado | Unidad | Tipo de Gráfico Recomendado | Refresh Rate | Prioridad UI |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **AD8232** | ECG (Actividad Eléctrica) | $mV$ / Arbitrario | Sweeping Line Chart (Sin delay) | Alta (100+ Hz) | **Crítica** |
| **MAX30100** | Onda Pletismográfica (PPG) | Intensidad IR | Line Chart con gradiente de área | Alta (50 Hz) | **Alta** |
| **MAX30100** | Frecuencia Cardíaca / $SpO_2$ | $BPM$ / $\%$ | KPI Display + Sparkline de tendencia | Baja (1 Hz) | **Alta** |
| **MQ-135** | Calidad del Aire / $CO_2$ | $ppm$ (Partes por millón) | Radial Gauge (Verde/Amarillo/Rojo) | Muy Baja (0.1 Hz)| **Media** |
| **LM386** | Auscultación / Fonocardiograma | Amplitud Sonido | Audio Waveform Chart (Espejo) | Muy Alta (500+ Hz)| **Media/Baja** |

---

## ⚠️ Consideraciones de Seguridad y Aislamiento

1.  **Dispositivo de Carácter Pedagógico:** Ninguno de los componentes listados posee certificación médica FDA/CE. Están diseñados estrictamente para aprendizaje, demostración e investigación de adquisición de señales.
2.  **Aislamiento Eléctrico Obligatorio:** Al realizar pruebas con el sensor de ECG AD8232 conectado a una persona, la computadora y el microcontrolador **deben estar completamente desconectados de la red eléctrica de pared** (por ejemplo, alimentando una laptop solo con batería o utilizando aisladores galvánicos USB/optoacopladores), previniendo cualquier riesgo de descarga por falla de tierra.
